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
import Trie "mo:base/Trie";
import Nat "mo:base/Nat";
import Array "mo:base/Array";
import TrieSet "mo:base/TrieSet";
import Int "mo:base/Int";
import Location "../models/Location";
import Scenario "../models/entities/Scenario";
import Character "../models/Character";
import IterTools "mo:itertools/Iter";
import CharacterGenerator "../CharacterGenerator";
import ScenarioSimulator "../ScenarioSimulator";
import Trait "../models/entities/Trait";
import Item "../models/entities/Item";
import Class "../models/entities/Class";
import Race "../models/entities/Race";
import Outcome "../models/Outcome";
import Image "../models/Image";
import Zone "../models/entities/Zone";
import HexGrid "../models/HexGrid";
import Achievement "../models/entities/Achievement";
import UserHandler "UserHandler";
import Creature "../models/entities/Creature";
import Weapon "../models/entities/Weapon";

module {
    type Prng = PseudoRandomX.PseudoRandomGenerator;

    public type StableData = {
        playerDataList : [PlayerData];
        classes : [Class.Class];
        races : [Race.Race];
        scenarioMetaDataList : [Scenario.ScenarioMetaData];
        items : [Item.Item];
        traits : [Trait.Trait];
        images : [Image.Image];
        zones : [Zone.Zone];
        achievements : [Achievement.Achievement];
        creatures : [Creature.Creature];
        weapons : [Weapon.Weapon];
    };

    public type PlayerData = {
        id : Principal;
        activeGame : ?GameInstance;
        completedGames : [CompletedGameWithMetaData];
    };

    public type GameInstance = {
        id : Nat;
        startTime : Time.Time;
        difficulty : Difficulty;
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
        turn : Nat;
        locations : [Location.Location];
    };

    public type CompletedData = {
        endTime : Time.Time;
        turns : Nat;
        character : Character.Character;
        victory : Bool;
    };

    public type Difficulty = {
        #easy;
        #normal;
        #hard;
    };

    public type GameWithMetaData = {
        id : Nat;
        playerId : Principal;
        startTime : Time.Time;
        difficulty : Difficulty;
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
        turn : Nat;
        locations : [Location.Location];
        character : CharacterWithMetaData;
    };

    public type CompletedGameStateWithMetaData = {
        turns : Nat;
        character : CharacterWithMetaData;
        endTime : Time.Time;
        victory : Bool;
    };

    public type CompletedGameWithMetaData = CompletedGameStateWithMetaData and {
        id : Nat;
        playerId : Principal;
        startTime : Time.Time;
        difficulty : Difficulty;
    };

    public type CharacterWithMetaData = {
        health : Nat;
        maxHealth : Nat;
        gold : Nat;
        class_ : Class.Class;
        race : Race.Race;
        attack : Int;
        defense : Int;
        speed : Int;
        magic : Int;
        items : [Item.Item];
        traits : [Trait.Trait];
        weapon : Weapon.Weapon;
    };

    public type ScenarioWithMetaData = Scenario.Scenario and {
        metaData : Scenario.ScenarioMetaData;
        availableChoiceIds : [Text];
    };

    public type CreateGameError = {
        #alreadyInitialized;
        #noClasses;
        #noRaces;
        #noScenarios;
        #noItems;
        #noTraits;
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

        let scenarioMetaDataList = toTextHashMap<Scenario.ScenarioMetaData>(data.scenarioMetaDataList);

        let items = toTextHashMap<Item.Item>(data.items);

        let traits = toTextHashMap<Trait.Trait>(data.traits);

        let images = toTextHashMap<Image.Image>(data.images);

        let zones = toTextHashMap<Zone.Zone>(data.zones);

        let achievements = toTextHashMap<Achievement.Achievement>(data.achievements);

        let creatures = toTextHashMap<Creature.Creature>(data.creatures);

        let weapons = toTextHashMap<Weapon.Weapon>(data.weapons);

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
                traits = Iter.toArray(traits.vals());
                images = Iter.toArray(images.vals());
                zones = Iter.toArray(zones.vals());
                achievements = Iter.toArray(achievements.vals());
                creatures = Iter.toArray(creatures.vals());
                weapons = Iter.toArray(weapons.vals());
            };
        };

        public func createInstance(
            prng : Prng,
            playerId : Principal,
            difficulty : Difficulty,
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
            if (traits.size() == 0) {
                return #err(#noTraits);
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
                        func(scenario : Scenario.ScenarioMetaData) : Bool = switch (scenario.location) {
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
                    CharacterGenerator.generate(class_, race, weapons);
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
                        difficulty = difficulty;
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
                        turns = inProgress.turn;
                        character = toCharacterWithMetaData(inProgress.character);
                        endTime = Time.now();
                        victory = false;
                    };
                };
                case (#completed(completed)) {
                    {
                        turns = completed.turns;
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
                        difficulty = activeGame.difficulty;
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
            let #inProgress({ scenarios; character }) = instance.state else return #err(#gameNotActive);
            let ?scenario = Array.find(scenarios, func(s : Scenario.Scenario) : Bool = s.id == scenarioId) else return #err(#notFound);
            #ok(mapScenario(scenario, character));
        };

        public func getScenarios(playerId : Principal) : Result.Result<[ScenarioWithMetaData], { #gameNotFound; #gameNotActive }> {
            let ?playerData = playerDataList.get(playerId) else return #err(#gameNotFound);
            let ?instance = playerData.activeGame else return #err(#gameNotActive);
            let #inProgress({ scenarios; character }) = instance.state else return #err(#gameNotActive);
            let scenariosWithMetaData = scenarios.vals()
            |> Iter.map<Scenario.Scenario, ScenarioWithMetaData>(
                _,
                func(scenario : Scenario.Scenario) : ScenarioWithMetaData = mapScenario(scenario, character),
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
                generateScenario(prng, zoneId) with
                id = scenarioId;
                outcome = null;
            };
            let location : Location.Location = {
                id = 0;
                coordinate = { q = 0; r = 0 };
                scenarioId = scenarioId;
                zoneId = zoneId;
            };
            playerDataList.put(
                playerId,
                {
                    playerData with
                    activeGame = ?{
                        instance with
                        state = #inProgress(
                            {
                                character = character;
                                scenarios = [scenario];
                                turn = 0;
                                locations = [location];
                            } : InProgressData
                        );
                    } : ?GameInstance
                },
            );
            #ok;
        };

        public func endTurn(
            prng : Prng,
            playerId : Principal,
            userHandler : UserHandler.Handler,
            choiceId : Text,
        ) : Result.Result<(), { #gameNotFound; #gameNotActive; #invalidChoice; #choiceRequirementNotMet }> {
            let ?playerData = playerDataList.get(playerId) else return #err(#gameNotFound);
            let ?instance = playerData.activeGame else return #err(#gameNotActive);
            let #inProgress(inProgressInstance) = instance.state else return #err(#gameNotActive);

            let currentLocation = getCharacterLocation(inProgressInstance);

            let ?scenario = Array.find(
                inProgressInstance.scenarios,
                func(s : Scenario.Scenario) : Bool = s.id == currentLocation.scenarioId,
            ) else Debug.trap("Scenario not found: " # Nat.toText(currentLocation.scenarioId));
            let ?scenarioMetaData = scenarioMetaDataList.get(scenario.metaDataId) else Debug.trap("Scenario meta data not found: " # scenario.metaDataId);

            let characterHandler = CharacterHandler.Handler(inProgressInstance.character);

            let ?choice = Array.find(
                scenarioMetaData.choices,
                func(choice : Scenario.Choice) : Bool = choiceId == choice.id,
            ) else return #err(#invalidChoice);
            switch (choice.requirement) {
                case (null) ();
                case (?requirement) {
                    if (not Outcome.validateRequirement(requirement, inProgressInstance.character)) {
                        return #err(#choiceRequirementNotMet);
                    };
                };
            };
            let result = ScenarioSimulator.run(
                prng,
                playerId,
                userHandler,
                characterHandler,
                scenario,
                scenarioMetaData,
                creatures,
                weapons,
                choiceId,
            );
            let outcome : Outcome.Outcome = {
                choiceId;
                log = result.log;
            };
            let updatedScenario : Scenario.Scenario = {
                scenario with
                outcome = ?outcome;
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
            let updatedGame : GameInstance = switch (result.kind) {
                case (#inProgress) {
                    switch (nextLocation(prng, updatedInProgressState)) {
                        case (?updatedInProgressState) {
                            {
                                updatedInstance with
                                state = #inProgress({
                                    updatedInProgressState with
                                    turn = inProgressInstance.turn + 1;
                                });
                            };
                        };
                        case (null) {
                            {
                                updatedInstance with
                                state = #completed({
                                    endTime = Time.now();
                                    turns = updatedInProgressState.turn;
                                    character = updatedInProgressState.character;
                                    victory = true;
                                });
                            };
                        };
                    };
                };
                case (#defeat) {
                    {
                        updatedInstance with
                        state = #completed({
                            endTime = Time.now();
                            turns = updatedInProgressState.turn;
                            character = updatedInProgressState.character;
                            victory = false;
                        });
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

        public func getInstance(playerId : Principal) : ?GameWithMetaData {
            let ?playerData = playerDataList.get(playerId) else return null;
            let ?instance = playerData.activeGame else return null;
            ?toInstanceWithMetaData(playerId, instance);
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
            Item.validate(item, achievements);
        };

        public func addOrUpdateTrait(trait : Trait.Trait) : Result.Result<(), { #invalid : [Text] }> {
            switch (validateTrait(trait)) {
                case (#err(errors)) return #err(#invalid(errors));
                case (#ok) ();
            };
            Debug.print("Adding trait: " # trait.id);
            traits.put(trait.id, trait);
            #ok;
        };

        public func validateTrait(trait : Trait.Trait) : Result.Result<(), [Text]> {
            Trait.validate(trait, achievements);
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
            Race.validate(race, items, traits, achievements);
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
            Class.validate(class_, items, traits, achievements);
        };

        public func addOrUpdateScenarioMetaData(scenario : Scenario.ScenarioMetaData) : Result.Result<(), { #invalid : [Text] }> {
            switch (validateScenarioMetaData(scenario)) {
                case (#err(errors)) return #err(#invalid(errors));
                case (#ok) ();
            };
            Debug.print("Adding scenario meta data: " # scenario.id);
            scenarioMetaDataList.put(scenario.id, scenario);
            #ok;
        };

        public func validateScenarioMetaData(scenario : Scenario.ScenarioMetaData) : Result.Result<(), [Text]> {
            Scenario.validateMetaData(scenario, items, traits, images, zones, achievements, creatures);
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
            Creature.validate(creature, weapons, achievements);
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
            Weapon.validate(weapon, achievements);
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

        public func getScenarioMetaDataList() : [Scenario.ScenarioMetaData] {
            scenarioMetaDataList.vals() |> Iter.toArray(_);
        };

        public func getTraits() : [Trait.Trait] {
            traits.vals() |> Iter.toArray(_);
        };

        public func getItems() : [Item.Item] {
            items.vals() |> Iter.toArray(_);
        };

        public func getRaces() : [Race.Race] {
            races.vals() |> Iter.toArray(_);
        };

        public func getClasses() : [Class.Class] {
            classes.vals() |> Iter.toArray(_);
        };

        // ------------------ Private ------------------

        private func getCharacterLocation(inProgressInstance : InProgressData) : Location.Location {
            inProgressInstance.locations.get(inProgressInstance.locations.size() - 1);
        };

        private func nextLocation(
            prng : Prng,
            inProgressInstance : InProgressData,
        ) : ?InProgressData {
            let currentLocation = getCharacterLocation(inProgressInstance);

            let nextCoordinate = {
                q = currentLocation.coordinate.q + 1; // Move right
                r = currentLocation.coordinate.r;
            };
            // TOOD how to change zones
            let scenariosPerZone = 10;
            let zoneId = if (inProgressInstance.locations.size() % scenariosPerZone == 0) {
                let exploredZoneIds = inProgressInstance.locations.vals()
                |> Iter.map<Location.Location, Text>(_, func(location : Location.Location) = location.zoneId)
                |> Iter.toArray(_)
                |> TrieSet.fromArray<Text>(_, Text.hash, Text.equal);

                let unexploredZones = zones.vals()
                |> Iter.filter<Zone.Zone>(_, func(zone : Zone.Zone) = not TrieSet.mem(exploredZoneIds, zone.id, Text.hash(zone.id), Text.equal))
                |> Iter.toArray(_);
                if (unexploredZones.size() == 0) {
                    return null; // TODO this is temporary complete the game
                };
                prng.nextArrayElement(unexploredZones).id;
            } else {
                currentLocation.zoneId;
            };
            let newScenarioId = inProgressInstance.scenarios.size(); // TODO?
            let newScenario = {
                generateScenario(prng, zoneId) with
                id = newScenarioId;
                outcome = null;
            };

            let nextLocation = {
                id = HexGrid.axialCoordinateToIndex(nextCoordinate);
                coordinate = nextCoordinate;
                scenarioId = newScenarioId;
                zoneId = zoneId;
            };
            ?{
                inProgressInstance with
                scenarios = Array.append(inProgressInstance.scenarios, [newScenario]);
                locations = Array.append(inProgressInstance.locations, [nextLocation]);
            };
        };

        private func mapScenario(
            scenario : Scenario.Scenario,
            character : Character.Character,
        ) : ScenarioWithMetaData {
            let ?metaData = scenarioMetaDataList.get(scenario.metaDataId) else Debug.trap("Scenario meta data not found: " # scenario.metaDataId);
            {
                scenario with
                metaData = metaData;
                availableChoiceIds = metaData.choices.vals()
                |> Iter.filter(
                    _,
                    func(choice : Scenario.Choice) : Bool {
                        switch (choice.requirement) {
                            case (null) true;
                            case (?requirement) Outcome.validateRequirement(requirement, character);
                        };
                    },
                )
                |> Iter.map(_, func(choice : Scenario.Choice) : Text = choice.id)
                |> Iter.toArray(_);
            };
        };

        private func generateScenario(prng : Prng, zoneId : Text) : {
            metaDataId : Text;
            data : [Scenario.GeneratedDataFieldInstance];
        } {
            let category = prng.nextArrayElementWeighted([
                (#combat, 6.),
                (#other, 3.),
                (#store, 1.),
            ]);
            let filteredScenarios = scenarioMetaDataList.vals()
            // Only scenarios that are common or have the zoneId
            |> Iter.filter(
                _,
                func(scenario : Scenario.ScenarioMetaData) : Bool {
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
            let scenarioData = scenarioMetaData.data.vals()
            |> Iter.map<Scenario.GeneratedDataField, Scenario.GeneratedDataFieldInstance>(
                _,
                func(field : Scenario.GeneratedDataField) : Scenario.GeneratedDataFieldInstance {
                    let value = switch (field.value) {
                        case (#nat({ min; max })) #nat(prng.nextNat(min, max));
                        case (#text(text)) #text(prng.nextArrayElementWeighted(text.options));
                    };
                    {
                        id = field.id;
                        value = value;
                    };
                },
            )
            |> Iter.toArray(_);
            {
                metaDataId = scenarioMetaData.id;
                data = scenarioData;
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
                        turn = inProgress.turn;
                        locations = inProgress.locations;
                        character;
                    });
                };
                case (#completed(completed)) {
                    let turns = completed.turns;
                    let character = toCharacterWithMetaData(completed.character);
                    #completed({
                        turns;
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
                difficulty = instance.difficulty;
                state = state;
            };
        };
        private func toCharacterWithMetaData(
            character : Character.Character
        ) : CharacterWithMetaData {
            let ?class_ = classes.get(character.classId) else Debug.trap("Class not found: " # character.classId);
            let ?race = races.get(character.raceId) else Debug.trap("Race not found: " # character.raceId);
            let itemsWithMetaData = Trie.iter(character.itemIds)
            |> Iter.map(
                _,
                func((itemId, _) : (Text, ())) : Item.Item {
                    let ?item = items.get(itemId) else Debug.trap("Item not found: " # itemId);
                    item;
                },
            )
            |> Iter.toArray(_);

            let traitsWithMetaData = Trie.iter(character.traitIds)
            |> Iter.map(
                _,
                func((traitId, _) : (Text, ())) : Trait.Trait {
                    let ?trait = traits.get(traitId) else Debug.trap("Trait not found: " # traitId);
                    trait;
                },
            )
            |> Iter.toArray(_);
            {
                health = character.health;
                maxHealth = character.maxHealth;
                gold = character.gold;
                class_ = class_;
                race = race;
                attack = character.attack;
                defense = character.defense;
                speed = character.speed;
                magic = character.magic;
                items = itemsWithMetaData;
                traits = traitsWithMetaData;
                weapon = character.weapon;
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
