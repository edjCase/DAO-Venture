import WorldHandler "WorldHandler";
import ScenarioHandler "ScenarioHandler";
import CharacterHandler "CharacterHandler";
import PseudoRandomX "mo:xtended-random/PseudoRandomX";
import Debug "mo:base/Debug";
import Principal "mo:base/Principal";
import Result "mo:base/Result";
import Nat32 "mo:base/Nat32";
import Iter "mo:base/Iter";
import Trie "mo:base/Trie";
import Time "mo:base/Time";
import Location "../models/Location";
import Scenario "../models/Scenario";
import Character "../models/Character";
import ExtendedProposal "mo:dao-proposal-engine/ExtendedProposal";
import Item "../models/Item";
import Trait "../models/Trait";
import IterTools "mo:itertools/Iter";

module {
    type Prng = PseudoRandomX.PseudoRandomGenerator;

    public type StableData = {
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

    public type GameState = {
        #notInitialized;
        #notStarted : {
            characterOptions : [CharacterState];
            characterVotes : ExtendedProposal.VotingSummary<Nat>;
            difficultyVotes : ExtendedProposal.VotingSummary<Difficulty>;
        };
        #inProgress : {
            turn : Nat;
            locations : [Location.Location];
            characterLocationId : Nat;
            character : CharacterState;
        };
        #completed : {
            turns : Nat;
            difficulty : Difficulty;
            character : CharacterState;
        };
    };

    public type CharacterState = {
        health : Nat;
        gold : Nat;
        class_ : ClassState;
        race : RaceState;
        stats : Character.CharacterStats;
        items : [ItemState];
        traits : [TraitState];
    };

    public type ClassState = {
        name : Text;
        description : Text;
    };

    public type RaceState = {
        name : Text;
        description : Text;
    };

    public type ItemState = {
        name : Text;
        description : Text;
    };

    public type TraitState = {
        name : Text;
        description : Text;
    };

    type MutableGameStateKind = {
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

        var stateKind : MutableGameStateKind = switch (data) {
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
            switch (stateKind) {
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

        public func initialize(
            prng : Prng,
            proposerId : Principal,
            members : [ExtendedProposal.Member],
        ) : Result.Result<(), { #alreadyInitialized }> {
            let #notInitialized = stateKind else return #err(#alreadyInitialized);

            let content = IterTools.range(0, 4)
            |> Iter.map(_, func(_ : Nat) : Character.Character = Character.generate(prng))
            |> Iter.toArray(_);
            let timeStart = Time.now();
            let timeEnd : ?Time.Time = null;

            stateKind := #notStarted({
                var characterProposal = ExtendedProposal.create(0, proposerId, content, members, timeStart, timeEnd);
                var difficultyProposal = ExtendedProposal.create(0, proposerId, {}, members, timeStart, timeEnd);
            });
            #ok;
        };

        public func getScenario(scenarioId : Nat) : Result.Result<Scenario.Scenario, { #noActiveGame; #notFound }> {
            let #inProgress({ scenarioHandler }) = stateKind else return #err(#noActiveGame);
            let ?scenario = scenarioHandler.get(scenarioId) else return #err(#notFound);
            #ok(scenario);
        };
        public func getScenarios() : Result.Result<[Scenario.Scenario], { #noActiveGame }> {
            let #inProgress({ scenarioHandler }) = stateKind else return #err(#noActiveGame);
            #ok(scenarioHandler.getAll());
        };

        public func voteOnScenario(scenarioId : Nat, voterId : Principal, choice : Text) : Result.Result<?Text, ScenarioHandler.VoteError or { #noActiveGame }> {
            let #inProgress({ scenarioHandler }) = stateKind else return #err(#noActiveGame);
            scenarioHandler.vote(scenarioId, voterId, choice);
        };

        public func getScenarioVote(scenarioId : Nat, voterId : Principal) : Result.Result<ExtendedProposal.Vote<Text>, { #scenarioNotFound; #notEligible; #noActiveGame }> {
            let #inProgress({ scenarioHandler }) = stateKind else return #err(#noActiveGame);
            scenarioHandler.getVote(scenarioId, voterId);
        };

        public func getScenarioVoteSummary(scenarioId : Nat) : Result.Result<ExtendedProposal.VotingSummary<Text>, { #scenarioNotFound; #noActiveGame }> {
            let #inProgress({ scenarioHandler }) = stateKind else return #err(#noActiveGame);
            scenarioHandler.getVoteSummary(scenarioId);
        };

        public func voteOnNewGame(
            voterId : Principal,
            characterId : Nat,
            difficulty : Difficulty,
        ) : Result.Result<?{ characterId : Nat; difficulty : Difficulty }, ExtendedProposal.VoteError or { #noActiveGame; #invalidCharacterId }> {
            let #notStarted(notStarted) = stateKind else return #err(#noActiveGame);

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
            let #notStarted(notStarted) = stateKind else return #err(#alreadyStarted);
            let scenarioKind = ScenarioHandler.generateRandomKind(prng);
            let scenarioId = 0;
            let firstScenario = ScenarioHandler.create(scenarioId, scenarioKind, proposerId, members);
            let location : Location.Location = {
                id = 0;
                coordinate = { q = 0; r = 0 };
                scenarioId = scenarioId;
            };
            let character = notStarted.characterProposal.content[characterId];
            let characterHandler = CharacterHandler.Handler({
                character = character;
            });
            let scenarioHandler = ScenarioHandler.Handler<system>(
                {
                    scenarios = [firstScenario];
                },
                characterHandler,
            );
            let worldHandler = WorldHandler.Handler({
                characterLocationId = 0;
                turn = 0;
                locations = [location];
            });
            stateKind := #inProgress({
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
            let #inProgress({ worldHandler; scenarioHandler }) = stateKind else return #err(#noActiveGame);
            switch (scenarioHandler.end(prng, worldHandler.getCharacterLocation().scenarioId, choiceOrUndecided)) {
                case (#ok) ();
                case (#err(error)) Debug.trap("Unable to end scenario: " # debug_show (error));
            };

            let newScenarioId = scenarioHandler.generateAndStart(prng, proposerId, members);
            worldHandler.nextTurn(newScenarioId);
            #ok;
        };

        public func getState() : GameState {
            toGameState(stateKind);
        };

    };

    private func toGameState(stateKind : MutableGameStateKind) : GameState {
        switch (stateKind) {
            case (#notInitialized) #notInitialized;
            case (#notStarted(notStarted)) {
                let characterVotes = ExtendedProposal.buildVotingSummary(notStarted.characterProposal, equalNat, Nat32.fromNat);
                let difficultyVotes = ExtendedProposal.buildVotingSummary(notStarted.difficultyProposal, difficultyEqual, difficultyHash);
                #notStarted({
                    characterOptions = notStarted.characterProposal.content.vals() |> Iter.map(_, toCharacterState) |> Iter.toArray(_);
                    characterVotes;
                    difficultyVotes;
                });
            };
            case (#inProgress(inProgress)) {
                let turn = inProgress.worldHandler.getTurn();
                let locations = inProgress.worldHandler.getLocations();
                let characterLocationId = inProgress.worldHandler.getCharacterLocation().id;
                let character = toCharacterState(inProgress.characterHandler.get());
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
                let character = toCharacterState(completed.character);
                #completed({ turns; difficulty; character });
            };
        };
    };

    public func toCharacterState(character : Character.Character) : CharacterState {
        {
            health = character.health;
            gold = character.gold;
            class_ = Character.toStateClass(character.class_);
            race = Character.toStateRace(character.race);
            stats = character.stats;
            items = Trie.iter(character.items) |> Iter.map(_, func((item, _) : (Item.Item, ())) : Item.State = Item.toState(item)) |> Iter.toArray(_);
            traits = Trie.iter(character.traits) |> Iter.map(_, func((trait, _) : (Trait.Trait, ())) : Trait.State = Trait.toState(trait)) |> Iter.toArray(_);
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
