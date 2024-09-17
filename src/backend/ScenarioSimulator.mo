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
import Int "mo:base/Int";
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
                let (result, nextKind) : (Scenario.ScenarioStageResultKind, NextKind) = switch (inProgress) {
                    case (#choice(choiceState)) {
                        switch (processChoice(choiceState, helper, choice)) {
                            case (#ok(result)) {
                                let nextKind = switch (result.kind) {
                                    case (#death) #dead;
                                    case (#complete) {
                                        let ?chosenChoice = choiceState.choices.vals()
                                        |> Iter.filter(
                                            _,
                                            func(c : ScenarioMetaData.Choice) : Bool {
                                                c.id == result.choice.id;
                                            },
                                        )
                                        |> _.next() else Debug.trap("Choice not found: " # result.choice.id);
                                        #nextPath(chosenChoice.nextPath);
                                    };
                                };
                                (#choice(result), nextKind);
                            };
                            case (#err(error)) return #err(error);
                        };
                    };
                    case (#combat(combatState)) {
                        switch (processCombat(combatState, helper, choice)) {
                            case (#ok(result)) {
                                let nextKind = switch (result.kind) {
                                    case (#victory(_)) #nextPath(combatState.nextPath);
                                    case (#defeat(_)) #dead;
                                    case (#inProgress(_)) #pathInProgress;
                                };
                                (#combat(result), nextKind);
                            };
                            case (#err(error)) return #err(error);
                        };
                    };
                    case (#reward(rewardState)) {
                        switch (processReward(rewardState, helper, choice)) {
                            case (#ok(result)) (#reward(result), #nextPath(rewardState.nextPath));
                            case (#err(error)) return #err(error);
                        };
                    };
                };

                let nextState : Scenario.ScenarioStateKind = buildNextState(prng, gameContent, nextKind, helper, inProgress);
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

    type NextKind = {
        #nextPath : ScenarioMetaData.NextPathKind;
        #pathInProgress;
        #dead;
    };

    func buildNextState(
        prng : Prng,
        gameContent : GameContent,
        nextKind : NextKind,
        helper : Helper,
        currentState : Scenario.InProgressScenarioStateKind,
    ) : Scenario.ScenarioStateKind {
        switch (nextKind) {
            case (#nextPath(nextPathKind)) {
                let nextPathId : ?Text = switch (nextPathKind) {
                    case (#single(pathId)) ?pathId;
                    case (#multi(options)) {
                        let pathsWithWeights = Array.map<ScenarioMetaData.WeightedScenarioPathOption, (ScenarioMetaData.WeightedScenarioPathOption, Float)>(
                            options,
                            func(p : ScenarioMetaData.WeightedScenarioPathOption) : (ScenarioMetaData.WeightedScenarioPathOption, Float) {
                                let attributes = helper.calculateAttributes();
                                let weight = calculateWeight(p.weight, attributes);
                                (p, weight);
                            },
                        );
                        let nexPath = prng.nextArrayElementWeighted(pathsWithWeights);

                        helper.log(nexPath.description);
                        for (effect in nexPath.effects.vals()) {
                            switch (helper.applyEffect(effect)) {
                                case (#alive) ();
                                case (#dead) return #completed;
                            };
                        };
                        nexPath.pathId;
                    };
                    case (#none) null;
                };
                switch (nextPathId) {
                    case (null) #completed;
                    case (?nextPathId) {
                        let ?nextPath = Array.find(
                            gameContent.scenarioMetaData.paths,
                            func(p : ScenarioMetaData.ScenarioPath) : Bool = p.id == nextPathId,
                        ) else Debug.trap("Path not found: " # nextPathId);
                        let character = helper.getCharacter();
                        let attributes = helper.calculateAttributes();
                        let nextState = buildNextInProgressState(prng, gameContent, character, attributes, nextPath);
                        #inProgress(nextState);
                    };
                };
            };
            case (#pathInProgress) #inProgress(currentState);
            case (#dead) #completed; // TODO handle death
        };
    };

    func calculateWeight(
        weight : ScenarioMetaData.OptionWeight,
        attributes : Character.CharacterAttributes,
    ) : Float {
        let baseWeight = weight.value;
        switch (weight.kind) {
            case (#raw) baseWeight;
            case (#attributeScaled(attribute)) {
                let k = 1.5; // Adjust this for desired steepness
                let attributeValue : Int = switch (attribute) {
                    case (#strength) attributes.strength;
                    case (#dexterity) attributes.dexterity;
                    case (#wisdom) attributes.wisdom;
                    case (#charisma) attributes.charisma;
                };
                // Scale the base weight by the attribute value
                // using a sigmoid curve
                let weight = baseWeight * (1 / (1 + Float.exp(-k * Float.fromInt(attributeValue))));
                Float.max(0, weight); // Ensure the weight is not negative
            };
        };
    };

    public func buildNextInProgressState(
        prng : Prng,
        gameContent : GameContent,
        character : Character.Character,
        attributes : Character.CharacterAttributes,
        path : ScenarioMetaData.ScenarioPath,
    ) : Scenario.InProgressScenarioStateKind {

        switch (path.kind) {
            case (#combat(combat)) #combat(
                CombatSimulator.startCombat(
                    prng,
                    combat,
                    character,
                    gameContent,
                )
            );
            case (#choice(choice)) #choice(startChoice(choice, character, attributes, gameContent));
            case (#reward(reward)) #reward(startReward(prng, reward, gameContent));
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
            func(c : ScenarioMetaData.Choice) : Bool {
                c.id == choiceId;
            },
        ) else return #err(#invalidChoice("Choice not found: " # choiceId));

        label f for (effect in choiceData.effects.vals()) {
            switch (helper.applyEffect(effect)) {
                case (#alive) (); // Continue
                case (#dead) {
                    return #ok({
                        choice = choiceData;
                        kind = #death;
                    });
                };
            };
        };

        #ok({
            choice = choiceData;
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

    func startChoice(
        choice : ScenarioMetaData.ChoicePath,
        character : Character.Character,
        attributes : Character.CharacterAttributes,
        gameContent : GameContent,
    ) : Scenario.ChoiceScenarioState {
        let availableChoices = choice.choices.vals()
        // Filter to ones where the character meets the requirement
        |> Iter.filter(
            _,
            func(c : ScenarioMetaData.Choice) : Bool = switch (c.requirement) {
                case (null) true;
                case (?requirement) ScenarioMetaData.characterMeetsRequirement(requirement, character, gameContent.items, attributes);
            },
        )
        |> Iter.toArray(_);
        { choices = availableChoices };
    };

    func startReward(
        prng : Prng,
        reward : ScenarioMetaData.RewardPath,
        gameContent : GameContent,
    ) : Scenario.RewardScenarioState {
        let options = switch (reward.kind) {
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
        {
            options = options;
            nextPath = reward.nextPath;
        };
    };

    func getNatValue(
        prng : Prng,
        value : ScenarioMetaData.NatValue,
    ) : Nat {
        switch (value) {
            case (#raw(n)) n;
            case (#random(min, max)) prng.nextNat(min, max);
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

        public func calculateAttributes() : Character.CharacterAttributes {
            characterHandler.calculateAttributes(gameContent.weapons, gameContent.items, gameContent.actions);
        };

        public func applyEffect(effect : ScenarioMetaData.Effect) : {
            #alive;
            #dead;
        } {
            func hasAllTags(item : Item.Item, tags : [Text]) : Bool {
                IterTools.all(tags.vals(), func(tag : Text) : Bool = Array.find(item.tags, func(t : Text) : Bool = t == tag) != null);
            };
            switch (effect) {
                case (#damage(amount)) {
                    let damageAmount = getNatValue(prng, amount);
                    switch (damageCharacter(damageAmount)) {
                        case (#alive) ();
                        case (#dead) return #dead;
                    };
                };
                case (#heal(amount)) {
                    heal(getNatValue(prng, amount));
                };
                case (#removeGold(amount)) {
                    ignore removeGold(getNatValue(prng, amount));
                };
                case (#addItemWithTags(itemTags)) {
                    let potentialItemIds : [Text] = gameContent.items.vals()
                    |> Iter.filter(
                        _,
                        func(item : Item.Item) : Bool = hasAllTags(item, itemTags),
                    )
                    |> Iter.map(_, func(item : Item.Item) : Text = item.id)
                    |> Iter.toArray(_);
                    if (potentialItemIds.size() < 1) {
                        Debug.trap("No item found with all tags: " # debug_show (itemTags));
                    };
                    let itemId = prng.nextArrayElement(potentialItemIds);
                    ignore addItem(itemId);
                };
                case (#removeItemWithTags(itemTags)) {
                    let itemIds = characterHandler.get().inventorySlots.vals()
                    |> Iter.map(_, func(slot : Character.InventorySlot) : ?Text = slot.itemId)
                    |> IterTools.mapFilter(
                        _,
                        func(itemId : ?Text) : ?Text {
                            switch (itemId) {
                                case (null) null;
                                case (?itemId) {
                                    let ?item = gameContent.items.get(itemId) else Debug.trap("Item not found: " # itemId);
                                    if (hasAllTags(item, itemTags)) {
                                        ?itemId;
                                    } else {
                                        null;
                                    };
                                };
                            };
                        },
                    )
                    |> Iter.toArray(_);
                    if (itemIds.size() > 0) {
                        let itemId = prng.nextArrayElement(itemIds);
                        ignore removeItem(itemId, true);
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
