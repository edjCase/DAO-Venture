import PseudoRandomX "mo:xtended-random/PseudoRandomX";
import Buffer "mo:base/Buffer";
import Nat "mo:base/Nat";
import TrieSet "mo:base/TrieSet";
import Array "mo:base/Array";
import Debug "mo:base/Debug";
import Text "mo:base/Text";
import Principal "mo:base/Principal";
import HashMap "mo:base/HashMap";
import Int "mo:base/Int";
import Iter "mo:base/Iter";
import Float "mo:base/Float";
import Order "mo:base/Order";
import Prelude "mo:base/Prelude";
import Option "mo:base/Option";
import CharacterHandler "handlers/CharacterHandler";
import Outcome "models/Outcome";
import Scenario "models/entities/Scenario";
import Character "models/Character";
import UserHandler "handlers/UserHandler";
import ScenarioHandler "handlers/ScenarioHandler";
import Creature "models/entities/Creature";
import Weapon "models/entities/Weapon";
import IterTools "mo:itertools/Iter";

module {
    type Prng = PseudoRandomX.PseudoRandomGenerator;

    public func run(
        prng : Prng,
        members : [ScenarioHandler.Member],
        userHandler : UserHandler.Handler,
        characterHandler : CharacterHandler.Handler,
        scenario : Scenario.Scenario,
        scenarioMetaData : Scenario.ScenarioMetaData,
        creatures : HashMap.HashMap<Text, Creature.Creature>,
        weapons : HashMap.HashMap<Text, Weapon.Weapon>,
        choiceOrUndecided : ?Text,
    ) : Outcome.Outcome {
        let messages = Buffer.Buffer<Text>(5);
        let helper = Helper(
            prng,
            members,
            characterHandler,
            userHandler,
            scenario,
            creatures,
            weapons,
            messages,
        );

        let initialPathId = switch (choiceOrUndecided) {
            case (null) { scenarioMetaData.undecidedPathId };
            case (?choice) {
                let ?choiceData = Array.find(
                    scenarioMetaData.choices,
                    func(c : Scenario.Choice) : Bool { c.id == choice },
                ) else Debug.trap("Invalid choice: " # choice);
                choiceData.pathId;
            };
        };

        var currentPathId = initialPathId;

        label l loop {
            let ?currentPath = Array.find(
                scenarioMetaData.paths,
                func(p : Scenario.OutcomePath) : Bool { p.id == currentPathId },
            ) else Debug.trap("Invalid path ID: " # currentPathId);
            helper.log(currentPath.description);

            switch (currentPath.kind) {
                case (#combat(combat)) {
                    let outcome = runCombat(prng, combat, helper);
                    switch (outcome) {
                        case (#alive) (); // Continue
                        case (#dead) {
                            return {
                                messages = helper.getMessages();
                                choiceOrUndecided = choiceOrUndecided;
                            };
                        };
                    };
                };
                case (#effects(effects)) {
                    for (effect in effects.vals()) {
                        switch (helper.applyEffect(effect)) {
                            case (#alive) (); // Continue
                            case (#dead) {
                                return {
                                    messages = helper.getMessages();
                                    choiceOrUndecided = choiceOrUndecided;
                                };
                            };
                        };
                    };
                };
            };

            if (currentPath.paths.size() == 0) {
                break l;
            };

            let validPaths = Array.filter(
                currentPath.paths,
                func(p : Scenario.WeightedOutcomePath) : Bool {
                    switch (p.condition) {
                        case (null) true;
                        case (?condition) helper.meetsCondition(condition);
                    };
                },
            );

            if (validPaths.size() == 0) {
                break l;
            };
            let pathsWithWeights = Array.map<Scenario.WeightedOutcomePath, (Text, Float)>(
                validPaths,
                func(p : Scenario.WeightedOutcomePath) : (Text, Float) {
                    (p.pathId, p.weight);
                },
            );
            let nextPathId = prng.nextArrayElementWeighted(pathsWithWeights);
            currentPathId := nextPathId;
        };
        {
            messages = Buffer.toArray(messages);
            choiceOrUndecided = choiceOrUndecided;
        };
    };
    func runCombat(
        prng : Prng,
        combat : Scenario.CombatPath,
        helper : Helper,
    ) : { #alive; #dead } {
        Debug.print("Running combat");
        let character = helper.getCharacterStats();
        Debug.print("Character: " # debug_show (character));
        var creatures = combat.creatures.vals()
        |> Iter.map(
            _,
            func(c : Scenario.CombatCreatureKind) : CombatStats {
                Debug.print("Getting creature stats for: " # debug_show (c));
                let creatureIds = helper.getCreatureIds(c);
                Debug.print("Creature IDs: " # debug_show (creatureIds));
                let selectedCreatureId = prng.nextArrayElement(creatureIds);
                Debug.print("Selected creature ID: " # selectedCreatureId);
                helper.getCreatureStats(selectedCreatureId);
            },
        )
        |> Buffer.fromIter<CombatStats>(_);

        func calculateWeaponStats(weapon : Weapon.Weapon) : Weapon.WeaponStats {
            var attacks = weapon.baseStats.attacks;
            var minDamage = weapon.baseStats.minDamage;
            var maxDamage = weapon.baseStats.maxDamage;
            var accuracy = weapon.baseStats.accuracy;
            var criticalChance = weapon.baseStats.criticalChance;
            var criticalMultiplier = weapon.baseStats.criticalMultiplier;
            for (modifier in weapon.baseStats.statModifiers.vals()) {

                let value : Int = switch (modifier.characterStat) {
                    case (#attack) character.attack;
                    case (#magic) character.magic;
                    case (#speed) character.speed;
                    case (#defense) character.defense;
                    case (#health(health)) {
                        if (health.inverse) {
                            character.maxHealth - character.health;
                        } else {
                            character.health;
                        };
                    };
                    case (#gold) character.gold;
                };
                let minValue : Nat = switch (modifier.attribute) {
                    case (#attacks) 1;
                    case (#damage) 1;
                    case (#minDamage) 1;
                    case (#maxDamage) 1;
                    case (#accuracy) 1;
                    case (#criticalChance) 0;
                    case (#criticalMultiplier) 1;
                };

                let scaledValue : Nat = Int.abs(Int.max(minValue, Int.abs(Float.toInt(Float.fromInt(value) * modifier.factor))));

                switch (modifier.attribute) {
                    case (#attacks) attacks += scaledValue;
                    case (#damage) {
                        minDamage += scaledValue;
                        maxDamage += scaledValue;
                    };
                    case (#minDamage) minDamage += scaledValue;
                    case (#maxDamage) maxDamage += scaledValue;
                    case (#accuracy) accuracy += scaledValue;
                    case (#criticalChance) criticalChance += scaledValue;
                    case (#criticalMultiplier) criticalMultiplier += scaledValue;
                };
            };

            {
                attacks = weapon.baseStats.attacks;
                minDamage = weapon.baseStats.minDamage;
                maxDamage = weapon.baseStats.maxDamage;
                accuracy = weapon.baseStats.accuracy;
                criticalChance = weapon.baseStats.criticalChance;
                criticalMultiplier = weapon.baseStats.criticalMultiplier;
                statModifiers = weapon.baseStats.statModifiers;
            };
        };

        func calculateWeaponDamage(weaponStats : Weapon.WeaponStats) : Nat {
            var damage = prng.nextNat(weaponStats.minDamage, weaponStats.maxDamage) + 5;

            if (prng.nextNat(1, 100) <= weaponStats.criticalChance) {
                // Crit
                let damagePlusCrit = damage
                |> percentMultiply(damage, weaponStats.criticalMultiplier)
                |> Int.max(1, _)
                |> Int.abs(_);
                damage := damagePlusCrit;
            };
            damage;
        };

        func calculateHitChance(attacker : { accuracy : Int }, defender : { speed : Int }) : Nat {
            let hitChance : Int = attacker.accuracy - defender.speed + 50;
            // Clamp to 5-100%
            hitChance |> Int.min(100, _) |> Int.max(5, _) |> Int.abs(_);
        };

        func hitAndDamage(
            attacker : {
                health : Nat;
                speed : Int;
                weapon : Weapon.Weapon;
            },
            defender : {
                health : Nat;
                defense : Int;
                speed : Int;
            },
            isCharacter : Bool,
            damageFunc : (Nat) -> { #alive; #dead },
        ) : { #alive; #dead } {
            let weaponStats = calculateWeaponStats(attacker.weapon);
            let hitChance = calculateHitChance(weaponStats, defender);
            for (_ in Iter.range(0, weaponStats.attacks - 1)) {
                if (prng.nextNat(1, 100) <= hitChance) {
                    var damage = calculateWeaponDamage(weaponStats);
                    // TODO better defense
                    // TODO do damage type/resistances
                    let finalDamage = Int.abs(Int.max(0, damage - defender.defense));
                    helper.log((if (isCharacter) "You hit for " else "The creature hits you for ") # Nat.toText(finalDamage) # " damage.");
                    switch (damageFunc(finalDamage)) {
                        case (#alive) ();
                        case (#dead) return #dead;
                    };
                } else {
                    helper.log(if (isCharacter) "Your attack misses." else "The creature's attack misses.");
                };
            };
            #alive;
        };

        // Determine initiative
        let characterInitiative : Int = character.speed + prng.nextNat(1, 20);

        type InitiativeSlot = { #character; #creatureIndex : Nat };
        type SlotAndValue = { slot : InitiativeSlot; initiative : Int };

        let initiativeSlots : [InitiativeSlot] = creatures.vals()
        |> IterTools.enumerate(_)
        |> Iter.map(
            _,
            func((i, c) : (Nat, CombatStats)) : SlotAndValue = {
                slot = #creatureIndex(i);
                initiative = c.speed + prng.nextNat(1, 20);
            },
        )
        // Add character
        |> IterTools.chain<SlotAndValue>(_, [{ slot = #character; initiative = characterInitiative } : SlotAndValue].vals())
        // Sort by initiative
        |> Iter.sort(_, func(x : SlotAndValue, y : SlotAndValue) : Order.Order = Int.compare(x.initiative, y.initiative))
        |> Iter.map(_, func(x : SlotAndValue) : InitiativeSlot = x.slot)
        |> Iter.toArray(_);

        func creatureIsAlive(i : Nat) : Bool {
            let creature = creatures.get(i) else Debug.trap("Creature not found at index: " # Int.toText(i));
            creature.health > 0;
        };

        func getTargetCreature() : ?(CombatStats, Nat) {
            let slot = initiativeSlots.vals()
            |> Iter.filter(
                _,
                func(s : InitiativeSlot) : Bool = switch (s) {
                    case (#creatureIndex(i)) creatureIsAlive(i);
                    case (#character) false;
                },
            ).next();
            switch (slot) {
                case (null) null;
                case (? #creatureIndex(i)) ?(creatures.get(i), i);
                case (? #character) Prelude.unreachable();
            };
        };

        Debug.print("Initiative slots: " # debug_show (initiativeSlots));
        var initiativeIndex = 0;
        var turn = 0;
        loop {
            switch (initiativeSlots[initiativeIndex]) {
                case (#character) {
                    let ?(targetCreature, creatureIndex) = getTargetCreature() else Debug.trap("No target creature found");
                    var newHealth = targetCreature.health;
                    let creatureState = hitAndDamage(
                        character,
                        targetCreature,
                        true,
                        func(damage : Nat) {
                            newHealth -= damage;
                            if (newHealth <= 0) {
                                helper.log("You defeat the creature " # Int.toText(creatureIndex + 1) # "!");
                                return #dead;
                            };
                            #alive;
                        },
                    );

                    creatures.put(
                        creatureIndex,
                        {
                            targetCreature with
                            health = Int.abs(Int.max(0, newHealth));
                        },
                    );

                    switch (creatureState) {
                        case (#dead) {
                            let anyCreaturesAlive = creatures.vals()
                            |> IterTools.any(_, func(c : CombatStats) : Bool { c.health > 0 });
                            if (not anyCreaturesAlive) {
                                return #alive; // Character is alive
                            };
                        };
                        case (#alive) ();
                    };
                };
                case (#creatureIndex(i)) {
                    if (creatureIsAlive(i)) {
                        let creature = creatures.get(i) else Debug.trap("Creature not found at index: " # Int.toText(i));
                        let characterState = hitAndDamage(
                            creature,
                            character,
                            false,
                            helper.damageCharacter,
                        );
                        switch (characterState) {
                            case (#dead) return #dead; // Stop if character is dead
                            case (#alive) ();
                        };
                    };
                };
            };
            initiativeIndex := (initiativeIndex + 1) % initiativeSlots.size();
            turn += 1;
            if (turn > 100) {
                helper.log("Combat took too long, you flee.");
                return #alive; // TODO
            };
        };
    };

    func percentMultiply(value : Nat, percent : Nat) : Nat {
        Int.abs(Float.toInt(Float.floor(Float.fromInt(value) * (Float.fromInt(percent) / 100.0))));
    };

    func getNatValue(
        prng : Prng,
        value : Scenario.NatValue,
        data : [Scenario.GeneratedDataFieldInstance],
    ) : Nat {
        switch (value) {
            case (#raw(n)) n;
            case (#random(min, max)) prng.nextNat(min, max);
            case (#dataField(id)) {
                let ?dataField = Array.find(
                    data,
                    func(d : Scenario.GeneratedDataFieldInstance) : Bool {
                        d.id == id;
                    },
                ) else Debug.trap("Data field not found: " # id);
                let #nat(value) = dataField.value else Debug.trap("Data field is not a Nat: " # id);
                value;
            };
        };
    };

    func getTextValue(
        prng : Prng,
        value : Scenario.TextValue,
        data : [Scenario.GeneratedDataFieldInstance],
    ) : Text {
        switch (value) {
            case (#raw(t)) t;
            case (#weighted(options)) prng.nextArrayElementWeighted(options);
            case (#dataField(id)) {
                let ?dataField = Array.find(data, func(d : Scenario.GeneratedDataFieldInstance) : Bool { d.id == id }) else Debug.trap("Data field not found: " # id);
                let #text(value) = dataField.value else Debug.trap("Data field is not a Text: " # id);
                value;
            };
        };
    };

    type CombatStats = {
        health : Nat;
        attack : Int;
        defense : Int;
        speed : Int;
        magic : Int;
        weapon : Weapon.Weapon;
        gold : Nat;
        maxHealth : Nat;
    };

    private class Helper(
        prng : Prng,
        members : [ScenarioHandler.Member],
        characterHandler : CharacterHandler.Handler,
        userHandler : UserHandler.Handler,
        scenario : Scenario.Scenario,
        creatures : HashMap.HashMap<Text, Creature.Creature>,
        weapons : HashMap.HashMap<Text, Weapon.Weapon>,
        messages : Buffer.Buffer<Text>,
    ) {

        public func getCharacterStats() : CombatStats {
            characterHandler.get();
        };

        public func getCreatureIds(kind : Scenario.CombatCreatureKind) : [Text] {
            switch (kind) {
                case (#id(id)) [id];
                case (#filter(filter)) {
                    let creatureFilter = switch (filter.location) {
                        case (#any) func(_ : Creature.Creature) : Bool = true;
                        case (#common) func(c : Creature.Creature) : Bool = c.location == #common;
                        case (#zone(zoneId)) func(c : Creature.Creature) : Bool = switch (c.location) {
                            case (#zoneIds(zoneIds)) Array.indexOf(zoneId, zoneIds, Text.equal) != null;
                            case (_) false;
                        };
                    };
                    creatures.vals()
                    |> Iter.filter(_, creatureFilter)
                    |> Iter.map(_, func(c : Creature.Creature) : Text = c.id)
                    |> Iter.toArray(_);
                };
            };
        };

        public func getCreatureStats(creatureId : Text) : CombatStats {
            let ?creature = creatures.get(creatureId) else Debug.trap("Creature not found: " # creatureId);
            let ?weapon = weapons.get(creature.weaponId) else Debug.trap("Weapon not found: " # creature.weaponId);
            {
                health = creature.health;
                maxHealth = creature.maxHealth;
                attack = creature.attack;
                defense = creature.defense;
                speed = creature.speed;
                magic = creature.magic;
                weapon = weapon;
                gold = 0; // TODO
            };
        };

        public func meetsCondition(condition : Scenario.Condition) : Bool {
            let character = characterHandler.get();
            switch (condition) {
                case (#hasGold(amountValue)) {
                    let amount = getNatValue(prng, amountValue, scenario.data);
                    character.gold >= amount;
                };
                case (#hasItem(itemValue)) {
                    let itemId = getTextValue(prng, itemValue, scenario.data);
                    TrieSet.mem(character.itemIds, itemId, Text.hash(itemId), Text.equal);
                };
                case (#hasTrait(traitValue)) {
                    let traitId = getTextValue(prng, traitValue, scenario.data);
                    TrieSet.mem(character.traitIds, traitId, Text.hash(traitId), Text.equal);
                };
            };
        };

        public func applyEffect(effect : Scenario.Effect) : { #alive; #dead } {
            switch (effect) {
                case (#reward) reward();
                case (#damage(amount)) {
                    Debug.print("Amount: " # debug_show (amount));
                    Debug.print("Data: " # debug_show (scenario.data));
                    let damageAmount = getNatValue(prng, amount, scenario.data);
                    switch (damageCharacter(damageAmount)) {
                        case (#alive) ();
                        case (#dead) return #dead;
                    };
                };
                case (#heal(amount)) {
                    heal(getNatValue(prng, amount, scenario.data));
                };
                case (#upgradeStat((stat, amount))) {
                    upgradeStat(stat, getNatValue(prng, amount, scenario.data));
                };
                case (#removeGold(amount)) {
                    ignore removeGold(getNatValue(prng, amount, scenario.data));
                };
                case (#addItem(item)) {
                    ignore addItem(getTextValue(prng, item, scenario.data));
                };
                case (#removeItem(item)) {
                    switch (item) {
                        case (#random) {
                            ignore loseRandomItem();
                        };
                        case (#specific(itemId)) {
                            ignore removeItem(getTextValue(prng, itemId, scenario.data));
                        };
                    };
                };
                case (#addTrait(trait)) {
                    ignore addTrait(getTextValue(prng, trait, scenario.data));
                };
                case (#removeTrait(trait)) {
                    switch (trait) {
                        case (#random) {
                            /* TODO: Implement random trait removal */
                        };
                        case (#specific(traitId)) {
                            ignore removeTrait(getTextValue(prng, traitId, scenario.data));
                        };
                    };
                };
                case (#achievement(achievementId)) {
                    for (member in members.vals()) {
                        switch (userHandler.unlockAchievement(member.id, achievementId)) {
                            case (#ok or #err(#achievementAlreadyUnlocked)) ();
                            case (#err(#userNotFound)) Debug.trap("User not found: " # Principal.toText(member.id));
                            case (#err(#achievementNotFound)) Debug.trap("Achievement not found: " # achievementId);
                        };
                    };
                };
            };
            #alive;
        };

        public func log(message : Text) {
            Debug.print(message);
            messages.add(message);
        };

        public func damageCharacter(amount : Nat) : { #alive; #dead } {
            log("You take " # Nat.toText(amount) # " damage.");
            if (characterHandler.takeDamage(amount)) {
                #alive;
            } else {
                #dead;
            };
        };

        public func heal(amount : Nat) {
            log("You heal " # Nat.toText(amount) # " health.");
            characterHandler.heal(amount);
        };

        public func addItem(item : Text) : Bool {
            log("You get " # item);
            characterHandler.addItem(item);
        };

        public func removeItem(item : Text) : Bool {
            log("You lose " # item);
            characterHandler.removeItem(item);
        };

        public func loseRandomItem() : Bool {
            let items = characterHandler.getItems();
            if (TrieSet.size(items) < 1) return false;
            let randomItem = prng.nextArrayElement(TrieSet.toArray(items));
            removeItem(randomItem);
        };

        public func addGold(amount : Nat) {
            log("You get " # Nat.toText(amount) # " gold");
            characterHandler.addGold(amount);
        };

        public func upgradeStat(kind : Character.CharacterStatKind, amount : Nat) {
            log("You upgrade your " # Character.toTextStatKind(kind) # " stat by " # Nat.toText(amount));
            characterHandler.upgradeStat(kind, amount);
        };

        type Reward = {
            #item : Text;
            #money : Nat;
        };
        // TODO reward table
        let weightedRewardTable : [(Reward, Float)] = [
            (#money(1), 20.0),
            (#money(10), 15.0),
            (#item("crystal"), 1.0),
        ];
        public func reward() {
            log("You find a reward!");
            switch (prng.nextArrayElementWeighted(weightedRewardTable)) {
                case (#money(amount)) addGold(amount);
                case (#item(item)) ignore addItem(item); // TODO already have item?
            };
        };

        public func removeGold(amount : Nat) : Bool {
            if (characterHandler.removeGold(amount)) {
                log("You lose " # Nat.toText(amount) # " gold");
                return true;
            } else {
                log("You don't have enough gold to lose " # Nat.toText(amount));
                return false;
            };
        };

        public func addTrait(trait : Text) : Bool {
            log("You gain the trait " # trait);
            characterHandler.addTrait(trait);
        };

        public func removeTrait(trait : Text) : Bool {
            log("You lose the trait " # trait);
            characterHandler.removeTrait(trait);
        };

        public func getMessages() : [Text] {
            Buffer.toArray(messages);
        };
    };
};
