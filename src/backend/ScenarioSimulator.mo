import PseudoRandomX "mo:xtended-random/PseudoRandomX";
import Buffer "mo:base/Buffer";
import Nat "mo:base/Nat";
import TrieSet "mo:base/TrieSet";
import Array "mo:base/Array";
import Debug "mo:base/Debug";
import Text "mo:base/Text";
import Principal "mo:base/Principal";
import HashMap "mo:base/HashMap";
import Iter "mo:base/Iter";
import Float "mo:base/Float";
import Int "mo:base/Int";
import CharacterHandler "handlers/CharacterHandler";
import Scenario "models/entities/Scenario";
import Character "models/Character";
import UserHandler "handlers/UserHandler";
import Creature "models/entities/Creature";
import Weapon "models/entities/Weapon";
import CombatSimulator "CombatSimulator";
import Outcome "models/Outcome";

module {
    type Prng = PseudoRandomX.PseudoRandomGenerator;

    public type ScenarioResult = {
        log : [Outcome.OutcomeLogEntry];
        kind : { #defeat; #inProgress };
    };

    public type Player = {
        id : Principal;
    };

    public func run(
        prng : Prng,
        players : [Player],
        userHandler : UserHandler.Handler,
        characterHandler : CharacterHandler.Handler,
        scenario : Scenario.Scenario,
        scenarioMetaData : Scenario.ScenarioMetaData,
        creatures : HashMap.HashMap<Text, Creature.Creature>,
        weapons : HashMap.HashMap<Text, Weapon.Weapon>,
        choiceOrUndecided : ?Text,
    ) : ScenarioResult {
        let logEntries = Buffer.Buffer<Outcome.OutcomeLogEntry>(5);
        let helper = Helper(
            prng,
            players,
            characterHandler,
            userHandler,
            scenario,
            creatures,
            weapons,
            logEntries,
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
                    let character = helper.getCharacterStats();
                    var creature = helper.getRandomCreature(combat.creature);
                    let maxTurns = 10;
                    let combatResult = CombatSimulator.run(prng, character, creature, maxTurns);
                    logEntries.add(#combat(combatResult));
                    if (combatResult.healthDelta < 0) {
                        // TODO ignore??
                        ignore helper.damageCharacter(Int.abs(combatResult.healthDelta));
                    } else {
                        helper.heal(Int.abs(combatResult.healthDelta));
                    };
                    switch (combatResult.kind) {
                        case (#victory) {
                            helper.log("You defeat the creature!");
                        };
                        case (#defeat) {
                            helper.log("You were defeated!");
                            return {
                                log = helper.getLog();
                                kind = #defeat;
                            };
                        };
                        case (#maxTurnsReached) {
                            helper.log("The battle ends in a draw.");
                            // TODO?
                        };
                    };
                };
                case (#effects(effects)) {
                    for (effect in effects.vals()) {
                        switch (helper.applyEffect(effect)) {
                            case (#alive) (); // Continue
                            case (#dead) {
                                return {
                                    log = helper.getLog();
                                    kind = #defeat;
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
            log = helper.getLog();
            kind = #inProgress;
        };
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

    private class Helper(
        prng : Prng,
        players : [Player],
        characterHandler : CharacterHandler.Handler,
        userHandler : UserHandler.Handler,
        scenario : Scenario.Scenario,
        creatures : HashMap.HashMap<Text, Creature.Creature>,
        weapons : HashMap.HashMap<Text, Weapon.Weapon>,
        logEntries : Buffer.Buffer<Outcome.OutcomeLogEntry>,
    ) {

        public func getCharacterStats() : CombatSimulator.CombatStats {
            characterHandler.get();
        };

        public func getRandomCreature(kind : Scenario.CombatCreatureKind) : CombatSimulator.CombatStats {
            let creatureIds = switch (kind) {
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
            let selectedCreatureId = prng.nextArrayElement(creatureIds);
            getCreatureStats(selectedCreatureId);
        };

        private func getCreatureStats(creatureId : Text) : CombatSimulator.CombatStats {
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
                    for (player in players.vals()) {
                        switch (userHandler.unlockAchievement(player.id, achievementId)) {
                            case (#ok or #err(#achievementAlreadyUnlocked)) ();
                            case (#err(#userNotFound)) Debug.trap("User not found: " # Principal.toText(player.id));
                            case (#err(#achievementNotFound)) Debug.trap("Achievement not found: " # achievementId);
                        };
                    };
                };
            };
            #alive;
        };

        public func log(message : Text) {
            logEntries.add(#text(message));
        };

        public func setCharacterHealth(newHealth : Nat) {
            characterHandler.setHealth(newHealth);
        };

        public func damageCharacter(amount : Nat) : { #alive; #dead } {
            logEntries.add(#healthDelta(-amount));
            if (characterHandler.takeDamage(amount)) {
                #alive;
            } else {
                #dead;
            };
        };

        public func heal(amount : Nat) {
            logEntries.add(#healthDelta(amount));
            characterHandler.heal(amount);
        };

        public func addItem(item : Text) : Bool {
            logEntries.add(#addItem(item));
            characterHandler.addItem(item);
        };

        public func removeItem(item : Text) : Bool {
            logEntries.add(#removeItem(item));
            characterHandler.removeItem(item);
        };

        public func loseRandomItem() : Bool {
            let items = characterHandler.getItems();
            if (TrieSet.size(items) < 1) return false;
            let randomItem = prng.nextArrayElement(TrieSet.toArray(items));
            removeItem(randomItem);
        };

        public func addGold(amount : Nat) {
            logEntries.add(#goldDelta(amount));
            characterHandler.addGold(amount);
        };

        public func upgradeStat(kind : Character.CharacterStatKind, amount : Nat) {
            let logEntry = switch (kind) {
                case (#attack) #attackDelta(amount);
                case (#defense) #defenseDelta(amount);
                case (#speed) #speedDelta(amount);
                case (#magic) #magicDelta(amount);
                case (#maxHealth) #maxHealthDelta(amount);
            };
            logEntries.add(logEntry);
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
                logEntries.add(#goldDelta(-amount));
                return true;
            } else {
                log("You don't have " # Nat.toText(amount) # " gold");
                return false;
            };
        };

        public func addTrait(trait : Text) : Bool {
            logEntries.add(#addTrait(trait));
            characterHandler.addTrait(trait);
        };

        public func removeTrait(trait : Text) : Bool {
            logEntries.add(#removeTrait(trait));
            characterHandler.removeTrait(trait);
        };

        public func getLog() : [Outcome.OutcomeLogEntry] {
            Buffer.toArray(logEntries);
        };
    };
};
