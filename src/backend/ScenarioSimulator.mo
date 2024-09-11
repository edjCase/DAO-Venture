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
import CharacterHandler "handlers/CharacterHandler";
import Scenario "models/entities/Scenario";
import Character "models/Character";
import UserHandler "handlers/UserHandler";
import Creature "models/entities/Creature";
import Weapon "models/entities/Weapon";
import CombatSimulator "CombatSimulator";
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
        #combat : CombatSimulator.CombatChoice;
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

    public type GameContent = {
        scenario : Scenario.Scenario;
        scenarioMetaData : ScenarioMetaData.ScenarioMetaData;
        creatures : HashMap.HashMap<Text, Creature.Creature>;
        classes : HashMap.HashMap<Text, Class.Class>;
        races : HashMap.HashMap<Text, Race.Race>;
        items : HashMap.HashMap<Text, Item.Item>;
        weapons : HashMap.HashMap<Text, Weapon.Weapon>;
        actions : HashMap.HashMap<Text, Action.Action>;
    };

    public func runStage(
        prng : Prng,
        playerId : Principal,
        userHandler : UserHandler.Handler,
        characterHandler : CharacterHandler.Handler,
        gameContent : GameContent,
        choice : StageChoiceKind,
    ) : Result.Result<Scenario.ScenarioStageResult, RunStageError> {
        let logEntries = Buffer.Buffer<Scenario.OutcomeEffect>(5);
        let helper = Helper(
            prng,
            playerId,
            characterHandler,
            userHandler,
            gameContent,
            logEntries,
        );
        switch (gameContent.scenario.state) {
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
            helper.gameContent.scenarioMetaData.choices,
            func(c : ScenarioMetaData.Choice) : Bool {
                c.id == choiceId;
            },
        ) else Debug.trap("Invalid choice: " # choiceId);

        var currentPathId = choiceData.pathId;

        let kind = label l : Scenario.ScenarioChoiceResultKind loop {

            let ?currentPath = Array.find(
                helper.gameContent.scenarioMetaData.paths,
                func(p : ScenarioMetaData.OutcomePath) : Bool {
                    p.id == currentPathId;
                },
            ) else Debug.trap("Invalid path ID: " # choiceData.pathId);
            helper.log(currentPath.description);

            switch (currentPath.kind) {
                case (#combat(combat)) {
                    let startCombatResult = CombatSimulator.startCombat(
                        helper.prng,
                        combat,
                        helper.getCharacter(),
                        helper.gameContent,
                    );
                    break l(startCombatResult);
                };
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
        let combatResult = CombatSimulator.run(
            state,
            combatChoice,
            helper.prng,
            helper.getCharacter(),
            helper.gameContent,
        );
        switch (combatResult) {
            case (#ok(combatKind)) {
                let newHealth = switch (combatKind.kind) {
                    case (#victory(victory)) victory.characterHealth;
                    case (#defeat(_)) 0;
                    case (#inProgress(combatState)) combatState.character.health;
                };
                helper.setCharacterHealth(newHealth);
                #ok({
                    effects = helper.getEffects();
                    kind = #combat(combatKind);
                });
            };
            case (#err(error)) return #err(error);
        };

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
        gameContent_ : GameContent,
        logEntries : Buffer.Buffer<Scenario.OutcomeEffect>,
    ) {

        public let prng = prng_;
        public let gameContent = gameContent_;

        public func getRandomItemId() : Text {
            let itemIds = gameContent.items.keys() |> Iter.toArray(_);
            prng.nextArrayElement(itemIds);
        };

        public func getRandomWeaponId() : Text {
            let weaponIds = gameContent.weapons.keys() |> Iter.toArray(_);
            prng.nextArrayElement(weaponIds);
        };

        public func getCharacter() : Character.Character {
            characterHandler.get();
        };

        public func meetsCondition(condition : ScenarioMetaData.Condition) : Bool {
            let character = characterHandler.get();
            switch (condition) {
                case (#hasGold(amountValue)) {
                    let amount = getNatValue(prng, amountValue, gameContent.scenario.data);
                    character.gold >= amount;
                };
                case (#hasItem(itemValue)) {
                    let itemId = getTextValue(prng, itemValue, gameContent.scenario.data);
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
                    let damageAmount = getNatValue(prng, amount, gameContent.scenario.data);
                    switch (damageCharacter(damageAmount)) {
                        case (#alive) ();
                        case (#dead) return #dead;
                    };
                };
                case (#heal(amount)) {
                    heal(getNatValue(prng, amount, gameContent.scenario.data));
                };
                case (#removeGold(amount)) {
                    ignore removeGold(getNatValue(prng, amount, gameContent.scenario.data));
                };
                case (#addItem(item)) {
                    switch (item) {
                        case (#random) {
                            // TODO
                        };
                        case (#specific(itemId)) {
                            ignore addItem(getTextValue(prng, itemId, gameContent.scenario.data));
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
                            let itemId = getTextValue(prng, specific, gameContent.scenario.data);
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
