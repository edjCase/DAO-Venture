import CharacterHandler "CharacterHandler";
import PseudoRandomX "mo:xtended-random/PseudoRandomX";
import Debug "mo:base/Debug";
import Principal "mo:base/Principal";
import Result "mo:base/Result";
import Nat32 "mo:base/Nat32";
import Iter "mo:base/Iter";
import Time "mo:base/Time";
import HashMap "mo:base/HashMap";
import Text "mo:base/Text";
import Nat "mo:base/Nat";
import Array "mo:base/Array";
import TrieSet "mo:base/TrieSet";
import Int "mo:base/Int";
import Order "mo:base/Order";
import Scenario "../models/entities/Scenario";
import Character "../models/Character";
import IterTools "mo:itertools/Iter";
import CharacterGenerator "../CharacterGenerator";
import ScenarioSimulator "../ScenarioSimulator";
import Item "../models/entities/Item";
import Class "../models/entities/Class";
import Race "../models/entities/Race";
import Image "../models/Image";
import Zone "../models/entities/Zone";
import Achievement "../models/entities/Achievement";
import UserHandler "UserHandler";
import Creature "../models/entities/Creature";
import Weapon "../models/entities/Weapon";
import CommonTypes "../CommonTypes";
import ScenarioMetaData "../models/entities/ScenarioMetaData";
import Action "../models/entities/Action";

