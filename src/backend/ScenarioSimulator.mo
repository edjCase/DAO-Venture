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

module {
    type Prng = PseudoRandomX.PseudoRandomGenerator;

    public type RunStageError = {
        #scenarioComplete;
        #invalidChoice;
        #invalidTarget;
        #targetRequired;
    };

    public type StageChoiceKind = {
        #choice : Text;
        #combat : CombatChoice;
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
            weapons,
            actions,
            logEntries,
        );
        switch (scenario.state) {
            case (#choice(choiceState)) processChoice(choiceState, helper, choice);
            case (#combat(combatState)) processCombat(combatState, helper, choice);
            case (#complete) return #err(#scenarioComplete);
        };

    };

    func processChoice(
        state : Scenario.ChoiceScenarioState,
        helper : Helper,
        choice : StageChoiceKind,
    ) : Result.Result<Scenario.ScenarioStageResult, RunStageError> {
        let #choice(choiceId) = choice else return #err(#invalidChoice);
        if (Array.indexOf(choiceId, state.choiceIds, Text.equal) == null) {
            return #err(#invalidChoice);
        };
        let ?choiceData = Array.find(
            helper.scenarioMetaData.choices,
            func(c : ScenarioMetaData.Choice) : Bool {
                c.id == choiceId;
            },
        ) else Debug.trap("Invalid choice: " # choiceId);

        let ?currentPath = Array.find(
            helper.scenarioMetaData.paths,
            func(p : ScenarioMetaData.OutcomePath) : Bool {
                p.id == choiceData.pathId;
            },
        ) else Debug.trap("Invalid path ID: " # choiceData.pathId);
        helper.log(currentPath.description);

        let kind = switch (currentPath.kind) {
            case (#combat(combat)) startCombat(combat, helper);
            case (#effects(effects)) processPathEffects(currentPath, effects, helper);
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
        #startCombat({
            character = {
                shield = 0;
                statusEffects = [];
                availableActionIds = newActionIds;
            };
            creatures = Buffer.toArray(creatureCombatStats);
        });
    };

    func processPathEffects(
        currentPath : ScenarioMetaData.OutcomePath,
        effects : [ScenarioMetaData.Effect],
        helper : Helper,
    ) : Scenario.ScenarioChoiceResultKind {

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
        #path(nextPathId);
    };

    func processCombat(
        state : Scenario.CombatScenarioState,
        helper : Helper,
        choice : StageChoiceKind,
    ) : Result.Result<Scenario.ScenarioStageResult, RunStageError> {
        let #combat(combatChoice) = choice else return #err(#invalidChoice);
        // Character turn first
        let action = switch (helper.getAction(combatChoice.actionId, state.character.availableActionIds)) {
            case (#ok(action)) action;
            case (#err(#notAvailable)) return #err(#invalidChoice);
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

        let initialCharacterState = helper.getCharacter();
        let characterCombatStats : CombatSimulator.CombatStats = {
            var health = initialCharacterState.health;
            var maxHealth = initialCharacterState.maxHealth;
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
        weapons : HashMap.HashMap<Text, Weapon.Weapon>,
        actions : HashMap.HashMap<Text, Action.Action>,
        logEntries : Buffer.Buffer<Scenario.OutcomeEffect>,
    ) {

        public let prng = prng_;
        public let scenarioMetaData = scenarioMetaData_;

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

            let allActionIds = Buffer.Buffer<Text>(10);

            let ?class_ = classes.get(character.classId) else Debug.trap("Class not found: " # character.classId);
            allActionIds.append(Buffer.fromArray(class_.actionIds));

            let ?race = races.get(character.raceId) else Debug.trap("Race not found: " # character.raceId);
            allActionIds.append(Buffer.fromArray(race.actionIds));

            let ?weapon = weapons.get(character.weaponId) else Debug.trap("Weapon not found: " # character.weaponId);
            allActionIds.append(Buffer.fromArray(weapon.actionIds));

            // TODO?
            // let traitActionIds = Trie.iter(character.traitIds)
            // |> Iter.map<(Text, ()), Iter.Iter<Text>>(
            //     _,
            //     func((traitId, _) : (Text, ())) : Iter.Iter<Text> {
            //         let ?trait = traits.get(traitId) else Debug.trap("Trait not found: " # traitId);
            //         trait.actionIds.vals();
            //     },
            // )
            // |> IterTools.flatten(_);
            // allActionIds.append(Buffer.fromArray(traitActionIds));

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
                    TrieSet.mem(character.itemIds, itemId, Text.hash(itemId), Text.equal);
                };
                case (#hasTrait(traitValue)) {
                    let traitId = getTextValue(prng, traitValue, scenario.data);
                    TrieSet.mem(character.traitIds, traitId, Text.hash(traitId), Text.equal);
                };
            };
        };

        public func applyEffect(effect : ScenarioMetaData.Effect) : {
            #alive;
            #dead;
        } {
            switch (effect) {
                case (#reward) reward();
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

        public func getEffects() : [Scenario.OutcomeEffect] {
            Buffer.toArray(logEntries);
        };
    };
};
