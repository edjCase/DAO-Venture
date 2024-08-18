import WorldHandler "WorldHandler";
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
import Location "../models/Location";
import Scenario "../models/Scenario";
import Character "../models/Character";
import ExtendedProposal "mo:dao-proposal-engine/ExtendedProposal";
import IterTools "mo:itertools/Iter";
import CharacterGenerator "../CharacterGenerator";

module {
    type Prng = PseudoRandomX.PseudoRandomGenerator;

    public type StableData = {
        current : GameInstance;
        historical : [CompletedData];
        classes : [Character.Class];
        races : [Character.Race];
        scenarios : [Scenario.ScenarioMetaData];
        items : [Character.Item];
        traits : [Character.Trait];
    };

    public type GameInstance = {
        #notInitialized;
        #notStarted : NotStartedData;
        #inProgress : InProgressData;
        #completed : CompletedData;
    };

    public type NotStartedData = {
        // Two proposals because i dont want the combo of character and difficulty, but rather the individual votes
        characterProposal : ExtendedProposal.Proposal<[Character.Character], Nat>;
        difficultyProposal : ExtendedProposal.Proposal<{}, Difficulty>;
    };

    public type InProgressData = {
        difficulty : Difficulty;
        world : WorldHandler.StableData;
        scenarios : ScenarioHandler.StableData;
        character : CharacterHandler.StableData;
    };

    public type CompletedData = {
        turns : Nat;
        difficulty : Difficulty;
        character : Character.Character;
    };

    public type Difficulty = {
        #easy;
        #medium;
        #hard;
    };

    public type GameInstanceWithMetaData = {
        #notInitialized;
        #notStarted : {
            characterOptions : [CharacterWithMetaData];
            characterVotes : ExtendedProposal.VotingSummary<Nat>;
            difficultyVotes : ExtendedProposal.VotingSummary<Difficulty>;
        };
        #inProgress : {
            turn : Nat;
            locations : [Location.Location];
            characterLocationId : Nat;
            character : CharacterWithMetaData;
        };
        #completed : {
            turns : Nat;
            difficulty : Difficulty;
            character : CharacterWithMetaData;
        };
    };

    public type CharacterWithMetaData = {
        class_ : Character.Class;
        race : Character.Race;
        stats : Character.CharacterStats;
        items : [Character.Item];
        traits : [Character.Trait];
    };

    public type ScenarioWithMetaData = Scenario.Scenario and {
        metaData : Scenario.ScenarioMetaData;
    };

    type MutableGameInstance = {
        #notInitialized;
        #notStarted : MutableNotStartedData;
        #inProgress : MutableInProgressData;
        #completed : CompletedData;
    };

    type MutableNotStartedData = {
        var characterProposal : ExtendedProposal.Proposal<[Character.Character], Nat>;
        var difficultyProposal : ExtendedProposal.Proposal<{}, Difficulty>;
    };

    type MutableInProgressData = {
        difficulty : Difficulty;
        worldHandler : WorldHandler.Handler;
        scenarioHandler : ScenarioHandler.Handler;
        characterHandler : CharacterHandler.Handler;
    };

    public class Handler<system>(data : StableData) {
        var historical : [CompletedData] = data.historical;
        let classes = data.classes.vals()
        |> Iter.map<Character.Class, (Text, Character.Class)>(_, func(class_ : Character.Class) : (Text, Character.Class) = (class_.id, class_))
        |> HashMap.fromIter<Text, Character.Class>(_, data.classes.size(), Text.equal, Text.hash);

        let races = data.races.vals()
        |> Iter.map<Character.Race, (Text, Character.Race)>(_, func(race : Character.Race) : (Text, Character.Race) = (race.id, race))
        |> HashMap.fromIter<Text, Character.Race>(_, data.races.size(), Text.equal, Text.hash);

        let scenarios = data.scenarios.vals()
        |> Iter.map<Scenario.ScenarioMetaData, (Text, Scenario.ScenarioMetaData)>(_, func(scenario : Scenario.ScenarioMetaData) : (Text, Scenario.ScenarioMetaData) = (scenario.id, scenario))
        |> HashMap.fromIter<Text, Scenario.ScenarioMetaData>(_, data.scenarios.size(), Text.equal, Text.hash);

        let items = data.items.vals()
        |> Iter.map<Character.Item, (Text, Character.Item)>(_, func(item : Character.Item) : (Text, Character.Item) = (item.id, item))
        |> HashMap.fromIter<Text, Character.Item>(_, data.items.size(), Text.equal, Text.hash);

        let traits = data.traits.vals()
        |> Iter.map<Character.Trait, (Text, Character.Trait)>(_, func(trait : Character.Trait) : (Text, Character.Trait) = (trait.id, trait))
        |> HashMap.fromIter<Text, Character.Trait>(_, data.traits.size(), Text.equal, Text.hash);

        var instance : MutableGameInstance = switch (data.current) {
            case (#notInitialized) #notInitialized;
            case (#notStarted(notStarted)) {
                #notStarted({
                    var characterProposal = notStarted.characterProposal;
                    var difficultyProposal = notStarted.difficultyProposal;
                });
            };
            case (#inProgress(inProgress)) {
                let worldHandler = WorldHandler.Handler(inProgress.world);
                let characterHandler = CharacterHandler.Handler(inProgress.character);
                let scenarioHandler = ScenarioHandler.Handler<system>(inProgress.scenarios, characterHandler);
                #inProgress({
                    difficulty = inProgress.difficulty;
                    worldHandler = worldHandler;
                    scenarioHandler = scenarioHandler;
                    characterHandler = characterHandler;
                });
            };
            case (#completed(completed)) #completed(completed);
        };

        public func toStableData() : StableData {
            let current = fromMutableInstance(instance);
            {
                current;
                historical;
                classes = Iter.toArray(classes.vals());
                races = Iter.toArray(races.vals());
                scenarios = Iter.toArray(scenarios.vals());
                items = Iter.toArray(items.vals());
                traits = Iter.toArray(traits.vals());
            };
        };

        public func initialize(
            prng : Prng,
            proposerId : Principal,
            members : [ExtendedProposal.Member],
        ) : Result.Result<(), { #alreadyInitialized }> {
            let #notInitialized = instance else return #err(#alreadyInitialized);

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

            let timeStart = Time.now();
            let timeEnd : ?Time.Time = null;

            instance := #notStarted({
                var characterProposal = ExtendedProposal.create(0, proposerId, characterOptions, members, timeStart, timeEnd);
                var difficultyProposal = ExtendedProposal.create(0, proposerId, {}, members, timeStart, timeEnd);
            });
            #ok;
        };

        public func getScenario(scenarioId : Nat) : Result.Result<ScenarioWithMetaData, { #noActiveGame; #notFound }> {
            let #inProgress({ scenarioHandler }) = instance else return #err(#noActiveGame);
            let ?scenario = scenarioHandler.get(scenarioId) else return #err(#notFound);
            let scenarioMetaData = scenarios.get(scenario.metaDataId) else Debug.trap("Scenario meta data not found: " # scenario.metaDataId);
            #ok({
                scenario with
                metaData = scenarioMetaData;
            });
        };
        public func getScenarios() : Result.Result<[ScenarioWithMetaData], { #noActiveGame }> {
            let #inProgress({ scenarioHandler }) = instance else return #err(#noActiveGame);
            #ok(scenarioHandler.getAll());
        };

        public func voteOnScenario(scenarioId : Nat, voterId : Principal, choice : Text) : Result.Result<?Text, ScenarioHandler.VoteError or { #noActiveGame }> {
            let #inProgress({ scenarioHandler }) = instance else return #err(#noActiveGame);
            scenarioHandler.vote(scenarioId, voterId, choice);
        };

        public func getScenarioVote(scenarioId : Nat, voterId : Principal) : Result.Result<ExtendedProposal.Vote<Text>, { #scenarioNotFound; #notEligible; #noActiveGame }> {
            let #inProgress({ scenarioHandler }) = instance else return #err(#noActiveGame);
            scenarioHandler.getVote(scenarioId, voterId);
        };

        public func getScenarioVoteSummary(scenarioId : Nat) : Result.Result<ExtendedProposal.VotingSummary<Text>, { #scenarioNotFound; #noActiveGame }> {
            let #inProgress({ scenarioHandler }) = instance else return #err(#noActiveGame);
            scenarioHandler.getVoteSummary(scenarioId);
        };

        public func voteOnNewGame(
            voterId : Principal,
            characterId : Nat,
            difficulty : Difficulty,
        ) : Result.Result<?{ characterId : Nat; difficulty : Difficulty }, ExtendedProposal.VoteError or { #noActiveGame; #invalidCharacterId }> {
            let #notStarted(notStarted) = instance else return #err(#noActiveGame);

            if (characterId >= notStarted.characterProposal.content.size()) {
                return #err(#invalidCharacterId);
            };
            let updatedCharacterProposal = switch (ExtendedProposal.vote(notStarted.characterProposal, voterId, characterId)) {
                case (#ok(ok)) ok.updatedProposal;
                case (#err(error)) return #err(error);
            };
            let updatedDifficultyProposal = switch (ExtendedProposal.vote(notStarted.difficultyProposal, voterId, difficulty)) {
                case (#ok(ok)) ok.updatedProposal;
                case (#err(error)) return #err(error);
            };
            // Dont set unless both votes are successful
            notStarted.characterProposal := updatedCharacterProposal;
            notStarted.difficultyProposal := updatedDifficultyProposal;

            let votingThreshold : ExtendedProposal.VotingThreshold = #percent({
                percent = 50;
                quorum = null;
            });
            let characterIdOrNull : ?Nat = switch (
                ExtendedProposal.calculateVoteStatus(
                    notStarted.characterProposal,
                    votingThreshold,
                    equalNat,
                    Nat32.fromNat,
                    false,
                )
            ) {
                case (#determined(characterIdOrNull)) characterIdOrNull;
                case (#undetermined) null;
            };
            let chosenCharacterId : Nat = switch (characterIdOrNull) {
                case (?id) id;
                case (null) return #ok(null); // Vote still in progress
            };

            let difficultyOrNull : ?Difficulty = switch (
                ExtendedProposal.calculateVoteStatus(
                    notStarted.difficultyProposal,
                    votingThreshold,
                    difficultyEqual,
                    difficultyHash,
                    false,
                )
            ) {
                case (#determined(difficultyOrNull)) difficultyOrNull;
                case (#undetermined) null;
            };

            let chosenDifficulty : Difficulty = switch (difficultyOrNull) {
                case (?d) d;
                case (null) return #ok(null); // Vote still in progress
            };
            #ok(
                ?{
                    characterId = chosenCharacterId;
                    difficulty = chosenDifficulty;
                }
            );
        };

        public func startGame<system>(
            prng : Prng,
            characterId : Nat,
            proposerId : Principal,
            difficulty : Difficulty,
            members : [ScenarioHandler.Member],
        ) : Result.Result<(), { #alreadyStarted }> {
            let #notStarted(notStarted) = instance else return #err(#alreadyStarted);
            let character = notStarted.characterProposal.content[characterId];

            let characterHandler = CharacterHandler.Handler({
                character = character;
            });
            let scenarioHandler = ScenarioHandler.Handler<system>(
                {
                    instances = [];
                    metaDataList = [];
                },
                characterHandler,
            );
            let scenario = generateScenario(prng);
            let scenarioId = scenarioHandler.start(scenario, proposerId, members);
            let location : Location.Location = {
                id = 0;
                coordinate = { q = 0; r = 0 };
                scenarioId = scenarioId;
            };
            let worldHandler = WorldHandler.Handler({
                characterLocationId = 0;
                turn = 0;
                locations = [location];
            });
            instance := #inProgress({
                difficulty;
                worldHandler = worldHandler;
                scenarioHandler = scenarioHandler;
                characterHandler = characterHandler;
            });
            #ok;
        };

        public func endTurn(
            prng : Prng,
            proposerId : Principal,
            members : [ScenarioHandler.Member],
            choiceOrUndecided : ?Text,
        ) : Result.Result<(), { #noActiveGame }> {
            let #inProgress({ worldHandler; scenarioHandler }) = instance else return #err(#noActiveGame);
            switch (scenarioHandler.end(prng, worldHandler.getCharacterLocation().scenarioId, choiceOrUndecided)) {
                case (#ok) ();
                case (#err(error)) Debug.trap("Unable to end scenario: " # debug_show (error));
            };
            let scenario = generateScenario(prng);
            let newScenarioId = scenarioHandler.start(scenario, proposerId, members);
            worldHandler.nextTurn(newScenarioId);
            #ok;
        };

        public func getInstance() : GameInstanceWithMetaData {
            toInstanceWithMetaData(instance);
        };

        private func generateScenario(prng : Prng) : {
            metaDataId : Text;
            data : [Scenario.GeneratedDataFieldInstance];
        } {
            let scenarioMetaData = prng.nextArrayElement(Iter.toArray(scenarios.vals()));
            let scenarioData = scenarioMetaData.data.vals()
            |> Iter.map<Scenario.GeneratedDataField, Scenario.GeneratedDataFieldInstance>(
                _,
                func(field : Scenario.GeneratedDataField) : Scenario.GeneratedDataFieldInstance {
                    let value = switch (field.value) {
                        case (#nat(nat)) #nat(prng.nextNat(nat.min, nat.max));
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

        private func toInstanceWithMetaData(instance : MutableGameInstance) : GameInstanceWithMetaData {
            switch (instance) {
                case (#notInitialized) #notInitialized;
                case (#notStarted(notStarted)) {
                    let characterVotes = ExtendedProposal.buildVotingSummary(notStarted.characterProposal, equalNat, Nat32.fromNat);
                    let difficultyVotes = ExtendedProposal.buildVotingSummary(notStarted.difficultyProposal, difficultyEqual, difficultyHash);
                    #notStarted({
                        characterOptions = notStarted.characterProposal.content.vals() |> Iter.map(_, toCharacterWithMetaData) |> Iter.toArray(_);
                        characterVotes;
                        difficultyVotes;
                    });
                };
                case (#inProgress(inProgress)) {
                    let turn = inProgress.worldHandler.getTurn();
                    let locations = inProgress.worldHandler.getLocations();
                    let characterLocationId = inProgress.worldHandler.getCharacterLocation().id;
                    let character = toCharacterWithMetaData(inProgress.characterHandler.get());
                    #inProgress({
                        turn;
                        locations;
                        characterLocationId;
                        character;
                    });
                };
                case (#completed(completed)) {
                    let turns = completed.turns;
                    let difficulty = completed.difficulty;
                    let character = toCharacterWithMetaData(completed.character);
                    #completed({ turns; difficulty; character });
                };
            };
        };

        private func toCharacterWithMetaData(
            character : Character.Character
        ) : CharacterWithMetaData {
            let ?class_ = classes.get(character.classId) else Debug.trap("Class not found: " # character.classId);
            let ?race = classes.get(character.raceId) else Debug.trap("Race not found: " # character.raceId);
            let itemsWithMetaData = Trie.iter(character.itemIds)
            |> Iter.map(
                _,
                func((itemId, _) : (Text, ())) : Character.Item {
                    let ?item = items.get(itemId) else Debug.trap("Item not found: " # itemId);
                    item;
                },
            )
            |> Iter.toArray(_);

            let traitsWithMetaData = Trie.iter(character.traitIds)
            |> Iter.map(
                _,
                func((traitId, _) : (Text, ())) : Character.Trait {
                    let ?trait = traits.get(traitId) else Debug.trap("Trait not found: " # traitId);
                    trait;
                },
            )
            |> Iter.toArray(_);
            {
                health = character.health;
                gold = character.gold;
                class_ = class_;
                race = race;
                stats = character.stats;
                items = itemsWithMetaData;
                traits = traitsWithMetaData;
            };
        };

    };

    private func fromMutableInstance(instance : MutableGameInstance) : GameInstance {
        switch (instance) {
            case (#notInitialized) #notInitialized;
            case (#notStarted(notStarted)) {
                #notStarted({
                    characterProposal = notStarted.characterProposal;
                    difficultyProposal = notStarted.difficultyProposal;
                });
            };
            case (#inProgress(inProgress)) {
                #inProgress({
                    difficulty = inProgress.difficulty;
                    world = inProgress.worldHandler.toStableData();
                    scenarios = inProgress.scenarioHandler.toStableData();
                    character = inProgress.characterHandler.toStableData();
                });
            };
            case (#completed(completed)) #completed(completed);
        };
    };

    private func equalNat(a : Nat, b : Nat) : Bool {
        a == b;
    };

    private func difficultyEqual(a : Difficulty, b : Difficulty) : Bool {
        a == b;
    };

    private func difficultyHash(difficulty : Difficulty) : Nat32 {
        switch (difficulty) {
            case (#easy) 0;
            case (#medium) 1;
            case (#hard) 2;
        };
    };
};