module {
    type Prng = PseudoRandomX.PseudoRandomGenerator;

    public type StableData = {
        playerDataList : [PlayerData];
        classes : [Class.Class];
        races : [Race.Race];
        scenarioMetaDataList : [ScenarioMetaData.ScenarioMetaData];
        items : [Item.Item];
        images : [Image.Image];
        zones : [Zone.Zone];
        achievements : [Achievement.Achievement];
        creatures : [Creature.Creature];
        weapons : [Weapon.Weapon];
        actions : [Action.Action];
    };

    public type PlayerData = {
        id : Principal;
        activeGame : ?GameInstance;
        completedGames : [CompletedGameWithMetaData];
    };

    public type GameInstance = {
        id : Nat;
        startTime : Time.Time;
        state : GameInstanceState;
    };

    public type GameInstanceState = {
        #starting : StartingData;
        #inProgress : InProgressData;
        #completed : CompletedData;
    };

    public type StartingData = {
        characterOptions : [Character.Character];
    };

    public type InProgressData = {
        scenarios : [Scenario.Scenario];
        character : Character.Character;
        zoneIds : [Text]; // Last is current zone
        turnKind : TurnKind;
    };

    public type TurnKind = {
        #scenario : ScenarioTurn;
        #combat : CombatTurn;
    };

    public type ScenarioTurn = {
        scenarioId : Nat;
    };

    public type CombatTurn = {

    };

    public type CompletedData = {
        endTime : Time.Time;
        character : Character.Character;
        victory : Bool;
    };

    public type GameWithMetaData = {
        id : Nat;
        playerId : Principal;
        startTime : Time.Time;
        state : GameStateWithMetaData;
    };

    public type GameStateWithMetaData = {
        #starting : StartingGameStateWithMetaData;
        #inProgress : InProgressGameStateWithMetaData;
        #completed : CompletedGameStateWithMetaData;
    };

    public type StartingGameStateWithMetaData = {
        characterOptions : [CharacterWithMetaData];
    };

    public type InProgressGameStateWithMetaData = {
        character : CharacterWithMetaData;
        turnKind : TurnKind;
    };

    public type CompletedGameStateWithMetaData = {
        character : CharacterWithMetaData;
        endTime : Time.Time;
        victory : Bool;
    };

    public type CompletedGameWithMetaData = CompletedGameStateWithMetaData and {
        id : Nat;
        playerId : Principal;
        startTime : Time.Time;
    };

    public type CharacterWithMetaData = {
        health : Nat;
        maxHealth : Nat;
        gold : Nat;
        class_ : Class.Class;
        race : Race.Race;
        actions : [CharacterActionWithMetaData];
        inventorySlots : [InventorySlotWithMetaData];
        weapon : Weapon.Weapon;
        attributes : Character.CharacterAttributes;
    };

    public type CharacterActionWithMetaData = {
        action : Action.Action;
        kind : Character.CharacterActionKind;
    };

    public type InventorySlotWithMetaData = {
        item : ?Item.Item;
    };

    public type ScenarioWithMetaData = Scenario.Scenario and {
        metaData : ScenarioMetaData.ScenarioMetaData;
    };

    public type CreateGameError = {
        #alreadyInitialized;
        #noClasses;
        #noRaces;
        #noScenarios;
        #noItems;
        #noImages;
        #noZones;
        #noScenariosForZone : Text;
        #noCreatures;
        #noCreaturesForZone : Text;
        #noWeapons;
        #notAuthenticated;
    };

    public class Handler(data : StableData) {

        private func toTextHashMap<T <: { id : Text }>(array : [T]) : HashMap.HashMap<Text, T> {
            array.vals()
            |> Iter.map<T, (Text, T)>(
                _,
                func(item : T) : (Text, T) = (item.id, item),
            )
            |> HashMap.fromIter<Text, T>(_, array.size(), Text.equal, Text.hash);
        };

        let classes = toTextHashMap<Class.Class>(data.classes);

        let races = toTextHashMap<Race.Race>(data.races);

        let scenarioMetaDataList = toTextHashMap<ScenarioMetaData.ScenarioMetaData>(data.scenarioMetaDataList);

        let items = toTextHashMap<Item.Item>(data.items);

        let images = toTextHashMap<Image.Image>(data.images);

        let zones = toTextHashMap<Zone.Zone>(data.zones);

        let achievements = toTextHashMap<Achievement.Achievement>(data.achievements);

        let creatures = toTextHashMap<Creature.Creature>(data.creatures);

        let weapons = toTextHashMap<Weapon.Weapon>(data.weapons);

        let actions = toTextHashMap<Action.Action>(data.actions);

        var playerDataList : HashMap.HashMap<Principal, PlayerData> = toHashMap<Principal, PlayerData>(
            data.playerDataList,
            func(d : PlayerData) : (Principal, PlayerData) = (d.id, d),
            Principal.hash,
            Principal.equal,
        );

        public func toStableData() : StableData {
            {
                playerDataList = playerDataList.vals() |> Iter.toArray(_);
                classes = Iter.toArray(classes.vals());
                races = Iter.toArray(races.vals());
                scenarioMetaDataList = Iter.toArray(scenarioMetaDataList.vals());
                items = Iter.toArray(items.vals());
                images = Iter.toArray(images.vals());
                zones = Iter.toArray(zones.vals());
                achievements = Iter.toArray(achievements.vals());
                creatures = Iter.toArray(creatures.vals());
                weapons = Iter.toArray(weapons.vals());
                actions = Iter.toArray(actions.vals());
            };
        };

        public func createInstance(
            prng : Prng,
            playerId : Principal,
        ) : Result.Result<(), CreateGameError> {
            if (classes.size() == 0) {
                return #err(#noClasses);
            };
            if (races.size() == 0) {
                return #err(#noRaces);
            };
            if (scenarioMetaDataList.size() == 0) {
                return #err(#noScenarios);
            };
            if (items.size() == 0) {
                return #err(#noItems);
            };
            if (images.size() == 0) {
                return #err(#noImages);
            };
            if (zones.size() == 0) {
                return #err(#noZones);
            };
            if (creatures.size() == 0) {
                return #err(#noCreatures);
            };
            if (weapons.size() == 0) {
                return #err(#noWeapons);
            };
            for (zone in zones.vals()) {
                if (
                    not IterTools.any(
                        scenarioMetaDataList.vals(),
                        func(scenario : ScenarioMetaData.ScenarioMetaData) : Bool = switch (scenario.location) {
                            case (#common) false;
                            case (#zoneIds(zoneIds)) Array.find(zoneIds, func(id : Text) : Bool = id == zone.id) != null;
                        },
                    )
                ) {
                    return #err(#noScenariosForZone(zone.id));
                };
                if (
                    not IterTools.any(
                        creatures.vals(),
                        func(creature : Creature.Creature) : Bool = switch (creature.location) {
                            case (#common) false;
                            case (#zoneIds(zoneIds)) Array.find(zoneIds, func(id : Text) : Bool = id == zone.id) != null;
                        },
                    )
                ) {
                    return #err(#noCreaturesForZone(zone.id));
                };
            };

            let playerDataInstance : PlayerData = switch (playerDataList.get(playerId)) {
                case (null) {
                    // Create new
                    {
                        id = playerId;
                        activeGame = null;
                        completedGames = [];
                    };
                };
                case (?data) {
                    // End current game if exists
                    // TODO make this more explicit to end current game?
                    switch (abandonAndArchiveInternal(data)) {
                        case (#ok(updatedData)) updatedData;
                        case (#err(#noActiveGame)) data; // No active game, no changes
                    };
                };
            };

            let classArray = Iter.toArray(classes.vals());
            let raceArray = Iter.toArray(races.vals());
            let characterOptions = IterTools.range(0, 4)
            |> Iter.map(
                _,
                func(_ : Nat) : Character.Character {
                    let class_ = prng.nextArrayElement(classArray);
                    let race = prng.nextArrayElement(raceArray);
                    CharacterGenerator.generate(class_, race);
                },
            )
            |> Iter.toArray(_);

            playerDataList.put(
                playerId,
                {
                    playerDataInstance with
                    activeGame = ?{
                        id = playerDataInstance.completedGames.size(); // TODO?
                        playerId = playerId;
                        startTime = Time.now();
                        state = #starting({
                            characterOptions = characterOptions;
                        });
                    } : ?GameInstance;
                },
            );

            #ok;
        };

        public func abandon(
            playerId : Principal
        ) : Result.Result<(), { #noActiveGame }> {
            let ?playerData = playerDataList.get(playerId) else return #err(#noActiveGame);
            switch (abandonAndArchiveInternal(playerData)) {
                case (#ok(_)) #ok;
                case (#err(#noActiveGame)) return #err(#noActiveGame);
            };
        };

        private func abandonAndArchiveInternal(playerData : PlayerData) : Result.Result<PlayerData, { #noActiveGame }> {
            let ?activeGame = playerData.activeGame else return #err(#noActiveGame);
            let completedGameState : CompletedGameStateWithMetaData = switch (activeGame.state) {
                case (#starting(starting)) {
                    {
                        turns = 0;
                        character = toCharacterWithMetaData(starting.characterOptions[0]); // TODO is it ok to just take the first one?
                        endTime = Time.now();
                        victory = false;
                    };
                };
                case (#inProgress(inProgress)) {
                    {
                        character = toCharacterWithMetaData(inProgress.character);
                        endTime = Time.now();
                        victory = false;
                    };
                };
                case (#completed(completed)) {
                    {
                        character = toCharacterWithMetaData(completed.character);
                        endTime = completed.endTime;
                        victory = completed.victory;
                    };
                };
            };

            let completedGames : [CompletedGameWithMetaData] = Array.append(
                playerData.completedGames,
                [
                    {
                        completedGameState with
                        id = activeGame.id;
                        playerId = playerData.id;
                        startTime = activeGame.startTime;
                    } : CompletedGameWithMetaData
                ],
            );
            let updatedPlayerData = {
                id = playerData.id;
                activeGame = null;
                completedGames = completedGames;
            };
            playerDataList.put(playerData.id, updatedPlayerData);
            #ok(updatedPlayerData);
        };

        public func getScenario(playerId : Principal, scenarioId : Nat) : Result.Result<ScenarioWithMetaData, { #gameNotFound; #gameNotActive; #notFound }> {
            let ?playerData = playerDataList.get(playerId) else return #err(#gameNotFound);
            let ?instance = playerData.activeGame else return #err(#gameNotActive);
            let #inProgress({ scenarios }) = instance.state else return #err(#gameNotActive);
            let ?scenario = Array.find(scenarios, func(s : Scenario.Scenario) : Bool = s.id == scenarioId) else return #err(#notFound);
            #ok(mapScenario(scenario));
        };

        public func getScenarios(playerId : Principal) : Result.Result<[ScenarioWithMetaData], { #gameNotFound; #gameNotActive }> {
            let ?playerData = playerDataList.get(playerId) else return #err(#gameNotFound);
            let ?instance = playerData.activeGame else return #err(#gameNotActive);
            let #inProgress({ scenarios }) = instance.state else return #err(#gameNotActive);
            let scenariosWithMetaData = scenarios.vals()
            |> Iter.map<Scenario.Scenario, ScenarioWithMetaData>(
                _,
                mapScenario,
            )
            |> Iter.toArray(_);
            #ok(scenariosWithMetaData);
        };

        public func startGame<system>(
            prng : Prng,
            playerId : Principal,
            characterIndex : Nat,
        ) : Result.Result<(), { #gameNotFound; #alreadyStarted; #invalidCharacterId }> {
            let ?playerData = playerDataList.get(playerId) else return #err(#gameNotFound);
            let ?instance = playerData.activeGame else return #err(#gameNotFound);
            let #starting(starting) = instance.state else return #err(#alreadyStarted);
            if (characterIndex >= starting.characterOptions.size()) return #err(#invalidCharacterId);
            let character = starting.characterOptions[characterIndex];

            let zoneId = prng.nextArrayElement(zones.vals() |> Iter.toArray(_)).id;
            let scenarioId = 0; // TODO?

            let scenario : Scenario.Scenario = {
                generateScenario(prng, zoneId, character) with
                id = scenarioId;
            };
            let turnKind = #scenario({ scenarioId });
            playerDataList.put(
                playerId,
                {
                    playerData with
                    activeGame = ?{
                        instance with
                        state = #inProgress(
                            {
                                zoneIds = [zoneId];
                                character = character;
                                scenarios = [scenario];
                                turnKind = turnKind;
                            } : InProgressData
                        );
                    } : ?GameInstance
                },
            );
            #ok;
        };

        public func selectScenarioChoice(
            prng : Prng,
            playerId : Principal,
            userHandler : UserHandler.Handler,
            choice : ScenarioSimulator.StageChoiceKind,
        ) : Result.Result<(), { #gameNotFound; #gameNotActive; #invalidChoice : Text; #notScenarioTurn; #invalidTarget; #targetRequired }> {
            let ?playerData = playerDataList.get(playerId) else return #err(#gameNotFound);
            let ?instance = playerData.activeGame else return #err(#gameNotActive);
            let #inProgress(inProgressInstance) = instance.state else return #err(#gameNotActive);

            let #scenario({ scenarioId }) = inProgressInstance.turnKind else return #err(#notScenarioTurn);
            let ?scenario = Array.find(
                inProgressInstance.scenarios,
                func(s : Scenario.Scenario) : Bool = s.id == scenarioId,
            ) else Debug.trap("Scenario not found: " # Nat.toText(scenarioId));
            let ?scenarioMetaData = scenarioMetaDataList.get(scenario.metaDataId) else Debug.trap("Scenario meta data not found: " # scenario.metaDataId);

            let characterHandler = CharacterHandler.Handler(inProgressInstance.character);

            let gameContent : ScenarioSimulator.GameContent = {
                scenarioMetaData = scenarioMetaData;
                creatures = creatures;
                classes = classes;
                races = races;
                items = items;
                weapons = weapons;
                actions = actions;
            };

            let runStageData : ScenarioSimulator.RunStageData = switch (
                ScenarioSimulator.runStage(
                    prng,
                    playerId,
                    userHandler,
                    characterHandler,
                    scenario,
                    gameContent,
                    choice,
                )
            ) {
                case (#err(#scenarioComplete)) Debug.trap("Failed to process choice: Scenario complete");
                case (#err(#invalidChoice(invalidChoice))) return #err(#invalidChoice(invalidChoice));
                case (#err(#invalidTarget)) return #err(#invalidTarget);
                case (#err(#targetRequired)) return #err(#targetRequired);
                case (#ok(result)) result;
            };
            let updatedScenario : Scenario.Scenario = {
                scenario with
                previousStages = Array.append(scenario.previousStages, [runStageData.stageResult]);
                state = runStageData.nextState;
            };
            let thawedScenarios = Array.thaw<Scenario.Scenario>(inProgressInstance.scenarios);
            thawedScenarios[inProgressInstance.scenarios.size() - 1] := updatedScenario;
            let updatedScenarios = Array.freeze(thawedScenarios);

            let updatedInProgressState : InProgressData = {
                inProgressInstance with
                character = characterHandler.get();
                scenarios = updatedScenarios;
            };
            let updatedInstance = {
                instance with
                state = #inProgress(updatedInProgressState);
            };
            let isDead = characterHandler.get().health <= 0;
            let updatedGame : GameInstance = if (isDead) {
                {
                    updatedInstance with
                    state = #completed({
                        endTime = Time.now();
                        character = updatedInProgressState.character;
                        victory = false;
                    });
                };
            } else {
                switch (updatedScenario.state) {
                    case (#inProgress(_)) updatedInstance; // Continue
                    case (#completed) {
                        switch (nextScenarioOrEnd(prng, updatedInProgressState)) {
                            case (?updatedInProgressState) {
                                {
                                    updatedInstance with
                                    state = #inProgress(updatedInProgressState);
                                };
                            };
                            case (null) {
                                {
                                    updatedInstance with
                                    state = #completed({
                                        endTime = Time.now();
                                        character = updatedInProgressState.character;
                                        victory = true;
                                    });
                                };
                            };
                        };
                    };
                };
            };
            playerDataList.put(
                playerId,
                {
                    playerData with
                    activeGame = ?updatedGame;
                },
            );
            #ok;
        };

        public func getActiveInstance(playerId : Principal) : ?GameWithMetaData {
            let ?playerData = playerDataList.get(playerId) else return null;
            let ?instance = playerData.activeGame else return null;
            ?toInstanceWithMetaData(playerId, instance);
        };

        public func getCompletedGames(
            playerId : Principal,
            offset : Nat,
            count : Nat,
        ) : CommonTypes.PagedResult<CompletedGameWithMetaData> {

            let ?playerData = playerDataList.get(playerId) else return {
                data = [];
                offset = 0;
                count = 0;
                totalCount = 0;
            };
            let totalSize = playerData.completedGames.size();
            let data = playerData.completedGames.vals()
            |> IterTools.sort(
                _,
                func(a : CompletedGameWithMetaData, b : CompletedGameWithMetaData) : Order.Order = Int.compare(b.startTime, a.startTime),
            )
            |> IterTools.skip(_, offset)
            |> IterTools.take(_, count)
            |> Iter.toArray(_);
            {
                data = data;
                offset = offset;
                count = count;
                totalCount = totalSize;
            };
        };

        public func addOrUpdateItem(item : Item.Item) : Result.Result<(), { #invalid : [Text] }> {
            switch (validateItem(item)) {
                case (#err(errors)) return #err(#invalid(errors));
                case (#ok) ();
            };
            Debug.print("Adding item: " # item.id);
            items.put(item.id, item);
            #ok;
        };

        public func validateItem(item : Item.Item) : Result.Result<(), [Text]> {
            Item.validate(item, actions, achievements);
        };

        public func addOrUpdateRace(race : Race.Race) : Result.Result<(), { #invalid : [Text] }> {
            switch (validateRace(race)) {
                case (#err(errors)) return #err(#invalid(errors));
                case (#ok) ();
            };
            Debug.print("Adding race: " # race.id);
            races.put(race.id, race);
            #ok;
        };

        public func validateRace(race : Race.Race) : Result.Result<(), [Text]> {
            Race.validate(race, items, actions, achievements);
        };

        public func addOrUpdateClass(class_ : Class.Class) : Result.Result<(), { #invalid : [Text] }> {
            switch (validateClass(class_)) {
                case (#err(errors)) return #err(#invalid(errors));
                case (#ok) ();
            };
            Debug.print("Adding class: " # class_.id);
            classes.put(class_.id, class_);
            #ok;
        };

        public func validateClass(class_ : Class.Class) : Result.Result<(), [Text]> {
            Class.validate(class_, items, actions, achievements);
        };

        public func addOrUpdateScenarioMetaData(scenario : ScenarioMetaData.ScenarioMetaData) : Result.Result<(), { #invalid : [Text] }> {
            switch (validateScenarioMetaData(scenario)) {
                case (#err(errors)) return #err(#invalid(errors));
                case (#ok) ();
            };
            Debug.print("Adding scenario meta data: " # scenario.id);
            scenarioMetaDataList.put(scenario.id, scenario);
            #ok;
        };

        public func validateScenarioMetaData(scenario : ScenarioMetaData.ScenarioMetaData) : Result.Result<(), [Text]> {
            ScenarioMetaData.validate(scenario, items, images, zones, achievements, creatures);
        };

        public func addOrUpdateZone(zone : Zone.Zone) : Result.Result<(), { #invalid : [Text] }> {
            switch (validateZone(zone)) {
                case (#err(errors)) return #err(#invalid(errors));
                case (#ok) ();
            };
            Debug.print("Adding zone: " # zone.id);
            zones.put(zone.id, zone);
            #ok;
        };

        public func validateZone(zone : Zone.Zone) : Result.Result<(), [Text]> {
            Zone.validate(zone, achievements);
        };

        public func addOrUpdateAchievement(achievement : Achievement.Achievement) : Result.Result<(), { #invalid : [Text] }> {
            switch (Achievement.validate(achievement)) {
                case (#err(errors)) return #err(#invalid(errors));
                case (#ok) ();
            };
            Debug.print("Adding achievement: " # achievement.id);
            achievements.put(achievement.id, achievement);
            #ok;
        };

        public func validateAchievement(achievement : Achievement.Achievement) : Result.Result<(), [Text]> {
            Achievement.validate(achievement);
        };

        public func addOrUpdateCreature(creature : Creature.Creature) : Result.Result<(), { #invalid : [Text] }> {
            switch (validateCreature(creature)) {
                case (#err(errors)) return #err(#invalid(errors));
                case (#ok) ();
            };
            Debug.print("Adding creature: " # creature.id);
            creatures.put(creature.id, creature);
            #ok;
        };

        public func validateCreature(creature : Creature.Creature) : Result.Result<(), [Text]> {
            Creature.validate(creature, actions, weapons, achievements);
        };

        public func addOrUpdateWeapon(weapon : Weapon.Weapon) : Result.Result<(), { #invalid : [Text] }> {
            switch (validateWeapon(weapon)) {
                case (#err(errors)) return #err(#invalid(errors));
                case (#ok) ();
            };
            Debug.print("Adding weapon: " # weapon.id);
            weapons.put(weapon.id, weapon);
            #ok;
        };

        public func validateWeapon(weapon : Weapon.Weapon) : Result.Result<(), [Text]> {
            Weapon.validate(weapon, actions, achievements);
        };

        public func addOrUpdateAction(action : Action.Action) : Result.Result<(), { #invalid : [Text] }> {
            switch (validateAction(action)) {
                case (#err(errors)) return #err(#invalid(errors));
                case (#ok) ();
            };
            Debug.print("Adding action: " # action.id);
            actions.put(action.id, action);
            #ok;
        };

        public func validateAction(action : Action.Action) : Result.Result<(), [Text]> {
            Action.validate(action);
        };

        public func addOrUpdateImage(image : Image.Image) : Result.Result<(), { #invalid : [Text] }> {
            switch (validateImage(image)) {
                case (#err(errors)) return #err(#invalid(errors));
                case (#ok) ();
            };

            Debug.print("Adding image: " # image.id);
            images.put(image.id, image);
            #ok;
        };

        public func validateImage(image : Image.Image) : Result.Result<(), [Text]> {
            Image.validate(image);
        };

        public func getImage(imageId : Text) : ?Image.Image {
            images.get(imageId);
        };

        public func getScenarioMetaDataList() : [ScenarioMetaData.ScenarioMetaData] {
            scenarioMetaDataList.vals() |> Iter.toArray(_);
        };

        public func getItems() : [Item.Item] {
            items.vals() |> Iter.toArray(_);
        };

        public func getActions() : [Action.Action] {
            actions.vals() |> Iter.toArray(_);
        };

        public func getRaces() : [Race.Race] {
            races.vals() |> Iter.toArray(_);
        };

        public func getClasses() : [Class.Class] {
            classes.vals() |> Iter.toArray(_);
        };

        public func getWeapons() : [Weapon.Weapon] {
            weapons.vals() |> Iter.toArray(_);
        };

        public func getZones() : [Zone.Zone] {
            zones.vals() |> Iter.toArray(_);
        };

        public func getAchievements() : [Achievement.Achievement] {
            achievements.vals() |> Iter.toArray(_);
        };

        public func getCreatures() : [Creature.Creature] {
            creatures.vals() |> Iter.toArray(_);
        };

        // ------------------ Private ------------------

        private func nextScenarioOrEnd(
            prng : Prng,
            inProgressInstance : InProgressData,
        ) : ?InProgressData {

            // TOOD how to change zones
            let scenariosPerZone = 10;
            let zoneId = if (inProgressInstance.scenarios.size() % scenariosPerZone == 0) {
                let exploredZoneIds = inProgressInstance.zoneIds
                |> TrieSet.fromArray<Text>(_, Text.hash, Text.equal);

                let unexploredZones = zones.vals()
                |> Iter.filter<Zone.Zone>(_, func(zone : Zone.Zone) = not TrieSet.mem(exploredZoneIds, zone.id, Text.hash(zone.id), Text.equal))
                |> Iter.toArray(_);
                if (unexploredZones.size() == 0) {
                    return null; // TODO this is temporary complete the game
                };
                prng.nextArrayElement(unexploredZones).id;
            } else {
                inProgressInstance.zoneIds[inProgressInstance.zoneIds.size() - 1]; // Last zone is 'current'
            };
            let newScenarioId = inProgressInstance.scenarios.size(); // TODO?
            let newScenario : Scenario.Scenario = {
                generateScenario(prng, zoneId, inProgressInstance.character) with
                id = newScenarioId;
            };

            ?{
                inProgressInstance with
                scenarios = Array.append(inProgressInstance.scenarios, [newScenario]);
                turnKind = #scenario({ scenarioId = newScenarioId });
            };
        };

        private func mapScenario(
            scenario : Scenario.Scenario
        ) : ScenarioWithMetaData {
            let ?metaData = scenarioMetaDataList.get(scenario.metaDataId) else Debug.trap("Scenario meta data not found: " # scenario.metaDataId);
            {
                scenario with
                metaData = metaData;
            };
        };

        private func generateScenario(
            prng : Prng,
            zoneId : Text,
            character : Character.Character,
        ) : {
            metaDataId : Text;
            previousStages : [Scenario.ScenarioStageResult];
            state : Scenario.ScenarioStateKind;
        } {
            let category = prng.nextArrayElementWeighted([
                (#combat, 4.),
                (#other, 3.),
                (#store, 3.),
            ]);
            let filteredScenarios = scenarioMetaDataList.vals()
            // Only scenarios that are common or have the zoneId
            |> Iter.filter(
                _,
                func(scenario : ScenarioMetaData.ScenarioMetaData) : Bool {
                    if (scenario.category != category) {
                        return false;
                    };
                    switch (scenario.location) {
                        case (#common) true;
                        case (#zoneIds(zoneIds)) Array.find(zoneIds, func(id : Text) : Bool = id == zoneId) != null;
                    };
                },
            )
            |> Iter.toArray(_);
            let scenarioMetaData = prng.nextArrayElement(filteredScenarios);
            let path = scenarioMetaData.paths[0]; // Use first path for initial path
            let gameContent : ScenarioSimulator.GameContent = {
                actions = actions;
                creatures = creatures;
                classes = classes;
                races = races;
                items = items;
                weapons = weapons;
                scenarioMetaData = scenarioMetaData;
            };
            let attributes = CharacterHandler.calculateAttributes(character, weapons, items, actions);
            let stateKind = ScenarioSimulator.buildNextInProgressState(prng, gameContent, character, attributes, path);
            {
                metaDataId = scenarioMetaData.id;
                previousStages = [];
                state = #inProgress(stateKind);
            };
        };

        private func toInstanceWithMetaData(playerId : Principal, instance : GameInstance) : GameWithMetaData {
            let state : GameStateWithMetaData = switch (instance.state) {
                case (#starting(starting)) {
                    #starting({
                        characterOptions = starting.characterOptions.vals()
                        |> Iter.map(_, toCharacterWithMetaData)
                        |> Iter.toArray(_);
                    });
                };
                case (#inProgress(inProgress)) {
                    let character = toCharacterWithMetaData(inProgress.character);
                    #inProgress({
                        character;
                        turnKind = inProgress.turnKind;
                    });
                };
                case (#completed(completed)) {
                    let character = toCharacterWithMetaData(completed.character);
                    #completed({
                        character;
                        endTime = completed.endTime;
                        victory = completed.victory;
                    });
                };
            };
            {
                id = instance.id;
                playerId = playerId;
                startTime = instance.startTime;
                state = state;
            };
        };
        private func toCharacterWithMetaData(
            character : Character.Character
        ) : CharacterWithMetaData {
            let ?class_ = classes.get(character.classId) else Debug.trap("Class not found: " # character.classId);
            let ?race = races.get(character.raceId) else Debug.trap("Race not found: " # character.raceId);
            let inventorySlots = character.inventorySlots.vals()
            |> Iter.map(
                _,
                func({ itemId } : Character.InventorySlot) : InventorySlotWithMetaData {
                    switch (itemId) {
                        case (null) ({ item = null });
                        case (?itemId) {
                            let ?item = items.get(itemId) else Debug.trap("Item not found: " # itemId);
                            { item = ?item };
                        };
                    };
                },
            )
            |> Iter.toArray(_);

            let actionsList = Character.getActions(character, items, weapons).vals()
            |> Iter.map(
                _,
                func(c : Character.CharacterAction) : CharacterActionWithMetaData {
                    let ?action = actions.get(c.actionId) else Debug.trap("Action not found: " # c.actionId);
                    {
                        action;
                        kind = c.kind;
                    };
                },
            )
            |> Iter.toArray(_);

            let ?weapon = weapons.get(character.weaponId) else Debug.trap("Weapon not found: " # character.weaponId);

            let attributes = CharacterHandler.calculateAttributes(character, weapons, items, actions);
            {
                health = character.health;
                maxHealth = character.maxHealth;
                gold = character.gold;
                class_ = class_;
                race = race;
                inventorySlots = inventorySlots;
                weapon = weapon;
                actions = actionsList;
                attributes = attributes;
            };
        };

    };

    private func toHashMap<TKey, TValue>(
        array : [TValue],
        func_ : (TValue) -> ((TKey, TValue)),
        hash : (TKey) -> Nat32,
        equal : (TKey, TKey) -> Bool,
    ) : HashMap.HashMap<TKey, TValue> {
        array.vals()
        |> Iter.map<TValue, (TKey, TValue)>(
            _,
            func_,
        )
        |> HashMap.fromIter<TKey, TValue>(_, array.size(), equal, hash);
    };
};
