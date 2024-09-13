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
        scenarioMetaData : ScenarioMetaData.ScenarioMetaData;
        creatures : HashMap.HashMap<Text, Creature.Creature>;
        classes : HashMap.HashMap<Text, Class.Class>;
        races : HashMap.HashMap<Text, Race.Race>;
        items : HashMap.HashMap<Text, Item.Item>;
        weapons : HashMap.HashMap<Text, Weapon.Weapon>;
        actions : HashMap.HashMap<Text, Action.Action>;
    };

    public type RunStageData = {
        stageResult : Scenario.ScenarioStageResult;
        nextState : Scenario.ScenarioStateKind;
    };
    public func runStage(
        prng : Prng,
        playerId : Principal,
        userHandler : UserHandler.Handler,
        characterHandler : CharacterHandler.Handler,
        scenario : Scenario.Scenario,
        gameContent : GameContent,
        choice : StageChoiceKind,
    ) : Result.Result<RunStageData, RunStageError> {
        let logEntries = Buffer.Buffer<Scenario.OutcomeEffect>(5);
        let helper = Helper(
            prng,
            playerId,
            characterHandler,
            userHandler,
            gameContent,
            logEntries,
        );
        switch (scenario.state) {
            case (#completed(_)) return #err(#scenarioComplete);
            case (#inProgress(inProgress)) {

                let result : Scenario.ScenarioStageResultKind = switch (inProgress.kind) {
                    case (#choice(choiceState)) switch (processChoice(choiceState, helper, choice)) {
                        case (#ok(result)) #choice(result);
                        case (#err(error)) return #err(error);
                    };
                    case (#combat(combatState)) switch (processCombat(combatState, helper, choice)) {
                        case (#ok(result)) #combat(result);
                        case (#err(error)) return #err(error);
                    };
                    case (#reward(rewardState)) switch (processReward(rewardState, helper, choice)) {
                        case (#ok(result)) #reward(result);
                        case (#err(error)) return #err(error);
                    };
                };

                let character = helper.getCharacter();
                let validPaths = Array.filter(
                    inProgress.nextPathOptions,
                    func(p : ScenarioMetaData.WeightedScenarioPathOption) : Bool {
                        switch (p.condition) {
                            case (null) true;
                            case (?condition) {
                                switch (condition) {
                                    case (#hasGold(goldAmount)) {
                                        character.gold >= goldAmount;
                                    };
                                    case (#hasItem(itemId)) {
                                        character.inventorySlots.vals()
                                        |> IterTools.any(_, func(slot : { itemId : ?Text }) : Bool = slot.itemId == ?itemId);
                                    };
                                };
                            };
                        };
                    },
                );

                let nextState = if (validPaths.size() == 0) {
                    #completed; // No valid paths
                } else {
                    let pathsWithWeights = Array.map<ScenarioMetaData.WeightedScenarioPathOption, (Text, Float)>(
                        validPaths,
                        func(p : ScenarioMetaData.WeightedScenarioPathOption) : (Text, Float) {
                            (p.pathId, p.weight);
                        },
                    );
                    let nextPathId = prng.nextArrayElementWeighted(pathsWithWeights);
                    let ?nextPath = Array.find(
                        gameContent.scenarioMetaData.paths,
                        func(p : ScenarioMetaData.ScenarioPath) : Bool {
                            p.id == nextPathId;
                        },
                    ) else Debug.trap("Path not found: " # nextPathId);

                    let nextState = buildNextState(prng, gameContent, character, nextPath);
                    #inProgress(nextState);
                };
                #ok({
                    stageResult = {
                        effects = helper.getEffects();
                        kind = result;
                    };
                    nextState = nextState;
                });
            };
        };

    };

    public func buildNextState(
        prng : Prng,
        gameContent : GameContent,
        character : Character.Character,
        nextPath : ScenarioMetaData.ScenarioPath,
    ) : Scenario.InProgressScenarioState {

        let kind : Scenario.InProgressScenarioStateKind = switch (nextPath.kind) {
            case (#combat(combat)) {
                let startCombatResult = CombatSimulator.startCombat(
                    prng,
                    nextPath.id,
                    combat,
                    character,
                    gameContent,
                );
                #combat(startCombatResult);
            };
            case (#choice(choice)) {
                let availableChoices = choice.choices.vals()
                // Filter to ones where the character meets the requirement
                |> Iter.filter(
                    _,
                    func(c : ScenarioMetaData.Choice) : Bool = switch (c.requirement) {
                        case (null) true;
                        case (?requirement) ScenarioMetaData.characterMeetsRequirement(requirement, character);
                    },
                )
                |> Iter.map(
                    _,
                    func(c : ScenarioMetaData.Choice) : Scenario.Choice = buildScenarioChoice(c, prng),
                )
                |> Iter.toArray(_);
                #choice({
                    choices = availableChoices;
                });
            };
            case (#reward(reward)) #reward(startReward(prng, reward, gameContent));
        };
        {
            kind = kind;
            nextPathOptions = nextPath.nextPathOptions;
        };
    };

    func buildScenarioChoice(
        choice : ScenarioMetaData.Choice,
        prng : Prng,
    ) : Scenario.Choice {
        let data = Array.map(
            choice.data,
            func(field : ScenarioMetaData.GeneratedDataField) : Scenario.GeneratedDataFieldInstance {
                let value = switch (field.value) {
                    case (#nat({ min; max })) #nat(prng.nextNat(min, max));
                    case (#text(text)) #text(prng.nextArrayElementWeighted(text.options));
                };
                {
                    id = field.id;
                    value = value;
                };
            },
        );
        {
            id = choice.id;
            description = choice.description;
            effects = choice.effects;
            data = data;
        };
    };

    func processReward(
        state : Scenario.RewardScenarioState,
        helper : Helper,
        choice : StageChoiceKind,
    ) : Result.Result<Scenario.ScenarioRewardResult, RunStageError> {
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
        #ok({ kind = kind });
    };

    func processChoice(
        state : Scenario.ChoiceScenarioState,
        helper : Helper,
        choice : StageChoiceKind,
    ) : Result.Result<Scenario.ScenarioChoiceResult, RunStageError> {
        let #choice(choiceId) = choice else return #err(#invalidChoice("Expected scenario choice"));

        let ?choiceData = Array.find(
            state.choices,
            func(c : Scenario.Choice) : Bool {
                c.id == choiceId;
            },
        ) else return #err(#invalidChoice("Choice not found: " # choiceId));

        label f for (effect in choiceData.effects.vals()) {
            switch (helper.applyEffect(effect, choiceData.data)) {
                case (#alive) (); // Continue
                case (#dead) {
                    return #ok({
                        choiceId = choiceData.id;
                        kind = #death;
                    });
                };
            };
        };

        #ok({
            choiceId = choiceData.id;
            kind = #complete;
        });

    };

    func processCombat(
        state : Scenario.CombatScenarioState,
        helper : Helper,
        choice : StageChoiceKind,
    ) : Result.Result<Scenario.ScenarioCombatResult, RunStageError> {
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
                #ok(combatKind);
            };
            case (#err(error)) return #err(error);
        };

    };

    func startReward(
        prng : Prng,
        reward : ScenarioMetaData.RewardPath,
        gameContent : GameContent,
    ) : Scenario.RewardScenarioState {
        let options = switch (reward) {
            case (#random) {
                let itemIds = gameContent.items.keys() |> Iter.toArray(_);
                let itemId = prng.nextArrayElement(itemIds);
                let gold = prng.nextNat(1, 100); // TODO amount
                // TODO ratio
                let reward = if (prng.nextRatio(1, 2)) {
                    let weaponIds = gameContent.weapons.keys() |> Iter.toArray(_);
                    let weaponId = prng.nextArrayElement(weaponIds);
                    #weapon(weaponId);
                } else {
                    #health(prng.nextNat(1, 20)); // TODO amount
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
        { options };
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

        public func getCharacter() : Character.Character {
            characterHandler.get();
        };

        public func applyEffect(effect : ScenarioMetaData.Effect, data : [Scenario.GeneratedDataFieldInstance]) : {
            #alive;
            #dead;
        } {
            switch (effect) {
                case (#damage(amount)) {
                    let damageAmount = getNatValue(prng, amount, data);
                    switch (damageCharacter(damageAmount)) {
                        case (#alive) ();
                        case (#dead) return #dead;
                    };
                };
                case (#heal(amount)) {
                    heal(getNatValue(prng, amount, data));
                };
                case (#removeGold(amount)) {
                    ignore removeGold(getNatValue(prng, amount, data));
                };
                case (#addItem(item)) {
                    switch (item) {
                        case (#random) {
                            // TODO
                        };
                        case (#specific(itemId)) {
                            ignore addItem(getTextValue(prng, itemId, data));
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
                            let itemId = getTextValue(prng, specific, data);
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
