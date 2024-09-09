import PseudoRandomX "mo:xtended-random/PseudoRandomX";
import Buffer "mo:base/Buffer";
import Nat "mo:base/Nat";
import Array "mo:base/Array";
import Debug "mo:base/Debug";
import Text "mo:base/Text";
import Principal "mo:base/Principal";
import HashMap "mo:base/HashMap";
import Iter "mo:base/Iter";
import Float "mo:base/Float";
import Result "mo:base/Result";
import Prelude "mo:base/Prelude";
import CharacterHandler "handlers/CharacterHandler";
import Scenario "models/entities/Scenario";
import Character "models/Character";
import UserHandler "handlers/UserHandler";
import Creature "models/entities/Creature";
import Weapon "models/entities/Weapon";
import CombatSimulator "CombatSimulator";
import ActionResult "models/ActionResult";
import ScenarioMetaData "models/entities/ScenarioMetaData";
import Action "models/entities/Action";
import IterTools "mo:itertools/Iter";
import Class "models/entities/Class";
import Race "models/entities/Race";
import Item "models/entities/Item";

module {
    type Prng = PseudoRandomX.PseudoRandomGenerator;

    public type RunStageError = {
        #scenarioComplete;
        #invalidChoice : Text;
        #invalidTarget;
        #targetRequired;
    };

    public type StageChoiceKind = {
        #choice : Text;
        #combat : CombatChoice;
        #reward : RewardChoice;
    };
    public type RewardChoice = {
        #item : ItemRewardChoice;
        #gold : Nat;
        #weapon : Text;
        #health : Nat;
    };

    public type ItemRewardChoice = {
        id : Text;
        inventorySlot : Nat;
    };

    public type CombatChoice = {
        actionId : Text;
        target : ?ActionResult.ActionTargetResult;
    };

    public func runStage(
        prng : Prng,
        playerId : Principal,
        userHandler : UserHandler.Handler,
        characterHandler : CharacterHandler.Handler,
        scenario : Scenario.Scenario,
        scenarioMetaData : ScenarioMetaData.ScenarioMetaData,
        creatures : HashMap.HashMap<Text, Creature.Creature>,
        classes : HashMap.HashMap<Text, Class.Class>,
        races : HashMap.HashMap<Text, Race.Race>,
        items : HashMap.HashMap<Text, Item.Item>,
        weapons : HashMap.HashMap<Text, Weapon.Weapon>,
        actions : HashMap.HashMap<Text, Action.Action>,
        choice : StageChoiceKind,
    ) : Result.Result<Scenario.ScenarioStageResult, RunStageError> {
        let logEntries = Buffer.Buffer<Scenario.OutcomeEffect>(5);
        let helper = Helper(
            prng,
            playerId,
            characterHandler,
            userHandler,
            scenario,
            scenarioMetaData,
            creatures,
            classes,
            races,
            items,
            weapons,
            actions,
            logEntries,
        );
        switch (scenario.state) {
            case (#choice(choiceState)) processChoice(choiceState, helper, choice);
            case (#combat(combatState)) processCombat(combatState, helper, choice);
            case (#reward(rewardState)) processReward(rewardState, helper, choice);
            case (#complete) return #err(#scenarioComplete);
        };

    };

    func processReward(
        state : Scenario.RewardScenarioState,
        helper : Helper,
        choice : StageChoiceKind,
    ) : Result.Result<Scenario.ScenarioStageResult, RunStageError> {
        let #reward(reward) = choice else return #err(#invalidChoice("Expected reward choice"));
        func validateRewardExists(reward : Scenario.RewardKind) : Bool {
            IterTools.any(
                state.options.vals(),
                func(r : Scenario.RewardKind) : Bool = r == reward,
            );
        };
        let kind = switch (reward) {
            case (#item(item)) #item(item.id);
            case (#gold(gold)) #gold(gold);
            case (#weapon(weaponId)) #weapon(weaponId);
            case (#health(health)) #health(health);
        };
        let true = validateRewardExists(kind) else return #err(#invalidChoice("Reward does not exist"));

        switch (reward) {
            case (#item(item)) {
                let result = helper.addItemToSlot(item.id, item.inventorySlot);
                switch (result) {
                    case (#ok(_)) {};
                    case (#err(#invalidSlot)) Debug.trap("Invalid slot: " # Nat.toText(item.inventorySlot));
                };
            };
            case (#gold(gold)) helper.addGold(gold);
            case (#weapon(weaponId)) helper.swapWeapon(weaponId);
            case (#health(health)) helper.heal(health);
        };
        #ok({
            effects = helper.getEffects();
            kind = #reward({ kind = kind });
        });
    };

    func processChoice(
        state : Scenario.ChoiceScenarioState,
        helper : Helper,
        choice : StageChoiceKind,
    ) : Result.Result<Scenario.ScenarioStageResult, RunStageError> {
        let #choice(choiceId) = choice else return #err(#invalidChoice("Expected scenario choice"));
        if (Array.indexOf(choiceId, state.choiceIds, Text.equal) == null) {
            return #err(#invalidChoice("Choice not available: " # choiceId));
        };
        let ?choiceData = Array.find(
            helper.scenarioMetaData.choices,
            func(c : ScenarioMetaData.Choice) : Bool {
                c.id == choiceId;
            },
        ) else Debug.trap("Invalid choice: " # choiceId);

        var currentPathId = choiceData.pathId;

        let kind = label l : Scenario.ScenarioChoiceResultKind loop {

            let ?currentPath = Array.find(
                helper.scenarioMetaData.paths,
                func(p : ScenarioMetaData.OutcomePath) : Bool {
                    p.id == choiceData.pathId;
                },
            ) else Debug.trap("Invalid path ID: " # choiceData.pathId);
            helper.log(currentPath.description);

            switch (currentPath.kind) {
                case (#combat(combat)) break l(startCombat(combat, helper));
                case (#effects(effects)) switch (processPathEffects(currentPath, effects, helper)) {
                    case (#complete) break l(#complete);
                    case (#death) break l(#death);
                    case (#nextPath(nextPathId)) currentPathId := nextPathId;
                };
                case (#reward(reward)) break l(startReward(reward, helper));
            };
        };
        #ok({
            effects = helper.getEffects();
            kind = #choice({
                choiceId = choiceData.id;
                kind = kind;
            });
        });

    };

    func startCombat(
        combat : ScenarioMetaData.CombatPath,
        helper : Helper,
    ) : Scenario.ScenarioChoiceResultKind {
        let creatureCombatStats = Buffer.Buffer<Scenario.CreatureCombatState>(combat.creatures.size());
        for (creature in combat.creatures.vals()) {
            creatureCombatStats.add(helper.getRandomCreature(creature));
        };
        let newActionIds = helper.getRandomCharacterActionIds();
        let character = helper.getCharacter();
        #startCombat({
            character = {
                health = character.health;
                maxHealth = character.maxHealth;
                shield = 0;
                statusEffects = [];
                availableActionIds = newActionIds;
            };
            creatures = Buffer.toArray(creatureCombatStats);
        });
    };

    func startReward(
        reward : ScenarioMetaData.RewardPath,
        helper : Helper,
    ) : Scenario.ScenarioChoiceResultKind {
        let options = switch (reward) {
            case (#random) {
                let itemId = helper.getRandomItemId();
                let gold = helper.prng.nextNat(1, 100); // TODO amount
                // TODO ratio
                let reward = if (helper.prng.nextRatio(1, 2)) {
                    #weapon(helper.getRandomWeaponId());
                } else {
                    #health(helper.prng.nextNat(1, 20)); // TODO amount
                };
                [#item(itemId), #gold(gold), reward];
            };
            case (#specificItemIds(itemIds)) {
                itemIds.vals()
                |> Iter.map(
                    _,
                    func(id : Text) : Scenario.RewardKind = #item(id),
                )
                |> Iter.toArray(_);
            };
        };
        #reward({ options });
    };

    func processPathEffects(
        currentPath : ScenarioMetaData.OutcomePath,
        effects : [ScenarioMetaData.Effect],
        helper : Helper,
    ) : { #complete; #death; #nextPath : Text } {

        label f for (effect in effects.vals()) {
            switch (helper.applyEffect(effect)) {
                case (#alive) (); // Continue
                case (#dead) {
                    return #death;
                };
            };
        };

        if (currentPath.paths.size() == 0) {
            return #complete; // No more paths
        };

        let validPaths = Array.filter(
            currentPath.paths,
            func(p : ScenarioMetaData.WeightedOutcomePath) : Bool {
                switch (p.condition) {
                    case (null) true;
                    case (?condition) helper.meetsCondition(condition);
                };
            },
        );

        if (validPaths.size() == 0) {
            return #complete; // No valid paths
        };
        let pathsWithWeights = Array.map<ScenarioMetaData.WeightedOutcomePath, (Text, Float)>(
            validPaths,
            func(p : ScenarioMetaData.WeightedOutcomePath) : (Text, Float) {
                (p.pathId, p.weight);
            },
        );
        let nextPathId = helper.prng.nextArrayElementWeighted(pathsWithWeights);
        #nextPath(nextPathId);
    };

    func processCombat(
        state : Scenario.CombatScenarioState,
        helper : Helper,
        choice : StageChoiceKind,
    ) : Result.Result<Scenario.ScenarioStageResult, RunStageError> {
        let #combat(combatChoice) = choice else return #err(#invalidChoice("Expected combat choice"));
        // Character turn first
        let action = switch (helper.getAction(combatChoice.actionId, state.character.availableActionIds)) {
            case (#ok(action)) action;
            case (#err(#notAvailable)) return #err(#invalidChoice("Action not available: " # combatChoice.actionId));
        };
        let creatureCount = state.creatures.size();
        let actionResult = switch (
            CombatSimulator.calculateActionResult(
                helper.prng,
                #character,
                action,
                creatureCount,
                combatChoice.target,
            )
        ) {
            case (#ok(result)) result;
            case (#err(#invalidTarget)) return #err(#invalidTarget);
            case (#err(#targetRequired)) return #err(#targetRequired);
        };

        let characterCombatStats : CombatSimulator.CombatStats = {
            var health = state.character.health;
            var maxHealth = state.character.maxHealth;
            var shield = state.character.shield;
            var statusEffects = Buffer.fromArray(state.character.statusEffects);
        };
        let creatureCombatStats = state.creatures.vals()
        |> Iter.map(
            _,
            func(c : Scenario.CreatureCombatState) : CombatSimulator.CombatStats {
                {
                    var health = c.health;
                    var maxHealth = c.maxHealth;
                    var shield = c.shield;
                    var statusEffects = Buffer.fromArray(c.statusEffects);
                };
            },
        )
        |> Iter.toArray(_);

        CombatSimulator.applyActionResult(characterCombatStats, creatureCombatStats, actionResult);

        func getLivingCreatures() : [Scenario.CreatureCombatState] {
            state.creatures.vals()
            |> Iter.filter(
                _,
                func(c : Scenario.CreatureCombatState) : Bool {
                    c.health > 0;
                },
            )
            |> Iter.toArray(_);
        };

        func checkForDefeat() : ?Scenario.ScenarioStageResult {
            if (characterCombatStats.health <= 0) {
                let livingCreatures = getLivingCreatures();
                return ?{
                    effects = helper.getEffects();
                    kind = #combat(#defeat({ creatures = livingCreatures }));
                };
            };
            null;
        };
        switch (checkForDefeat()) {
            case (?result) return #ok(result);
            case (null) ();
        };

        // Creature turns
        label f for ((i, creature) in IterTools.enumerate(state.creatures.vals())) {
            if (creature.health <= 0) continue f;
            let randomActionId = helper.prng.nextArrayElement(creature.availableActionIds);
            let creatureAction = switch (helper.getAction(randomActionId, creature.availableActionIds)) {
                case (#ok(action)) action;
                case (#err(#notAvailable)) Prelude.unreachable();
            };
            let actionResult = switch (
                CombatSimulator.calculateActionResult(
                    helper.prng,
                    #creature(i),
                    creatureAction,
                    creatureCount,
                    null,
                )
            ) {
                case (#ok(result)) result;
                case (#err(#invalidTarget)) Prelude.unreachable();
                case (#err(#targetRequired)) Prelude.unreachable();
            };
            CombatSimulator.applyActionResult(characterCombatStats, creatureCombatStats, actionResult);

            switch (checkForDefeat()) {
                case (?result) return #ok(result);
                case (null) ();
            };
        };
        helper.setCharacterHealth(characterCombatStats.health);
        let livingCreatures = getLivingCreatures();
        let combatKind : Scenario.ScenarioCombatResult = if (livingCreatures.size() == 0) {
            #victory;
        } else {
            let newActionIds = helper.getRandomCharacterActionIds();
            #inProgress({
                character = {
                    health = characterCombatStats.health;
                    maxHealth = characterCombatStats.maxHealth;
                    shield = characterCombatStats.shield;
                    statusEffects = Buffer.toArray(characterCombatStats.statusEffects);
                    availableActionIds = newActionIds;
                };
                creatures = livingCreatures;
            });
        };

        #ok({
            effects = helper.getEffects();
            kind = #combat(combatKind);
        });

    };

    func getNatValue(
        prng : Prng,
        value : ScenarioMetaData.NatValue,
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
        value : ScenarioMetaData.TextValue,
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
        prng_ : Prng,
        playerId : Principal,
        characterHandler : CharacterHandler.Handler,
        userHandler : UserHandler.Handler,
        scenario : Scenario.Scenario,
        scenarioMetaData_ : ScenarioMetaData.ScenarioMetaData,
        creatures : HashMap.HashMap<Text, Creature.Creature>,
        classes : HashMap.HashMap<Text, Class.Class>,
        races : HashMap.HashMap<Text, Race.Race>,
        items : HashMap.HashMap<Text, Item.Item>,
        weapons : HashMap.HashMap<Text, Weapon.Weapon>,
        actions : HashMap.HashMap<Text, Action.Action>,
        logEntries : Buffer.Buffer<Scenario.OutcomeEffect>,
    ) {

        public let prng = prng_;
        public let scenarioMetaData = scenarioMetaData_;

        public func getRandomItemId() : Text {
            let itemIds = items.keys() |> Iter.toArray(_);
            prng.nextArrayElement(itemIds);
        };

        public func getRandomWeaponId() : Text {
            let weaponIds = weapons.keys() |> Iter.toArray(_);
            prng.nextArrayElement(weaponIds);
        };

        public func getAction(actionId : Text, avaiableActionIds : [Text]) : Result.Result<Action.Action, { #notAvailable }> {
            let ?action = actions.get(actionId) else Debug.trap("Action not found: " # actionId);
            if (Array.indexOf(actionId, avaiableActionIds, Text.equal) == null) {
                return #err(#notAvailable);
            };
            #ok(action);
        };

        public func getRandomCharacterActionIds() : [Text] {
            let count = 3; // TODO
            let character = characterHandler.get();

            let allActionIds = Character.getActionIds(character, classes, races, items, weapons);

            prng.shuffleBuffer(allActionIds);

            allActionIds.vals()
            |> IterTools.take(_, count)
            |> Iter.toArray(_);
        };

        public func getCharacter() : Character.Character {
            characterHandler.get();
        };

        public func getRandomCreature(kind : ScenarioMetaData.CombatCreatureKind) : Scenario.CreatureCombatState {
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
            let ?creature = creatures.get(selectedCreatureId) else Debug.trap("Creature not found: " # selectedCreatureId);
            {
                creatureId = selectedCreatureId;
                health = creature.health;
                maxHealth = creature.maxHealth;
                shield = 0;
                statusEffects = [];
                availableActionIds = creature.actionIds;
            };
        };

        public func meetsCondition(condition : ScenarioMetaData.Condition) : Bool {
            let character = characterHandler.get();
            switch (condition) {
                case (#hasGold(amountValue)) {
                    let amount = getNatValue(prng, amountValue, scenario.data);
                    character.gold >= amount;
                };
                case (#hasItem(itemValue)) {
                    let itemId = getTextValue(prng, itemValue, scenario.data);
                    character.inventorySlots.vals()
                    |> IterTools.any(_, func(slot : { itemId : ?Text }) : Bool = slot.itemId == ?itemId);
                };
            };
        };

        public func applyEffect(effect : ScenarioMetaData.Effect) : {
            #alive;
            #dead;
        } {
            switch (effect) {
                case (#damage(amount)) {
                    let damageAmount = getNatValue(prng, amount, scenario.data);
                    switch (damageCharacter(damageAmount)) {
                        case (#alive) ();
                        case (#dead) return #dead;
                    };
                };
                case (#heal(amount)) {
                    heal(getNatValue(prng, amount, scenario.data));
                };
                case (#removeGold(amount)) {
                    ignore removeGold(getNatValue(prng, amount, scenario.data));
                };
                case (#addItem(item)) {
                    switch (item) {
                        case (#random) {
                            // TODO
                        };
                        case (#specific(itemId)) {
                            ignore addItem(getTextValue(prng, itemId, scenario.data));
                        };
                    };
                };
                case (#removeItem(item)) {
                    switch (item) {
                        case (#random) {
                            let itemIdOrEmptyInventory = loseRandomItem();
                            switch (itemIdOrEmptyInventory) {
                                case (null) (); // TODO handle inventory empty messaging?
                                case (?itemId) logEntries.add(#removeItem(itemId));
                            };
                        };
                        case (#specific(specific)) {
                            let itemId = getTextValue(prng, specific, scenario.data);
                            ignore removeItem(itemId, false);
                        };
                    };
                };
                case (#achievement(achievementId)) {
                    switch (userHandler.unlockAchievement(playerId, achievementId)) {
                        case (#ok or #err(#achievementAlreadyUnlocked)) ();
                        case (#err(#userNotFound)) Debug.trap("User not found: " # Principal.toText(playerId));
                        case (#err(#achievementNotFound)) Debug.trap("Achievement not found: " # achievementId);
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

        public func addItem(itemId : Text) : Result.Result<(), { #inventoryFull }> {
            switch (characterHandler.addItem(itemId)) {
                case (#ok) {
                    logEntries.add(#addItem({ itemId = itemId; removedItemId = null }));
                    #ok();
                };
                case (#err(#inventoryFull)) #err(#inventoryFull);
            };
        };

        public func addItemToSlot(itemId : Text, slot : Nat) : Result.Result<{ removedItemId : ?Text }, { #invalidSlot }> {
            switch (characterHandler.addItemToSlot(itemId, slot)) {
                case (#ok({ removedItemId })) {
                    logEntries.add(#addItem({ itemId = itemId; removedItemId }));
                    #ok({ removedItemId });
                };
                case (#err(#invalidSlot)) #err(#invalidSlot);
            };
        };

        public func removeItem(itemId : Text, removeAll : Bool) : Nat {
            let removedCount = characterHandler.removeItem(itemId, removeAll);
            for (i in Iter.range(0, removedCount - 1)) {
                logEntries.add(#removeItem(itemId));
            };
            removedCount;
        };

        public func removeItemBySlot(index : Nat) : Result.Result<{ removedItemId : ?Text }, { #invalidSlot }> {
            switch (characterHandler.removeItemBySlot(index)) {
                case (#ok({ removedItemId = null })) #ok({
                    removedItemId = null;
                });
                case (#ok({ removedItemId = ?itemId })) {
                    logEntries.add(#removeItem(itemId));
                    #ok({ removedItemId = ?itemId });
                };
                case (#err(#invalidSlot)) #err(#invalidSlot);
            };
        };

        public func loseRandomItem() : ?Text {
            let character = characterHandler.get();
            let items = character.inventorySlots.vals()
            |> IterTools.enumerate(_)
            // Only keep the indices of the slots that have an item
            |> IterTools.mapFilter(
                _,
                func((i, slot) : (Nat, Character.InventorySlot)) : ?Nat {
                    if (slot.itemId == null) null else ?i;
                },
            )
            |> Iter.toArray(_);
            if (items.size() < 1) return null;
            let randomItemIndex = prng.nextNat(0, items.size() - 1);
            switch (removeItemBySlot(randomItemIndex)) {
                case (#ok({ removedItemId })) return removedItemId;
                case (#err(#invalidSlot)) Debug.trap("Invalid slot: " # Nat.toText(randomItemIndex));
            };
        };

        public func addGold(amount : Nat) {
            logEntries.add(#goldDelta(amount));
            characterHandler.addGold(amount);
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

        public func swapWeapon(weaponId : Text) {
            let oldWeaponId = characterHandler.swapWeapon(weaponId);
            logEntries.add(#swapWeapon({ weaponId = weaponId; removedWeaponId = oldWeaponId }));
        };

        public func getEffects() : [Scenario.OutcomeEffect] {
            Buffer.toArray(logEntries);
        };
    };
};
