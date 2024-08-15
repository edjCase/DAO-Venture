import Principal "mo:base/Principal";
import Iter "mo:base/Iter";
import Nat "mo:base/Nat";
import Debug "mo:base/Debug";
import Text "mo:base/Text";
import Bool "mo:base/Bool";
import PseudoRandomX "mo:xtended-random/PseudoRandomX";
import Types "MainActorTypes";
import UserHandler "../handlers/UserHandler";
import ProposalEngine "mo:dao-proposal-engine/ProposalEngine";
import Proposal "mo:dao-proposal-engine/Proposal";
import Result "mo:base/Result";
import Time "mo:base/Time";
import Int "mo:base/Int";
import Float "mo:base/Float";
import Prelude "mo:base/Prelude";
import Random "mo:base/Random";
import TrieSet "mo:base/TrieSet";
import Trie "mo:base/Trie";
import WorldDao "../models/WorldDao";
import CommonTypes "../CommonTypes";
import MysteriousStructure "../scenarios/MysteriousStructure";
import GameHandler "../handlers/GameHandler";
import Character "../models/Character";
import Location "../models/Location";
import ScenarioHandler "../handlers/ScenarioHandler";
import Item "../models/Item";
import Trait "../models/Trait";
import Scenario "../models/Scenario";

actor MainActor : Types.Actor {
    // Types  ---------------------------------------------------------
    type Prng = PseudoRandomX.PseudoRandomGenerator;

    type Duration = {
        #days : Nat;
    };

    // Stables ---------------------------------------------------------

    stable var gameStableDataOrNull : ?GameHandler.StableData = null;

    stable var worldDaoStableData : ProposalEngine.StableData<WorldDao.ProposalContent> = {
        proposalDuration = ? #days(3);
        proposals = [];
        votingThreshold = #percent({
            percent = 50;
            quorum = ?20;
        });
    };

    stable var userStableData : UserHandler.StableData = {
        users = [];
    };

    // Unstables ---------------------------------------------------------

    var gameHandlerOrNull : ?GameHandler.Handler = null;

    var userHandler = UserHandler.UserHandler(userStableData);

    func onWorldProposalExecute(proposal : ProposalEngine.Proposal<WorldDao.ProposalContent>) : async* Result.Result<(), Text> {
        // TODO change world proposal for town data to be a simple approve w/ callback. Dont need to expose all the update routes
        switch (proposal.content) {
            case (#motion(_)) {
                // Do nothing
                #ok;
            };
        };
    };
    func onWorldProposalReject(_ : ProposalEngine.Proposal<WorldDao.ProposalContent>) : async* () {}; // TODO
    func onWorldProposalValidate(_ : WorldDao.ProposalContent) : async* Result.Result<(), [Text]> {
        #ok; // TODO
    };
    var worldDao = ProposalEngine.ProposalEngine<system, WorldDao.ProposalContent>(
        worldDaoStableData,
        onWorldProposalExecute,
        onWorldProposalReject,
        onWorldProposalValidate,
    );

    // System Methods ---------------------------------------------------------

    system func preupgrade() {
        gameStableDataOrNull := switch (gameHandlerOrNull) {
            case (?gameHandler) ?gameHandler.toStableData();
            case (null) null;
        };
        worldDaoStableData := worldDao.toStableData();
        userStableData := userHandler.toStableData();
    };

    system func postupgrade() {
        gameHandlerOrNull := switch (gameStableDataOrNull) {
            case (?gameStableData) ?GameHandler.Handler<system>(gameStableData, Principal.fromActor(MainActor));
            case (null) null;
        };
        worldDao := ProposalEngine.ProposalEngine<system, WorldDao.ProposalContent>(
            worldDaoStableData,
            onWorldProposalExecute,
            onWorldProposalReject,
            onWorldProposalValidate,
        );
        userHandler := UserHandler.UserHandler(userStableData);
    };

    // Public Methods ---------------------------------------------------------

    // TODO remove
    public shared func nextTurn() : async Types.NextTurnResult {
        let ?gameHandler = gameHandlerOrNull else return #err(#noActiveInstance);
        let prng = PseudoRandomX.fromBlob(await Random.blob(), #xorshift32);
        let members = buildVotingMembersList();
        gameHandler.nextTurn(prng, members);
        #ok;
    };

    public shared func startGame() : async Types.StartGameResult {
        let null = gameHandlerOrNull else return #err(#alreadyStarted);
        // TODO restrict to DAO proposal approval

        let prng = PseudoRandomX.fromBlob(await Random.blob(), #xorshift32);

        let character : Character.Character = {
            gold = 0;
            health = 100;
            items = TrieSet.empty();
            traits = TrieSet.empty();
            weaponLevel = 0;
        };
        let scenario = #mysteriousStructure(MysteriousStructure.generate(prng)); // TODO
        let location : Location.Location = {
            id = 0;
            coordinate = { q = 0; r = 0 };
            scenarioId = 0;
        };
        let members = buildVotingMembersList();
        let stableData : GameHandler.StableData = {
            world = {
                turn = 0;
                locations = [location];
                characterLocationId = 0;
            };
            scenarios = {
                scenarios = [ScenarioHandler.create(0, scenario, Principal.fromActor(MainActor), members)];
            };
            character = {
                character = character;
            };
        };
        gameHandlerOrNull := ?GameHandler.Handler<system>(stableData, Principal.fromActor(MainActor));
        #ok;
    };

    public shared ({ caller }) func join() : async Result.Result<(), Types.JoinError> {
        // TODO restrict to NFT?/TOken holders
        userHandler.add(caller);
    };

    public shared query func getWorldProposal(id : Nat) : async Types.GetWorldProposalResult {
        switch (worldDao.getProposal(id)) {
            case (?proposal) return #ok(proposal);
            case (null) return #err(#proposalNotFound);
        };
    };

    public shared query func getWorldProposals(count : Nat, offset : Nat) : async CommonTypes.PagedResult<Types.WorldProposal> {
        worldDao.getProposals(count, offset);
    };

    public shared ({ caller }) func createWorldProposal(request : Types.CreateWorldProposalRequest) : async Types.CreateWorldProposalResult {
        let members = buildVotingMembersList();

        let isAMember = members.vals()
        |> Iter.filter(
            _,
            func(member : Proposal.Member) : Bool = member.id == caller,
        )
        |> _.next() != null;
        if (not isAMember) {
            return #err(#notEligible);
        };
        Debug.print("Creating proposal for world with content: " # debug_show (request));
        await* worldDao.createProposal<system>(caller, request, members);
    };

    public shared ({ caller }) func voteOnWorldProposal(request : Types.VoteOnWorldProposalRequest) : async Types.VoteOnWorldProposalResult {
        await* worldDao.vote(request.proposalId, caller, request.vote);
    };

    public query ({ caller }) func getScenario(scenarioId : Nat) : async Types.GetScenarioResult {
        let ?gameHandler = gameHandlerOrNull else return #err(#noActiveGame);
        let ?scenario = gameHandler.getScenario(scenarioId) else return #err(#notFound);
        #ok(mapScenario(caller, scenario));
    };

    public query ({ caller }) func getScenarios() : async Types.GetScenariosResult {
        let ?gameHandler = gameHandlerOrNull else return #err(#noActiveGame);
        let scenarios = gameHandler.getScenarios().vals()
        |> Iter.map(
            _,
            func(scenario : Scenario.Scenario) : Types.Scenario = mapScenario(caller, scenario),
        )
        |> Iter.toArray(_);
        #ok(scenarios);
    };

    public shared query ({ caller }) func getScenarioVote(request : Types.GetScenarioVoteRequest) : async Types.GetScenarioVoteResult {
        getScenarioVoteInternal(caller, request.scenarioId);
    };

    public shared ({ caller }) func voteOnScenario(request : Types.VoteOnScenarioRequest) : async Types.VoteOnScenarioResult {
        let ?gameHandler = gameHandlerOrNull else return #err(#noActiveGame);
        gameHandler.vote(request.scenarioId, caller, request.value);
    };

    public shared query func getGameState() : async Types.GetGameStateResult {
        let ?gameHandler = gameHandlerOrNull else return #err(#noActiveGame);
        let gameState = gameHandler.getState();
        let character : Types.Character = {
            gold = gameState.character.gold;
            health = gameState.character.health;
            items = Trie.iter(gameState.character.items)
            |> Iter.map(
                _,
                func((item, _) : (Item.Item, ())) : Types.Item = {
                    id = Item.toId(item);
                    name = Item.toText(item);
                    description = Item.toDescription(item);
                },
            )
            |> Iter.toArray(_);
            traits = Trie.iter(gameState.character.traits)
            |> Iter.map(
                _,
                func((trait, _) : (Trait.Trait, ())) : Types.Trait = {
                    id = Trait.toId(trait);
                    name = Trait.toText(trait);
                    description = Trait.toDescription(trait);
                },
            )
            |> Iter.toArray(_);
        };
        #ok({
            locations = gameState.locations;
            turn = gameState.turn;
            characterLocationId = gameState.characterLocationId;
            character = character;
        });
    };

    public shared query func getUser(userId : Principal) : async Types.GetUserResult {
        let ?user = userHandler.get(userId) else return #err(#notFound);
        #ok(user);
    };

    public shared query func getUsers(request : Types.GetUsersRequest) : async Types.GetUsersResult {
        let users = switch (request) {
            case (#all) userHandler.getAll();
        };
        #ok(users);
    };

    public shared query func getUserStats() : async Types.GetUserStatsResult {
        let stats = userHandler.getStats();
        #ok(stats);
    };

    public shared query func getTopUsers(request : Types.GetTopUsersRequest) : async Types.GetTopUsersResult {
        let result = userHandler.getTopUsers(request.count, request.offset);
        #ok(result);
    };

    type VotingMemberInfo = {
        id : Principal;
        votingPower : Nat;
    };

    // Private Methods ---------------------------------------------------------

    private func mapScenario(
        voterId : Principal,
        scenario : Scenario.Scenario,
    ) : Types.Scenario {

        let (title, description, options) = switch (scenario.kind) {
            case (#mysteriousStructure(mysteriousStructure)) {
                let title = MysteriousStructure.getTitle();
                let description = MysteriousStructure.getDescription();
                let options = MysteriousStructure.getOptions();
                (title, description, options);
            };
        };
        let voteData = switch (getScenarioVoteInternal(voterId, scenario.id)) {
            case (#ok(voteData)) voteData;
            case (#err(#noActiveGame)) Prelude.unreachable();
            case (#err(#scenarioNotFound)) Prelude.unreachable();
        };
        {
            scenario with
            title = title;
            description = description;
            options = options;
            voteData = voteData;
        };
    };

    private func buildVotingMembersList() : [Proposal.Member] {
        userHandler.getAll().vals()
        |> Iter.map(
            _,
            func(user : UserHandler.User) : Proposal.Member = {
                id = user.id;
                votingPower = calculateVotingPower(user);
            },
        )
        |> Iter.toArray(_);
    };

    private func getScenarioVoteInternal(voterId : Principal, scenarioId : Nat) : Types.GetScenarioVoteResult {
        let ?gameHandler = gameHandlerOrNull else return #err(#noActiveGame);
        let vote = switch (gameHandler.getVote(scenarioId, voterId)) {
            case (#ok(vote)) ?vote;
            case (#err(#notEligible)) null;
            case (#err(#scenarioNotFound)) return #err(#scenarioNotFound);
        };
        let { totalVotingPower; undecidedVotingPower; votingPowerByChoice } = switch (gameHandler.getVoteSummary(scenarioId)) {
            case (#err(#scenarioNotFound)) return #err(#scenarioNotFound);
            case (#ok(summary)) summary;
        };
        #ok({
            yourVote = vote;
            totalVotingPower = totalVotingPower;
            undecidedVotingPower = undecidedVotingPower;
            votingPowerByChoice = votingPowerByChoice;
        });
    };

    private func calculateVotingPower(user : UserHandler.User) : Nat {
        let basePower : Nat = 10;
        let levelMultiplier : Nat = 5;
        let timeMultiplier : Nat = 2;
        let maxTimePower : Nat = 100;
        let timeCap : Nat = 30 * 24 * 60 * 60 * 1_000_000_000; // 30 days in nanoseconds

        // Power from level
        let powerFromLevel : Nat = user.level * levelMultiplier;

        let timeInWorld : Nat = Int.abs(Time.now() - user.inWorldSince) + 1;

        // Power from time in world
        let worldTime : Nat = Nat.min(timeInWorld, timeCap);
        let worldTimePower : Nat = Int.abs(
            Float.toInt(
                Float.log(Float.fromInt(worldTime + 1)) / Float.log(Float.fromInt(timeCap)) * Float.fromInt(maxTimePower)
            )
        );

        // Combine powers
        basePower + powerFromLevel + worldTimePower * timeMultiplier;
    };

};
