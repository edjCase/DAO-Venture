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
import Int "mo:base/Int";
import Order "mo:base/Order";
import Buffer "mo:base/Buffer";
import Scenario "../models/Scenario";
import Character "../models/Character";
import IterTools "mo:itertools/Iter";
import CharacterGenerator "../CharacterGenerator";
import ScenarioSimulator "../ScenarioSimulator";
import Item "../models/entities/Item";
import Class "../models/entities/Class";
import Race "../models/entities/Race";
import Zone "../models/entities/Zone";
import Achievement "../models/entities/Achievement";
import Creature "../models/entities/Creature";
import Weapon "../models/entities/Weapon";
import CommonTypes "../CommonTypes";
import ScenarioMetaData "../models/entities/ScenarioMetaData";
import Action "../models/entities/Action";
import UnlockRequirement "../models/UnlockRequirement";
import UserHandler "UserHandler";

module {
    type Prng = PseudoRandomX.PseudoRandomGenerator;

    public type StableData = {
        playerDataList : [PlayerData];
        classes : [Class.Class];
        races : [Race.Race];
        scenarioMetaDataList : [ScenarioMetaData.ScenarioMetaData];
        items : [Item.Item];
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
        playerAchievementIds : [Text];
    };

    public type InProgressData = {
        character : Character.Character;
        playerAchievementIds : [Text];
        route : [RouteLocation];
        currentLocation : InProgressRouteLocationKind;
        completedLocations : [CompletedRouteLocationKind];
    };

    public type RouteLocation = {
        zoneId : Text;
        kind : RouteLocationKind;
    };

    public type RouteLocationKind = {
        #scenario;
    };

    public type InProgressRouteLocationKind = {
        #scenario : Scenario.Scenario;
    };

    public type CompletedRouteLocationKind = {
        #scenario : Scenario.CompletedScenario;
    };

    public type CompletedData = {
        endTime : Time.Time;
        outcome : CompletedGameOutcome;
        route : [CompletedGameRouteLocation];
    };

    public type CompletedGameRouteLocation = {
        zoneId : Text;
        kind : CompletedGameRouteLocationKind;
    };

    public type CompletedGameRouteLocationKind = CompletedRouteLocationKind or {
        #notStarted : RouteLocationKind;
    };

    public type CompletedGameOutcome = {
        #victory : VictoryGameOutcome;
        #forfeit : ForfeitGameOutcome;
        #death : DeathGameOutcome;
    };

    public type VictoryGameOutcome = {
        character : Character.Character;
        unlockedAchievementIds : [Text];
    };

    public type ForfeitGameOutcome = {
        character : ?Character.Character;
    };

    public type DeathGameOutcome = {
        character : Character.Character;
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
        route : [RouteLocation];
        currentLocation : InProgressRouteLocationKind;
        completedLocations : [CompletedRouteLocationKind];
    };

    public type CompletedGameStateWithMetaData = {
        endTime : Time.Time;
        outcome : CompletedGameOutcomeWithMetaData;
        route : [CompletedGameRouteLocation];
    };

    public type CompletedGameOutcomeWithMetaData = {
        #victory : VictoryGameOutcomeWithMetaData;
        #forfeit : ForfeitGameOutcomeWithMetaData;
        #death : DeathGameOutcomeWithMetaData;
    };

    public type VictoryGameOutcomeWithMetaData = {
        character : CharacterWithMetaData;
        unlockedAchievementIds : [Text];
    };

    public type ForfeitGameOutcomeWithMetaData = {
        character : ?CharacterWithMetaData;
    };

    public type DeathGameOutcomeWithMetaData = {
        character : CharacterWithMetaData;
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

    public type ScenarioWithMetaData = {
        metaData : ScenarioMetaData.ScenarioMetaData;
        previousStages : [Scenario.ScenarioStageResult];
        currentStage : Scenario.ScenarioStageKind;
    };

    public type CreateGameError = {
        #alreadyInitialized;
        #noClasses;
        #noRaces;
        #noScenarios;
        #noItems;
        #noZones;
        #noScenariosForZone : Text;
        #noCreatures;
        #noCreaturesForZone : Text;
        #noWeapons;
        #notAuthenticated;
        #userNotRegistered;
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
            playerAchievementIds : [Text],
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

            let unlockedClasses = classes.vals()
            |> UnlockRequirement.filterOutLockedEntities<Class.Class>(_, playerAchievementIds)
            |> Iter.toArray(_);

            let unlockedRaces = races.vals()
            |> UnlockRequirement.filterOutLockedEntities<Race.Race>(_, playerAchievementIds)
            |> Iter.toArray(_);

            let characterOptions = IterTools.range(0, 4)
            |> Iter.map(
                _,
                func(_ : Nat) : Character.Character {
                    let class_ = prng.nextArrayElement(unlockedClasses);
                    let race = prng.nextArrayElement(unlockedRaces);
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
                            playerAchievementIds = playerAchievementIds;
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
                case (#starting(_)) {
                    {
                        endTime = Time.now();
                        outcome = #forfeit({
                            character = null;
                        });
                        route = [];
                    };
                };
                case (#inProgress(inProgress)) {
                    let completedRoute = getCompletedRoute(inProgress.route, inProgress.completedLocations);
                    {
                        endTime = Time.now();
                        outcome = #forfeit({
                            character = ?toCharacterWithMetaData(inProgress.character);
                        });
                        route = completedRoute;
                    };
                };
                case (#completed(completed)) {
                    {
                        endTime = completed.endTime;
                        outcome = toOutcomeWithMetaData(completed.outcome);
                        route = completed.route;
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

        private func getCompletedRoute(
            route : [RouteLocation],
            completedLocations : [CompletedRouteLocationKind],
        ) : [CompletedGameRouteLocation] {
            IterTools.zipLongest(route.vals(), completedLocations.vals())
            |> Iter.map<IterTools.EitherOr<RouteLocation, CompletedRouteLocationKind>, CompletedGameRouteLocation>(
                _,
                func(eo : IterTools.EitherOr<RouteLocation, CompletedRouteLocationKind>) : CompletedGameRouteLocation {
                    switch (eo) {
                        case (#both(routeLocation, completedLocation)) {
                            {
                                zoneId = routeLocation.zoneId;
                                kind = completedLocation;
                            };
                        };
                        case (#left(routeLocation)) {
                            {
                                zoneId = routeLocation.zoneId;
                                kind = #notStarted(routeLocation.kind);
                            };
                        };
                        case (#right(_)) Debug.trap("Unexpected completed location, with no route location");
                    };
                },
            )
            |> Iter.toArray(_);
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

            let unlockedZones = zones.vals()
            |> UnlockRequirement.filterOutLockedEntities<Zone.Zone>(_, starting.playerAchievementIds)
            |> Iter.toArray(_);

            let route = Buffer.Buffer<RouteLocation>(15);

            func getRandomZoneWithDifficulty(difficulty : Zone.ZoneDifficulty) : Zone.Zone {
                let zonesWithDifficulty = unlockedZones.vals()
                |> Iter.filter(
                    _,
                    func(zone : Zone.Zone) : Bool = zone.difficulty == difficulty,
                )
                |> Iter.toArray(_);
                prng.nextArrayElement(zonesWithDifficulty);
            };

            func addZoneScenarios(zoneId : Text, count : Nat) {
                for (i in IterTools.range(0, count)) {
                    route.add({
                        zoneId = zoneId;
                        kind = #scenario;
                    });
                };
            };

            // Zone 1 (Easy), 5 scenarios
            let zone1 = getRandomZoneWithDifficulty(#easy);
            addZoneScenarios(zone1.id, 5);
            // Zone 2 (Medium), 5 scenarios
            let zone2 = getRandomZoneWithDifficulty(#medium);
            addZoneScenarios(zone2.id, 5);
            // Zone 3 (Hard), 5 scenarios
            let zone3 = getRandomZoneWithDifficulty(#hard);
            addZoneScenarios(zone3.id, 5);

            let firstRouteLocation = route.get(0);
            let currentLocation : InProgressRouteLocationKind = initializeNewLocation(
                prng,
                firstRouteLocation,
                character,
                playerId,
                starting.playerAchievementIds,
            );
            playerDataList.put(
                playerId,
                {
                    playerData with
                    activeGame = ?{
                        instance with
                        state = #inProgress(
                            {
                                character = character;
                                playerAchievementIds = starting.playerAchievementIds;
                                route = Buffer.toArray(route);
                                currentLocation = currentLocation;
                                completedLocations = [];
                            } : InProgressData
                        );
                    } : ?GameInstance
                },
            );
            #ok;
        };

        private func initializeNewLocation(
            prng : Prng,
            firstRouteLocation : RouteLocation,
            character : Character.Character,
            playerId : Principal,
            playerAchievementIds : [Text],
        ) : InProgressRouteLocationKind {
            switch (firstRouteLocation.kind) {
                case (#scenario) {
                    let filteredScenarios = scenarioMetaDataList.vals()
                    |> UnlockRequirement.filterOutLockedEntities(_, playerAchievementIds)
                    // Only scenarios that are common or have the zoneId
                    |> Iter.filter(
                        _,
                        func(scenario : ScenarioMetaData.ScenarioMetaData) : Bool {
                            switch (scenario.location) {
                                case (#common) true;
                                case (#zoneIds(zoneIds)) Array.find(zoneIds, func(id : Text) : Bool = id == firstRouteLocation.zoneId) != null;
                            };
                        },
                    )
                    |> Iter.toArray(_);
                    let scenarioMetaData = prng.nextArrayElement(filteredScenarios);

                    let characterHandler = CharacterHandler.Handler(character);

                    let gameContent : ScenarioSimulator.GameContent = {
                        scenarioMetaData = scenarioMetaDataList;
                        creatures = creatures;
                        classes = classes;
                        races = races;
                        items = items;
                        weapons = weapons;
                        actions = actions;
                    };

                    let player : ScenarioSimulator.Player = {
                        id = playerId;
                        var achievementIds = playerAchievementIds;
                    };
                    // TODO initialize doesnt need most of this stuff, but the internal helper does
                    let scenario = ScenarioSimulator.initialize(
                        prng,
                        player,
                        characterHandler,
                        gameContent,
                        scenarioMetaData,
                    );
                    #scenario(scenario);
                };
            };
        };

        public func selectScenarioChoice(
            prng : Prng,
            playerId : Principal,
            choice : ScenarioSimulator.StageChoiceKind,
            userHandler : UserHandler.Handler,
        ) : Result.Result<(), { #gameNotFound; #gameNotActive; #invalidChoice : Text; #notScenarioTurn; #invalidTarget; #targetRequired }> {
            let ?playerData = playerDataList.get(playerId) else return #err(#gameNotFound);
            let ?instance = playerData.activeGame else return #err(#gameNotActive);
            let #inProgress(inProgressInstance) = instance.state else return #err(#gameNotActive);

            let characterHandler = CharacterHandler.Handler(inProgressInstance.character);

            let gameContent : ScenarioSimulator.GameContent = {
                scenarioMetaData = scenarioMetaDataList;
                creatures = creatures;
                classes = classes;
                races = races;
                items = items;
                weapons = weapons;
                actions = actions;
            };

            let player : ScenarioSimulator.Player = {
                id = playerId;
                var achievementIds = inProgressInstance.playerAchievementIds;
            };
            let result = switch (inProgressInstance.currentLocation) {
                case (#scenario(currentScenario)) {
                    switch (
                        ScenarioSimulator.runStage(
                            prng,
                            player,
                            characterHandler,
                            currentScenario,
                            gameContent,
                            choice,
                        )
                    ) {
                        case (#ok(result)) switch (result) {
                            case (#dead) #dead;
                            case (#updated(updatedScenario)) #updated(#scenario(updatedScenario));
                            case (#completed(completedScenario)) #completed(#scenario(completedScenario));
                        };
                        case (#err(#scenarioComplete)) Debug.trap("Failed to process choice: Scenario complete");
                        case (#err(#invalidChoice(invalidChoice))) return #err(#invalidChoice(invalidChoice));
                        case (#err(#invalidTarget)) return #err(#invalidTarget);
                        case (#err(#targetRequired)) return #err(#targetRequired);
                    };
                };
            };
            let updatedState = switch (result) {
                case (#dead) {
                    let completedRoute = getCompletedRoute(inProgressInstance.route, inProgressInstance.completedLocations);
                    #completed({
                        endTime = Time.now();
                        route = completedRoute;
                        outcome = #death({
                            character = characterHandler.get();
                        });
                    });
                };
                case (#updated(updatedLocation)) {
                    #inProgress({
                        inProgressInstance with
                        character = characterHandler.get();
                        playerAchievementIds = player.achievementIds;
                        currentLocation = updatedLocation;
                    });
                };
                case (#completed(completedLocation)) {
                    let completedLocations = Array.append(inProgressInstance.completedLocations, [completedLocation]);
                    let runComplete = inProgressInstance.route.size() == completedLocations.size();

                    if (not runComplete) {
                        let nextLocationInfo = inProgressInstance.route.get(completedLocations.size());
                        let newLocation = initializeNewLocation(
                            prng,
                            nextLocationInfo,
                            characterHandler.get(),
                            playerId,
                            inProgressInstance.playerAchievementIds,
                        );
                        #inProgress({
                            inProgressInstance with
                            character = characterHandler.get();
                            playerAchievementIds = player.achievementIds;
                            completedLocations = completedLocations;
                            currentLocation = newLocation;
                        });
                    } else {
                        // Victory
                        let unlockedAchievementIds : [Text] = inProgressInstance.playerAchievementIds.vals()
                        // Filter out achievements that the user already has
                        |> Iter.filter(
                            _,
                            func(id : Text) : Bool = switch (userHandler.unlockAchievement(playerId, id)) {
                                case (#ok(_)) true;
                                case (#err(#alreadyUnlocked)) false;
                                case (#err(#userNotFound)) Debug.trap("User not found: " # Principal.toText(playerId));
                                case (#err(#achievementNotFound)) Debug.trap("Achievement not found: " # id);
                            },
                        )
                        |> Iter.toArray(_);
                        let completedRoute = getCompletedRoute(inProgressInstance.route, completedLocations);
                        #completed({
                            endTime = Time.now();
                            route = completedRoute;
                            outcome = #victory({
                                character = characterHandler.get();
                                unlockedAchievementIds = unlockedAchievementIds;
                            });
                        });
                    };
                };
            };

            playerDataList.put(
                playerId,
                {
                    playerData with
                    activeGame = ?{
                        instance with
                        state = updatedState;
                    };
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
            ScenarioMetaData.validate(scenario, items, weapons, zones, achievements, creatures);
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
            Creature.validate(creature, actions, achievements);
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
                        route = inProgress.route;
                        currentLocation = inProgress.currentLocation;
                        completedLocations = inProgress.completedLocations;
                    });
                };
                case (#completed(completed)) {
                    #completed({
                        endTime = completed.endTime;
                        outcome = toOutcomeWithMetaData(completed.outcome);
                        route = completed.route;
                    });
                };
            };
            {
                instance with
                playerId = playerId;
                state = state;
            };
        };

        private func toOutcomeWithMetaData(
            outcome : CompletedGameOutcome
        ) : CompletedGameOutcomeWithMetaData {
            switch (outcome) {
                case (#victory(victory)) {
                    #victory({
                        character = toCharacterWithMetaData(victory.character);
                        unlockedAchievementIds = victory.unlockedAchievementIds;
                    });
                };
                case (#forfeit(forfeit)) {
                    #forfeit({
                        character = switch (forfeit.character) {
                            case (null) null;
                            case (?character) ?toCharacterWithMetaData(character);
                        };
                    });
                };
                case (#death(death)) {
                    #death({
                        character = toCharacterWithMetaData(death.character);
                    });
                };
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
