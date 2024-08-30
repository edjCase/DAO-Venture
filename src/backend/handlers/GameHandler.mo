import ScenarioHandler "ScenarioHandler";
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
import Prelude "mo:base/Prelude";
import Order "mo:base/Order";
import Int "mo:base/Int";
import Buffer "mo:base/Buffer";
import Location "../models/Location";
import Scenario "../models/entities/Scenario";
import Character "../models/Character";
import ExtendedProposal "mo:dao-proposal-engine/ExtendedProposal";
import IterTools "mo:itertools/Iter";
import NatX "mo:xtended-numbers/NatX";
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
        instances : [GameInstance]; // TODO archive completed games
        classes : [Class.Class];
        races : [Race.Race];
        scenarios : [Scenario.ScenarioMetaData];
        items : [Item.Item];
        traits : [Trait.Trait];
        images : [Image.Image];
        zones : [Zone.Zone];
        achievements : [Achievement.Achievement];
        creatures : [Creature.Creature];
        weapons : [Weapon.Weapon];
    };

    public type GameInstance = {
        id : Nat;
        hostUserId : Principal;
        guestUserIds : [Principal];
        createdTime : Time.Time;
        difficulty : Difficulty;
        state : GameInstanceState;
    };

    public type GameInstanceState = {
        #notStarted;
        #voting : VotingData;
        #inProgress : InProgressData;
        #completed : CompletedData;
    };

    public type VotingData = {
        startTime : Time.Time;
        characterProposal : ExtendedProposal.Proposal<[Character.Character], Text>;
    };

    public type InProgressData = {
        startTime : Time.Time;
        scenarios : ScenarioHandler.StableData;
        character : CharacterHandler.StableData;
        turn : Nat;
        locations : [Location.Location];
    };

    public type CompletedData = {
        startTime : Time.Time;
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
        hostUserId : Principal;
        guestUserIds : [Principal];
        createdTime : Time.Time;
        difficulty : Difficulty;
        state : GameStateWithMetaData;
    };

    public type GameStateWithMetaData = {
        #notStarted;
        #voting : VotingGameStateWithMetaData;
        #inProgress : InProgressGameStateWithMetaData;
        #completed : CompletedGameStateWithMetaData;
    };

    public type VotingGameStateWithMetaData = {
        startTime : Time.Time;
        characterOptions : [CharacterWithMetaData];
        characterVotes : ExtendedProposal.VotingSummary<Text>;
    };

    public type InProgressGameStateWithMetaData = {
        startTime : Time.Time;
        turn : Nat;
        locations : [Location.Location];
        character : CharacterWithMetaData;
    };

    public type CompletedGameStateWithMetaData = {
        startTime : Time.Time;
        turns : Nat;
        character : CharacterWithMetaData;
        endTime : Time.Time;
        victory : Bool;
    };

    public type CompletedGameWithMetaData = CompletedGameStateWithMetaData and {
        id : Nat;
        hostUserId : Principal;
        guestUserIds : [Principal];
        createdTime : Time.Time;
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
    };

    type MutableGameInstance = {
        id : Nat;
        hostUserId : Principal;
        guestUserIds : [Principal];
        createdTime : Time.Time;
        difficulty : Difficulty;
        state : {
            #notStarted;
            #voting : MutableVotingData;
            #inProgress : MutableInProgressData;
            #completed : CompletedData;
        };
    };

    type MutableVotingData = {
        startTime : Time.Time;
        var characterProposal : ExtendedProposal.Proposal<[Character.Character], Text>;
    };

    type MutableInProgressData = {
        startTime : Time.Time;
        scenarioHandler : ScenarioHandler.Handler;
        characterHandler : CharacterHandler.Handler;
        var turn : Nat;
        var locations : [Location.Location];
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

        let scenarios = toTextHashMap<Scenario.ScenarioMetaData>(data.scenarios);

        let items = toTextHashMap<Item.Item>(data.items);

        let traits = toTextHashMap<Trait.Trait>(data.traits);

        let images = toTextHashMap<Image.Image>(data.images);

        let zones = toTextHashMap<Zone.Zone>(data.zones);

        let achievements = toTextHashMap<Achievement.Achievement>(data.achievements);

        let creatures = toTextHashMap<Creature.Creature>(data.creatures);

        let weapons = toTextHashMap<Weapon.Weapon>(data.weapons);

        var instances : HashMap.HashMap<Nat, MutableGameInstance> = toHashMap<GameInstance, Nat, MutableGameInstance>(
            data.instances,
            func(instance : GameInstance) : (Nat, MutableGameInstance) = (instance.id, toMutableInstance(instance)),
            Nat32.fromNat,
            Nat.equal,
        );

        public func toStableData() : StableData {
            {
                instances = instances.vals() |> Iter.map(_, fromMutableInstance) |> Iter.toArray(_);
                classes = Iter.toArray(classes.vals());
                races = Iter.toArray(races.vals());
                scenarios = Iter.toArray(scenarios.vals());
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
            hostUserId : Principal
        ) : Result.Result<Nat, CreateGameError> {
            if (classes.size() == 0) {
                return #err(#noClasses);
            };
            if (races.size() == 0) {
                return #err(#noRaces);
            };
            if (scenarios.size() == 0) {
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
                        scenarios.vals(),
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
            switch (getCurrentInstance(hostUserId)) {
                case (?instance) {
                    switch (instance.state) {
                        case (#completed(_)) (); // Ok to create a new game
                        case (_) return #err(#alreadyInitialized);
                    };
                };
                case (null) ();
            };

            let instanceId = instances.size(); // TODO
            instances.put(
                instanceId,
                {
                    id = instanceId;
                    hostUserId = hostUserId;
                    guestUserIds = [];
                    createdTime = Time.now();
                    state = #notStarted;
                    difficulty = #normal;
                },
            );

            #ok(instanceId);
        };

        public func addPlayer(
            gameId : Nat,
            playerId : Principal,
        ) : Result.Result<(), { #gameNotFound; #alreadyJoined; #lobbyClosed }> {
            let ?instance = instances.get(gameId) else return #err(#gameNotFound);
            let #notStarted = instance.state else return #err(#lobbyClosed);
            if (instance.hostUserId == playerId or Array.indexOf(playerId, instance.guestUserIds, Principal.equal) != null) {
                return #err(#alreadyJoined);
            };
            instances.put(
                gameId,
                {
                    instance with
                    guestUserIds = Array.append(instance.guestUserIds, [playerId]);
                },
            );
            #ok;
        };

        public func kickPlayer(
            gameId : Nat,
            playerId : Principal,
            kickerId : Principal,
        ) : Result.Result<(), { #gameNotFound; #notAuthorized; #playerNotInGame; #kickHostForbidden }> {
            let ?instance = instances.get(gameId) else return #err(#gameNotFound);
            if (instance.hostUserId != kickerId and kickerId != playerId) {
                return #err(#notAuthorized);
            };
            if (instance.hostUserId == playerId) {
                return #err(#kickHostForbidden);
            };
            if (Array.indexOf(playerId, instance.guestUserIds, Principal.equal) == null) {
                return #err(#playerNotInGame);
            };
            instances.put(
                gameId,
                {
                    instance with
                    guestUserIds = Array.filter(instance.guestUserIds, func(id : Principal) : Bool = id != playerId);
                },
            );
            #ok;
        };

        public func changeDifficulty(
            gameId : Nat,
            difficulty : Difficulty,
            caller : Principal,
        ) : Result.Result<(), { #gameNotFound; #notAuthorized; #gameStarted }> {
            let ?instance = instances.get(gameId) else return #err(#gameNotFound);
            let #notStarted = instance.state else return #err(#gameStarted);
            if (instance.hostUserId != caller) {
                return #err(#notAuthorized);
            };
            instances.put(
                gameId,
                {
                    instance with
                    difficulty = difficulty;
                },
            );
            #ok;
        };

        public func abandon(
            gameId : Nat,
            userId : Principal,
        ) : Result.Result<(), { #gameNotFound; #notAuthorized; #gameComplete }> {
            let ?instance = instances.get(gameId) else return #err(#gameNotFound);
            if (instance.hostUserId != userId) {
                return #err(#notAuthorized);
            };
            switch (instance.state) {
                case (#notStarted or #voting(_)) {
                    ignore instances.remove(gameId);
                    #ok;
                };
                case (#inProgress(inProgress)) {
                    instances.put(
                        gameId,
                        {
                            instance with
                            state = #completed({
                                startTime = inProgress.startTime;
                                endTime = Time.now();
                                turns = inProgress.turn;
                                character = inProgress.characterHandler.get();
                                victory = false;
                            });
                        },
                    );
                    #ok;
                };
                case (#completed(_)) return #err(#gameComplete);
            };
        };

        public func startVote(
            prng : Prng,
            gameId : Nat,
            initiatingUserId : Principal,
        ) : Result.Result<(), { #gameNotFound; #gameAlreadyStarted; #notAuthorized }> {
            let ?instance = instances.get(gameId) else return #err(#gameNotFound);
            let #notStarted = instance.state else return #err(#gameAlreadyStarted);
            if (instance.hostUserId != initiatingUserId) {
                return #err(#notAuthorized);
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

            let timeStart = Time.now();
            let timeEnd : ?Time.Time = null;

            let members : [ExtendedProposal.Member] = [
                {
                    id = instance.hostUserId;
                    votingPower = 1;
                },
            ];

            instances.put(
                gameId,
                {
                    instance with
                    state = #voting(
                        {
                            startTime = timeStart;
                            var characterProposal = ExtendedProposal.create(0, instance.hostUserId, characterOptions, members, timeStart, timeEnd);
                        } : MutableVotingData
                    );
                },
            );
            #ok;
        };

        public func getScenario(gameId : Nat, scenarioId : Nat) : Result.Result<ScenarioWithMetaData, { #gameNotFound; #gameNotActive; #notFound }> {
            let ?instance = instances.get(gameId) else return #err(#gameNotFound);
            let #inProgress({ scenarioHandler; characterHandler }) = instance.state else return #err(#gameNotActive);
            let ?scenario = scenarioHandler.get(scenarioId) else return #err(#notFound);
            let character = characterHandler.get();
            #ok(mapScenario(scenario, character));
        };

        public func getScenarios(gameId : Nat) : Result.Result<[ScenarioWithMetaData], { #gameNotFound; #gameNotActive }> {
            let ?instance = instances.get(gameId) else return #err(#gameNotFound);
            let #inProgress({ scenarioHandler; characterHandler }) = instance.state else return #err(#gameNotActive);
            let character = characterHandler.get();
            let scenariosWithMetaData = scenarioHandler.getAll().vals()
            |> Iter.map<ScenarioHandler.ScenarioInstance, ScenarioWithMetaData>(
                _,
                func(scenario : ScenarioHandler.ScenarioInstance) : ScenarioWithMetaData = mapScenario(scenario, character),
            )
            |> Iter.toArray(_);
            #ok(scenariosWithMetaData);
        };

        public func voteOnScenario(
            gameId : Nat,
            scenarioId : Nat,
            voterId : Principal,
            choiceId : Text,
        ) : Result.Result<?Text, ScenarioHandler.VoteError or { #gameNotFound; #gameNotActive; #choiceRequirementNotMet }> {
            let ?instance = instances.get(gameId) else return #err(#gameNotFound);
            let #inProgress({ scenarioHandler; characterHandler }) = instance.state else return #err(#gameNotActive);
            let ?scenario = scenarioHandler.get(scenarioId) else return #err(#scenarioNotFound);
            let ?scenarioMetaData = scenarios.get(scenario.metaDataId) else Debug.trap("Scenario meta data not found: " # scenario.metaDataId);
            let ?choice = Array.find(
                scenarioMetaData.choices,
                func(choice : Scenario.Choice) : Bool = choiceId == choice.id,
            ) else return #err(#invalidChoice);
            switch (choice.requirement) {
                case (null) ();
                case (?requirement) {
                    let character = characterHandler.get();
                    if (not Outcome.validateRequirement(requirement, character)) {
                        return #err(#choiceRequirementNotMet);
                    };
                };
            };

            scenarioHandler.vote(scenarioId, voterId, choiceId);
        };

        public func getScenarioVote(
            gameId : Nat,
            scenarioId : Nat,
            voterId : Principal,
        ) : Result.Result<ExtendedProposal.Vote<Text>, { #gameNotFound; #gameNotActive; #scenarioNotFound; #notEligible }> {
            let ?instance = instances.get(gameId) else return #err(#gameNotFound);
            let #inProgress({ scenarioHandler }) = instance.state else return #err(#gameNotActive);
            scenarioHandler.getVote(scenarioId, voterId);
        };

        public func getScenarioVoteSummary(gameId : Nat, scenarioId : Nat) : Result.Result<ExtendedProposal.VotingSummary<Text>, { #scenarioNotFound; #gameNotFound; #gameNotActive }> {
            let ?instance = instances.get(gameId) else return #err(#gameNotFound);
            let #inProgress({ scenarioHandler }) = instance.state else return #err(#gameNotActive);
            scenarioHandler.getVoteSummary(scenarioId);
        };

        public func voteOnNewGame(
            gameId : Nat,
            voterId : Principal,
            characterId : Text,
        ) : Result.Result<?{ characterId : Text }, ExtendedProposal.VoteError or { #gameNotFound; #gameNotActive; #invalidCharacterId }> {
            let ?instance = instances.get(gameId) else return #err(#gameNotFound);

            let #voting(voting) = instance.state else return #err(#gameNotActive);

            let ?characterIndex = NatX.fromText(characterId) else return #err(#invalidCharacterId);
            if (characterIndex >= voting.characterProposal.content.size()) {
                return #err(#invalidCharacterId);
            };
            let updatedCharacterProposal = switch (ExtendedProposal.vote(voting.characterProposal, voterId, characterId, true)) {
                case (#ok(ok)) ok.updatedProposal;
                case (#err(error)) return #err(error);
            };
            // Dont set unless both votes are successful
            voting.characterProposal := updatedCharacterProposal;

            let votingThreshold : ExtendedProposal.VotingThreshold = #percent({
                percent = 50;
                quorum = null;
            });
            let characterIdOrNull : ?Text = switch (
                ExtendedProposal.calculateVoteStatus(
                    voting.characterProposal,
                    votingThreshold,
                    Text.equal,
                    Text.hash,
                    false,
                )
            ) {
                case (#determined(characterIdOrNull)) characterIdOrNull;
                case (#undetermined) null;
            };
            let chosenCharacterId : Text = switch (characterIdOrNull) {
                case (?id) id;
                case (null) return #ok(null); // Vote still in progress
            };

            #ok(
                ?{
                    characterId = chosenCharacterId;
                }
            );
        };

        public func startGame<system>(
            prng : Prng,
            gameId : Nat,
            characterId : Text,
        ) : Result.Result<(), { #gameNotFound; #alreadyStarted; #invalidCharacterId }> {
            let ?instance = instances.get(gameId) else return #err(#gameNotFound);
            let #voting(voting) = instance.state else return #err(#alreadyStarted);
            let ?characterIndex = NatX.fromText(characterId) else return #err(#invalidCharacterId);
            let character = voting.characterProposal.content[characterIndex];

            let characterHandler = CharacterHandler.Handler({
                character = character;
            });
            let scenarioHandler = ScenarioHandler.Handler({
                instances = [];
                metaDataList = [];
            });
            let zoneId = prng.nextArrayElement(zones.vals() |> Iter.toArray(_)).id;
            let scenario = generateScenario(prng, zoneId);
            let members = buildMemberList(instance);
            let scenarioId = scenarioHandler.start(scenario, instance.hostUserId, members);
            let location : Location.Location = {
                id = 0;
                coordinate = { q = 0; r = 0 };
                scenarioId = scenarioId;
                zoneId = zoneId;
            };
            instances.put(
                gameId,
                {
                    instance with
                    state = #inProgress({
                        startTime = voting.startTime;
                        scenarioHandler = scenarioHandler;
                        characterHandler = characterHandler;
                        var turn = 0;
                        var locations = [location];
                    });
                },
            );
            #ok;
        };

        public func endTurn(
            prng : Prng,
            gameId : Nat,
            userHandler : UserHandler.Handler,
            choiceOrUndecided : ?Text,
        ) : Result.Result<(), { #gameNotFound; #gameNotActive }> {
            let ?instance = instances.get(gameId) else return #err(#gameNotFound);
            let #inProgress(inProgressInstance) = instance.state else return #err(#gameNotActive);

            let currentLocation = getCharacterLocation(inProgressInstance);

            let ?scenario = inProgressInstance.scenarioHandler.get(currentLocation.scenarioId) else Debug.trap("Scenario not found: " # Nat.toText(currentLocation.scenarioId));
            let ?scenarioMetaData = scenarios.get(scenario.metaDataId) else Debug.trap("Scenario meta data not found: " # scenario.metaDataId);
            let members = buildMemberList(instance);
            let result = ScenarioSimulator.run(
                prng,
                members,
                userHandler,
                inProgressInstance.characterHandler,
                scenario,
                scenarioMetaData,
                creatures,
                weapons,
                choiceOrUndecided,
            );
            let outcome : Outcome.Outcome = {
                choiceOrUndecided;
                log = result.log;
            };
            switch (inProgressInstance.scenarioHandler.end(currentLocation.scenarioId, outcome)) {
                case (#ok) ();
                case (#err(error)) Debug.trap("Unable to end scenario: " # debug_show (error));
            };
            switch (result.kind) {
                case (#inProgress) {
                    inProgressInstance.turn += 1;
                    switch (nextLocation(prng, instance.hostUserId, members, inProgressInstance)) {
                        case (?_) ();
                        case (null) {
                            instances.put(
                                gameId,
                                {
                                    instance with
                                    state = #completed({
                                        startTime = inProgressInstance.startTime;
                                        endTime = Time.now();
                                        turns = inProgressInstance.turn;
                                        character = inProgressInstance.characterHandler.get();
                                        victory = true;
                                    });
                                },
                            );
                        };
                    };
                };
                case (#defeat) {
                    instances.put(
                        gameId,
                        {
                            instance with
                            state = #completed({
                                startTime = inProgressInstance.startTime;
                                endTime = Time.now();
                                turns = inProgressInstance.turn;
                                character = inProgressInstance.characterHandler.get();
                                victory = false;
                            });
                        },
                    );
                };
            };
            #ok;
        };

        public func getInstance(gameId : Nat) : ?GameWithMetaData {
            let ?instance = instances.get(gameId) else return null;
            ?toInstanceWithMetaData(instance);
        };

        public func getCurrentInstance(userId : Principal) : ?GameWithMetaData {

            let instanceOrNull = instances.vals()
            |> Iter.filter<MutableGameInstance>(
                _,
                func(instance : MutableGameInstance) : Bool {
                    instance.hostUserId == userId or Array.indexOf(userId, instance.guestUserIds, Principal.equal) != null;
                },
            )
            |> Iter.sort(
                _,
                func(a : MutableGameInstance, b : MutableGameInstance) : Order.Order = Int.compare(b.createdTime, a.createdTime),
            )
            |> _.next();

            switch (instanceOrNull) {
                case (?instance) ?toInstanceWithMetaData(instance);
                case (null) null;
            };
        };

        public func getCompletedInstances(userId : Principal) : [CompletedGameWithMetaData] {
            instances.vals()
            |> Iter.filter<MutableGameInstance>(
                _,
                func(instance : MutableGameInstance) : Bool {
                    switch (instance.state) {
                        case (#completed(_)) instance.hostUserId == userId or Array.indexOf(userId, instance.guestUserIds, Principal.equal) != null;
                        case (_) false;
                    };
                },
            )
            |> Iter.map(_, toInstanceWithMetaData)
            |> Iter.map(
                _,
                func(instance : GameWithMetaData) : CompletedGameWithMetaData {
                    let #completed(state) = instance.state else Prelude.unreachable();
                    {
                        instance with
                        startTime = state.startTime;
                        endTime = state.endTime;
                        character = state.character;
                        turns = state.turns;
                        victory = state.victory;
                    };
                },
            )
            |> Iter.toArray(_);
        };

        public func addItem(item : Item.Item) : Result.Result<(), { #invalid : [Text] }> {
            switch (Item.validate(item, items)) {
                case (#err(errors)) return #err(#invalid(errors));
                case (#ok) ();
            };
            Debug.print("Adding item: " # item.id);
            items.put(item.id, item);
            #ok;
        };

        public func addTrait(trait : Trait.Trait) : Result.Result<(), { #invalid : [Text] }> {
            switch (Trait.validate(trait, traits)) {
                case (#err(errors)) return #err(#invalid(errors));
                case (#ok) ();
            };
            Debug.print("Adding trait: " # trait.id);
            traits.put(trait.id, trait);
            #ok;
        };

        public func addRace(race : Race.Race) : Result.Result<(), { #invalid : [Text] }> {
            switch (Race.validate(race, races, items, traits)) {
                case (#err(errors)) return #err(#invalid(errors));
                case (#ok) ();
            };
            Debug.print("Adding race: " # race.id);
            races.put(race.id, race);
            #ok;
        };

        public func addClass(class_ : Class.Class) : Result.Result<(), { #invalid : [Text] }> {
            switch (Class.validate(class_, classes, items, traits, achievements)) {
                case (#err(errors)) return #err(#invalid(errors));
                case (#ok) ();
            };
            Debug.print("Adding class: " # class_.id);
            classes.put(class_.id, class_);
            #ok;
        };

        public func addScenarioMetaData(scenario : Scenario.ScenarioMetaData) : Result.Result<(), { #invalid : [Text] }> {
            switch (
                Scenario.validateMetaData(
                    scenario,
                    scenarios,
                    items,
                    traits,
                    images,
                    zones,
                    achievements,
                    creatures,
                )
            ) {
                case (#err(errors)) return #err(#invalid(errors));
                case (#ok) ();
            };
            Debug.print("Adding scenario meta data: " # scenario.id);
            scenarios.put(scenario.id, scenario);
            #ok;
        };

        public func addZone(zone : Zone.Zone) : Result.Result<(), { #invalid : [Text] }> {
            switch (Zone.validate(zone, zones)) {
                case (#err(errors)) return #err(#invalid(errors));
                case (#ok) ();
            };
            Debug.print("Adding zone: " # zone.id);
            zones.put(zone.id, zone);
            #ok;
        };

        public func addAchievement(achievement : Achievement.Achievement) : Result.Result<(), { #invalid : [Text] }> {
            switch (Achievement.validate(achievement, achievements)) {
                case (#err(errors)) return #err(#invalid(errors));
                case (#ok) ();
            };
            Debug.print("Adding achievement: " # achievement.id);
            achievements.put(achievement.id, achievement);
            #ok;
        };

        public func addCreature(creature : Creature.Creature) : Result.Result<(), { #invalid : [Text] }> {
            switch (Creature.validate(creature, creatures, weapons)) {
                case (#err(errors)) return #err(#invalid(errors));
                case (#ok) ();
            };
            Debug.print("Adding creature: " # creature.id);
            creatures.put(creature.id, creature);
            #ok;
        };

        public func addWeapon(weapon : Weapon.Weapon) : Result.Result<(), { #invalid : [Text] }> {
            switch (Weapon.validate(weapon, weapons)) {
                case (#err(errors)) return #err(#invalid(errors));
                case (#ok) ();
            };
            Debug.print("Adding weapon: " # weapon.id);
            weapons.put(weapon.id, weapon);
            #ok;
        };

        public func addImage(image : Image.Image) : Result.Result<(), { #invalid : [Text] }> {
            switch (Image.validate(image, images)) {
                case (#err(errors)) return #err(#invalid(errors));
                case (#ok) ();
            };

            Debug.print("Adding image: " # image.id);
            images.put(image.id, image);
            #ok;
        };

        public func getImage(imageId : Text) : ?Image.Image {
            images.get(imageId);
        };

        public func getScenarioMetaDataList() : [Scenario.ScenarioMetaData] {
            scenarios.vals() |> Iter.toArray(_);
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

        private func getCharacterLocation(inProgressInstance : MutableInProgressData) : Location.Location {
            inProgressInstance.locations.get(inProgressInstance.locations.size() - 1);
        };

        private func nextLocation(
            prng : Prng,
            proposerId : Principal,
            members : [ScenarioHandler.Member],
            inProgressInstance : MutableInProgressData,
        ) : ?Location.Location {
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
            let newScenario = generateScenario(prng, zoneId);
            let newScenarioId = inProgressInstance.scenarioHandler.start(newScenario, proposerId, members);
            let nextLocation = {
                id = HexGrid.axialCoordinateToIndex(nextCoordinate);
                coordinate = nextCoordinate;
                scenarioId = newScenarioId;
                zoneId = zoneId;
            };
            inProgressInstance.locations := Array.append(inProgressInstance.locations, [nextLocation]);
            ?nextLocation;
        };

        private func mapScenario(
            scenario : ScenarioHandler.ScenarioInstance,
            character : Character.Character,
        ) : ScenarioWithMetaData {
            let ?metaData = scenarios.get(scenario.metaDataId) else Debug.trap("Scenario meta data not found: " # scenario.metaDataId);
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
            let filteredScenarios = scenarios.vals()
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

        private func toInstanceWithMetaData(instance : MutableGameInstance) : GameWithMetaData {
            let state : GameStateWithMetaData = switch (instance.state) {
                case (#notStarted) #notStarted;
                case (#voting(voting)) {
                    let characterVotes = ExtendedProposal.buildVotingSummary(voting.characterProposal, Text.equal, Text.hash);
                    #voting({
                        startTime = voting.startTime;
                        characterOptions = voting.characterProposal.content.vals() |> Iter.map(_, toCharacterWithMetaData) |> Iter.toArray(_);
                        characterVotes;
                    });
                };
                case (#inProgress(inProgress)) {
                    let character = toCharacterWithMetaData(inProgress.characterHandler.get());
                    #inProgress({
                        startTime = inProgress.startTime;
                        turn = inProgress.turn;
                        locations = inProgress.locations;
                        character;
                    });
                };
                case (#completed(completed)) {
                    let turns = completed.turns;
                    let character = toCharacterWithMetaData(completed.character);
                    #completed({
                        startTime = completed.startTime;
                        turns;
                        character;
                        endTime = completed.endTime;
                        victory = completed.victory;
                    });
                };
            };
            {
                id = instance.id;
                hostUserId = instance.hostUserId;
                guestUserIds = instance.guestUserIds;
                createdTime = instance.createdTime;
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

    private func toMutableInstance(instance : GameInstance) : MutableGameInstance {
        let state = switch (instance.state) {
            case (#notStarted) #notStarted;
            case (#voting(voting)) {
                #voting(
                    {
                        startTime = voting.startTime;
                        var characterProposal = voting.characterProposal;
                    } : MutableVotingData
                );
            };
            case (#inProgress(inProgress)) {
                #inProgress(
                    {
                        startTime = inProgress.startTime;
                        scenarioHandler = ScenarioHandler.Handler(inProgress.scenarios);
                        characterHandler = CharacterHandler.Handler(inProgress.character);
                        var turn = inProgress.turn;
                        var locations = inProgress.locations;
                    } : MutableInProgressData
                );
            };
            case (#completed(completed)) #completed(completed);
        };
        {
            id = instance.id;
            hostUserId = instance.hostUserId;
            guestUserIds = instance.guestUserIds;
            createdTime = instance.createdTime;
            difficulty = instance.difficulty;
            state = state;
        };
    };

    private func fromMutableInstance(instance : MutableGameInstance) : GameInstance {
        let state : GameInstanceState = switch (instance.state) {
            case (#notStarted) #notStarted;
            case (#voting(voting)) {
                #voting({
                    startTime = voting.startTime;
                    characterProposal = voting.characterProposal;
                });
            };
            case (#inProgress(inProgress)) {
                #inProgress({
                    startTime = inProgress.startTime;
                    scenarios = inProgress.scenarioHandler.toStableData();
                    character = inProgress.characterHandler.toStableData();
                    turn = inProgress.turn;
                    locations = inProgress.locations;
                });
            };
            case (#completed(completed)) #completed(completed);
        };
        {
            id = instance.id;
            hostUserId = instance.hostUserId;
            guestUserIds = instance.guestUserIds;
            createdTime = instance.createdTime;
            difficulty = instance.difficulty;
            state = state;
        };
    };

    private func buildMemberList(instance : MutableGameInstance) : [ScenarioHandler.Member] {
        let members = Buffer.Buffer<ScenarioHandler.Member>(instance.guestUserIds.size() + 1);
        members.add({
            id = instance.hostUserId;
            votingPower = 1;
        });
        for (guestUserId in instance.guestUserIds.vals()) {
            members.add({
                id = guestUserId;
                votingPower = 1;
            });
        };
        Buffer.toArray(members);
    };

    private func toHashMap<T, K, V>(
        array : [T],
        func_ : (T) -> ((K, V)),
        hash : (K) -> Nat32,
        equal : (K, K) -> Bool,
    ) : HashMap.HashMap<K, V> {
        array.vals()
        |> Iter.map<T, (K, V)>(
            _,
            func_,
        )
        |> HashMap.fromIter<K, V>(_, array.size(), equal, hash);
    };
};
