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
import Scenario "models/Scenario";
import Character "models/Character";
import Creature "models/entities/Creature";
import Weapon "models/entities/Weapon";
import CombatSimulator "CombatSimulator";
import ScenarioMetaData "models/entities/ScenarioMetaData";
import Action "models/entities/Action";
import IterTools "mo:itertools/Iter";
import Class "models/entities/Class";
import Race "models/entities/Race";
import Item "models/entities/Item";
import UnlockRequirement "models/UnlockRequirement";

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

    public type Player = {
        id : Principal;
        var achievementIds : [Text];
    };

    public type GameContent = {
        creatures : HashMap.HashMap<Text, Creature.Creature>;
        classes : HashMap.HashMap<Text, Class.Class>;
        races : HashMap.HashMap<Text, Race.Race>;
        items : HashMap.HashMap<Text, Item.Item>;
        weapons : HashMap.HashMap<Text, Weapon.Weapon>;
        actions : HashMap.HashMap<Text, Action.Action>;
        scenarioMetaData : HashMap.HashMap<Text, ScenarioMetaData.ScenarioMetaData>;
    };

    public type NextScenarioState = {
        #updated : Scenario.Scenario;
        #completed : Scenario.CompletedScenario;
        #dead;
    };

    public func initialize(
        prng : Prng,
        player : Player,
        characterHandler : CharacterHandler.Handler,
        gameContent : GameContent,
        scenarioMetaData : ScenarioMetaData.ScenarioMetaData,
    ) : Scenario.Scenario {
        let logEntries = Buffer.Buffer<Scenario.OutcomeEffect>(5);
        let helper = Helper(
            prng,
            player,
            characterHandler,
            gameContent,
            logEntries,
        );

        let nextStateKind = buildNextStage(helper, scenarioMetaData.paths[0]); // Use first path for initial path
        {
            metaDataId = scenarioMetaData.id;
            previousStages = [];
            currentStage = nextStateKind;
        };
    };

    public func runStage(
        prng : Prng,
        player : Player,
        characterHandler : CharacterHandler.Handler,
        scenario : Scenario.Scenario,
        gameContent : GameContent,
        choice : StageChoiceKind,
    ) : Result.Result<NextScenarioState, RunStageError> {
        let logEntries = Buffer.Buffer<Scenario.OutcomeEffect>(5);
        let helper = Helper(
            prng,
            player,
            characterHandler,
            gameContent,
            logEntries,
        );
        let result : Result.Result<(NextKind, Scenario.ScenarioStageResultKind), RunStageError> = switch (scenario.currentStage) {
            case (#choice(choiceState)) processChoice(choiceState, helper, choice);
            case (#combat(combatState)) processCombat(combatState, helper, choice);
            case (#reward(rewardState)) processReward(rewardState, helper, choice);
        };
        let (nextKind, stageResultKind) : (NextKind, Scenario.ScenarioStageResultKind) = switch (result) {
            case (#ok((nextKind, stageResultKind))) (nextKind, stageResultKind);
            case (#err(error)) return #err(error);
        };
        let newStage = { effects = helper.getEffects(); kind = stageResultKind };
        let newStages = Array.append(scenario.previousStages, [newStage]);
        let isDead = helper.getCharacter().health == 0;
        if (isDead) {
            return #ok(#dead);
        };
        let nextStageOrNull = buildNextStageOrComplete(scenario.metaDataId, nextKind, helper);
        switch (nextStageOrNull) {
            case (null) {
                #ok(
                    #completed({
                        metaDataId = scenario.metaDataId;
                        stages = newStages;
                    })
                );
            };
            case (?nextStage) {
                #ok(
                    #updated({
                        metaDataId = scenario.metaDataId;
                        previousStages = newStages;
                        currentStage = nextStage;
                    })
                );
            };
        };

    };

    type NextKind = {
        #nextPath : ScenarioMetaData.NextPathKind;
        #pathInProgress : Scenario.ScenarioStageKind;
        #dead;
    };

    func buildNextStageOrComplete(
        metaDataId : Text,
        nextKind : NextKind,
        helper : Helper,
    ) : ?Scenario.ScenarioStageKind {
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
                        let nexPath = helper.prng.nextArrayElementWeighted(pathsWithWeights);

                        helper.log(nexPath.description);
                        for (effect in nexPath.effects.vals()) {
                            switch (helper.applyEffect(effect)) {
                                case (#alive) ();
                                case (#dead) return null;
                            };
                        };
                        nexPath.pathId;
                    };
                    case (#none) null;
                };
                switch (nextPathId) {
                    case (null) return null;
                    case (?nextPathId) {
                        let ?scenarioMetaData = helper.gameContent.scenarioMetaData.get(metaDataId) else Debug.trap("Scenario meta data not found: " # metaDataId);
                        let ?nextPath = Array.find(
                            scenarioMetaData.paths,
                            func(p : ScenarioMetaData.ScenarioPath) : Bool = p.id == nextPathId,
                        ) else Debug.trap("Path not found: " # nextPathId);
                        ?buildNextStage(helper, nextPath);
                    };
                };
            };
            case (#pathInProgress(inProgress)) ?inProgress;
            case (#dead) null; // TODO handle death
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

    public func buildNextStage(
        helper : Helper,
        path : ScenarioMetaData.ScenarioPath,
    ) : Scenario.ScenarioStageKind {
        let character = helper.getCharacter();
        switch (path.kind) {
            case (#combat(combat)) #combat(
                CombatSimulator.startCombat(
                    helper.prng,
                    combat,
                    character,
                    helper.gameContent,
                )
            );
            case (#choice(choice)) {
                let attributes = helper.calculateAttributes();
                #choice(startChoice(choice, character, attributes, helper.gameContent));
            };
            case (#reward(reward)) #reward(startReward(helper, reward));
        };
    };

    func processChoice(
        state : Scenario.ChoiceScenarioState,
        helper : Helper,
        choice : StageChoiceKind,
    ) : Result.Result<(NextKind, Scenario.ScenarioStageResultKind), RunStageError> {
        let #choice(choiceId) = choice else return #err(#invalidChoice("Expected scenario choice"));

        let ?choiceData = Array.find(
            state.choices,
            func(c : ScenarioMetaData.Choice) : Bool {
                c.id == choiceId;
            },
        ) else return #err(#invalidChoice("Choice not found: " # choiceId));

        func applyEffects() : { #complete; #death } {

            label f for (effect in choiceData.effects.vals()) {
                switch (helper.applyEffect(effect)) {
                    case (#alive) (); // Continue
                    case (#dead) {
                        return #death;
                    };
                };
            };

            #complete;
        };

        let result = applyEffects();

        let nextKind = switch (result) {
            case (#death) #dead;
            case (#complete) {
                let ?chosenChoice = state.choices.vals()
                |> Iter.filter(
                    _,
                    func(c : ScenarioMetaData.Choice) : Bool {
                        c.id == choiceId;
                    },
                )
                |> _.next() else Debug.trap("Choice not found: " # choiceId);
                #nextPath(chosenChoice.nextPath);
            };
        };

        #ok((nextKind, #choice({ choice = choiceData; kind = result })));

    };

    func processCombat(
        state : Scenario.CombatScenarioState,
        helper : Helper,
        choice : StageChoiceKind,
    ) : Result.Result<(NextKind, Scenario.ScenarioStageResultKind), RunStageError> {
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
                let nextKind = switch (combatKind.kind) {
                    case (#victory(_)) #nextPath(state.nextPath);
                    case (#defeat(_)) #dead;
                    case (#inProgress(inProgress)) #pathInProgress(#combat(inProgress));
                };

                #ok((nextKind, #combat(combatKind)));
            };
            case (#err(error)) return #err(error);
        };
    };

    func processReward(
        state : Scenario.RewardScenarioState,
        helper : Helper,
        choice : StageChoiceKind,
    ) : Result.Result<(NextKind, Scenario.ScenarioStageResultKind), RunStageError> {
        let #reward(reward) = choice else return #err(#invalidChoice("Expected reward choice"));
        func validateRewardExists(reward : ScenarioMetaData.RewardKind) : Bool {
            if (reward == state.options.0) return true;
            if (reward == state.options.1) return true;
            if (reward == state.options.2) return true;
            return false;
        };
        let rewardKind = switch (reward) {
            case (#item(item)) #item(item.id);
            case (#gold(gold)) #gold(gold);
            case (#weapon(weaponId)) #weapon(weaponId);
            case (#health(health)) #health(health);
        };
        let true = validateRewardExists(rewardKind) else return #err(#invalidChoice("Reward does not exist"));

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
        #ok((#nextPath(state.nextPath), #reward({ kind = rewardKind })));
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
        helper : Helper,
        reward : ScenarioMetaData.RewardPath,
    ) : Scenario.RewardScenarioState {
        let options = switch (reward.kind) {
            case (#random) {
                let itemIds = helper.gameContent.items.vals()
                |> UnlockRequirement.filterOutLockedEntities<Item.Item>(_, helper.player.achievementIds)
                |> Iter.map(_, func(item : Item.Item) : Text = item.id)
                |> Iter.toArray(_);
                let itemId = helper.prng.nextArrayElement(itemIds);
                let gold = helper.prng.nextNat(1, 101); // TODO amount
                // TODO ratio
                let reward = if (helper.prng.nextRatio(1, 2)) {
                    let weaponIds = helper.gameContent.weapons.vals()
                    |> UnlockRequirement.filterOutLockedEntities<Weapon.Weapon>(_, helper.player.achievementIds)
                    |> Iter.map(_, func(weapon : Weapon.Weapon) : Text = weapon.id)
                    |> Iter.toArray(_);
                    let weaponId = helper.prng.nextArrayElement(weaponIds);
                    #weapon(weaponId);
                } else {
                    #health(helper.prng.nextNat(1, 21)); // TODO amount
                };
                (#item(itemId), #gold(gold), reward);
            };
            case (#specific(specific)) specific;
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
            case (#random(min, max)) prng.nextNat(min, max + 1);
        };
    };

    private class Helper(
        prng_ : Prng,
        player_ : Player,
        characterHandler : CharacterHandler.Handler,
        gameContent_ : GameContent,
        logEntries : Buffer.Buffer<Scenario.OutcomeEffect>,
    ) {

        public let prng = prng_;
        public let gameContent = gameContent_;
        public let player = player_;

        public func getCharacter() : Character.Character {
            characterHandler.get();
        };

        public func calculateAttributes() : Character.CharacterAttributes {
            characterHandler.calculateAttributes(gameContent.weapons, gameContent.items, gameContent.actions);
        };

        public func applyEffect(effect : ScenarioMetaData.PathEffect) : {
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
                case (#addItem(itemId)) {
                    ignore addItem(itemId);
                };
                case (#removeItem(itemId)) {
                    ignore removeItem(itemId, false);
                };
                case (#addItemWithTags(itemTags)) {
                    let potentialItemIds : [Text] = gameContent.items.vals()
                    |> Iter.filter(
                        _,
                        func(item : Item.Item) : Bool = hasAllTags(item, itemTags),
                    )
                    |> UnlockRequirement.filterOutLockedEntities<Item.Item>(_, player.achievementIds)
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
                    player.achievementIds := Array.append(player.achievementIds, [achievementId]);
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
            let randomItemIndex = prng.nextNat(0, items.size());
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
