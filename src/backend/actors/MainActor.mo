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
import Prelude "mo:base/Prelude";
import Random "mo:base/Random";
import WorldDao "../models/WorldDao";
import CommonTypes "../CommonTypes";
import GameHandler "../handlers/GameHandler";
import HttpHandler "../handlers/HttpHandler";
import Scenario "../models/entities/Scenario";
import Trait "../models/entities/Trait";
import Class "../models/entities/Class";
import Race "../models/entities/Race";
import Item "../models/entities/Item";

actor MainActor : Types.Actor {
    // Types  ---------------------------------------------------------
    type Prng = PseudoRandomX.PseudoRandomGenerator;

    type Duration = {
        #days : Nat;
    };

    // Stables ---------------------------------------------------------

    stable var gameStableData : GameHandler.StableData = {
        instances = [];
        classes = [];
        races = [];
        scenarios = [];
        items = [];
        traits = [];
        images = [];
        zones = [];
        achievements = [];
        creatures = [];
        weapons = [];
    };

    stable var worldDaoStableData : ProposalEngine.StableData<WorldDao.ProposalContent> = {
        proposalDuration = ? #days(3);
        proposals = [];
        votingThreshold = #percent({
            percent = 50;
            quorum = ?20;
        });
        allowVoteChange = false;
    };

    stable var userStableData : UserHandler.StableData = {
        users = [];
    };

    // Unstables ---------------------------------------------------------

    var gameHandler = GameHandler.Handler(gameStableData);

    var httpHandler = HttpHandler.Handler(gameHandler);

    var userHandler = UserHandler.Handler(userStableData);

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
        gameStableData := gameHandler.toStableData();
        worldDaoStableData := worldDao.toStableData();
        userStableData := userHandler.toStableData();
    };

    system func postupgrade() {
        gameHandler := GameHandler.Handler(gameStableData);
        worldDao := ProposalEngine.ProposalEngine<system, WorldDao.ProposalContent>(
            worldDaoStableData,
            onWorldProposalExecute,
            onWorldProposalReject,
            onWorldProposalValidate,
        );
        userHandler := UserHandler.Handler(userStableData);
    };

    // Public Methods ---------------------------------------------------------

    public shared ({ caller }) func createGame() : async Types.CreateGameResult {
        gameHandler.createInstance(caller);
    };

    public shared ({ caller }) func addUserToGame(request : Types.AddUserToGameRequest) : async Types.AddUserToGameResult {
        gameHandler.addUserToGame(request.gameId, caller, request.userId);
    };

    public shared ({ caller }) func startGameVote(request : Types.StartGameVoteRequest) : async Types.StartGameVoteResult {
        let prng = PseudoRandomX.fromBlob(await Random.blob(), #xorshift32);
        gameHandler.startVote(prng, request.gameId, caller);
    };

    public shared func addGameContent(request : Types.AddGameContentRequest) : async Types.AddGameContentResult {
        // TODO authorization check
        switch (request) {
            case (#item(item)) gameHandler.addItem(item);
            case (#trait(trait)) gameHandler.addTrait(trait);
            case (#image(image)) gameHandler.addImage(image);
            case (#scenario(scenario)) gameHandler.addScenarioMetaData(scenario);
            case (#race(race)) gameHandler.addRace(race);
            case (#class_(class_)) gameHandler.addClass(class_);
            case (#zone(zone)) gameHandler.addZone(zone);
            case (#achievement(achievement)) gameHandler.addAchievement(achievement);
            case (#creature(creature)) gameHandler.addCreature(creature);
            case (#weapon(weapon)) gameHandler.addWeapon(weapon);
        };
    };

    public shared ({ caller }) func voteOnNewGame(request : Types.VoteOnNewGameRequest) : async Types.VoteOnNewGameResult {
        let { characterId; difficulty } = switch (
            gameHandler.voteOnNewGame(
                request.gameId,
                caller,
                request.characterId,
                request.difficulty,
            )
        ) {
            case (#ok(null)) return #ok; // no consensus yet
            case (#ok(?newGameChoice)) newGameChoice; // Concensus reached
            case (#err(err)) return #err(err);
        };
        // Start the game if consensus reached
        let prng = PseudoRandomX.fromBlob(await Random.blob(), #xorshift32);
        let members = buildVotingMembersList();
        let proposerId = Principal.fromActor(MainActor); // Canister will be proposer for the first scenario
        switch (
            gameHandler.startGame<system>(
                prng,
                request.gameId,
                characterId,
                proposerId,
                difficulty,
                members,
            )
        ) {
            case (#ok) #ok;
            case (#err(err)) #err(err);
        };
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

    public query ({ caller }) func getScenario(request : Types.GetScenarioRequest) : async Types.GetScenarioResult {
        switch (gameHandler.getScenario(request.gameId, request.scenarioId)) {
            case (#ok(scenario)) #ok(mapScenario(request.gameId, caller, scenario));
            case (#err(err)) return #err(err);
        };
    };

    public query ({ caller }) func getScenarios(request : Types.GetScenariosRequest) : async Types.GetScenariosResult {
        switch (gameHandler.getScenarios(request.gameId)) {
            case (#err(err)) return #err(err);
            case (#ok(scenarios)) {
                let mappedScenarios = scenarios.vals()
                |> Iter.map(
                    _,
                    func(scenario : GameHandler.ScenarioWithMetaData) : Types.Scenario = mapScenario(request.gameId, caller, scenario),
                )
                |> Iter.toArray(_);
                #ok(mappedScenarios);
            };
        };
    };

    public shared query ({ caller }) func getScenarioVote(request : Types.GetScenarioVoteRequest) : async Types.GetScenarioVoteResult {
        getScenarioVoteInternal(request.gameId, caller, request.scenarioId);
    };

    public shared ({ caller }) func voteOnScenario(request : Types.VoteOnScenarioRequest) : async Types.VoteOnScenarioResult {
        switch (gameHandler.voteOnScenario(request.gameId, request.scenarioId, caller, request.value)) {
            case (#ok(null)) ();
            case (#ok(?choice)) {
                let prng = PseudoRandomX.fromBlob(await Random.blob(), #xorshift32);
                let members = buildVotingMembersList();
                let proposerId = Principal.fromActor(MainActor); // Canister will be proposer for the next scenario
                switch (gameHandler.endTurn(prng, request.gameId, proposerId, members, userHandler, ?choice)) {
                    case (#ok) ();
                    case (#err(#gameNotFound)) Prelude.unreachable();
                    case (#err(#gameNotActive)) Prelude.unreachable();
                };
            };
            case (#err(error)) return #err(error);
        };
        #ok;
    };

    public shared query func getGame(request : Types.GetGameRequest) : async Types.GetGameResult {
        switch (gameHandler.getInstance(request.gameId)) {
            case (?game) #ok(game);
            case (null) return #err(#gameNotFound);
        };
    };

    public shared query ({ caller }) func getCurrentGame() : async Types.GetCurrentGameResult {
        if (Principal.isAnonymous(caller)) {
            return #err(#notAuthenticated);
        };

        #ok(gameHandler.getCurrentInstance(caller));
    };

    public shared query ({ caller }) func getCompletedGames() : async [GameHandler.CompletedGameWithMetaData] {
        gameHandler.getCompletedInstances(caller);
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

    public query func getScenarioMetaDataList() : async [Scenario.ScenarioMetaData] {
        gameHandler.getScenarioMetaDataList();
    };

    public query func getTraits() : async [Trait.Trait] {
        gameHandler.getTraits();
    };

    public query func getClasses() : async [Class.Class] {
        gameHandler.getClasses();
    };

    public query func getRaces() : async [Race.Race] {
        gameHandler.getRaces();
    };

    public query func getItems() : async [Item.Item] {
        gameHandler.getItems();
    };

    public shared query func getTopUsers(request : Types.GetTopUsersRequest) : async Types.GetTopUsersResult {
        let result = userHandler.getTopUsers(request.count, request.offset);
        #ok(result);
    };

    public query func http_request(req : HttpHandler.HttpRequest) : async HttpHandler.HttpResponse {
        httpHandler.http_request(req);
    };

    public func http_request_update(req : HttpHandler.HttpUpdateRequest) : async HttpHandler.HttpResponse {
        httpHandler.http_request_update(req);
    };

    // Private Methods ---------------------------------------------------------

    private func mapScenario(
        gameId : Nat,
        voterId : Principal,
        scenario : GameHandler.ScenarioWithMetaData,
    ) : Types.Scenario {

        let voteData = switch (getScenarioVoteInternal(gameId, voterId, scenario.id)) {
            case (#ok(voteData)) voteData;
            case (#err(#gameNotFound)) Prelude.unreachable();
            case (#err(#gameNotActive)) Prelude.unreachable();
            case (#err(#scenarioNotFound)) Prelude.unreachable();
        };
        {
            scenario with
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

    private func getScenarioVoteInternal(gameId : Nat, voterId : Principal, scenarioId : Nat) : Types.GetScenarioVoteResult {
        let vote = switch (gameHandler.getScenarioVote(gameId, scenarioId, voterId)) {
            case (#ok(vote)) ?vote;
            case (#err(#notEligible)) null;
            case (#err(#scenarioNotFound)) return #err(#scenarioNotFound);
            case (#err(#gameNotFound)) return #err(#gameNotFound);
            case (#err(#gameNotActive)) return #err(#gameNotActive);
        };
        let { totalVotingPower; undecidedVotingPower; votingPowerByChoice } = switch (gameHandler.getScenarioVoteSummary(gameId, scenarioId)) {
            case (#err(#scenarioNotFound)) return #err(#scenarioNotFound);
            case (#err(#gameNotFound)) Prelude.unreachable();
            case (#err(#gameNotActive)) Prelude.unreachable();
            case (#ok(summary)) summary;
        };
        #ok({
            yourVote = vote;
            totalVotingPower = totalVotingPower;
            undecidedVotingPower = undecidedVotingPower;
            votingPowerByChoice = votingPowerByChoice;
        });
    };

    private func calculateVotingPower(_ : UserHandler.User) : Nat {
        // let basePower : Nat = 10;
        // let levelMultiplier : Nat = 5;
        // let timeMultiplier : Nat = 2;
        // let maxTimePower : Nat = 100;
        // let timeCap : Nat = 30 * 24 * 60 * 60 * 1_000_000_000; // 30 days in nanoseconds

        // // Power from level

        // let timeInWorld : Nat = Int.abs(Time.now() - user.inWorldSince) + 1;

        // // Power from time in world
        // let worldTime : Nat = Nat.min(timeInWorld, timeCap);
        // let worldTimePower : Nat = Int.abs(
        //     Float.toInt(
        //         Float.log(Float.fromInt(worldTime + 1)) / Float.log(Float.fromInt(timeCap)) * Float.fromInt(maxTimePower)
        //     )
        // );

        // // Combine powers
        // basePower + powerFromLevel + worldTimePower * timeMultiplier;
        // TODO
        1;
    };

};
