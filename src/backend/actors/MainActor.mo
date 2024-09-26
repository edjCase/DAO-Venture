import Principal "mo:base/Principal";
import Iter "mo:base/Iter";
import Nat "mo:base/Nat";
import Text "mo:base/Text";
import Bool "mo:base/Bool";
import PseudoRandomX "mo:xtended-random/PseudoRandomX";
import Types "MainActorTypes";
import UserHandler "../handlers/UserHandler";
import ProposalEngine "mo:dao-proposal-engine/ProposalEngine";
import Proposal "mo:dao-proposal-engine/Proposal";
import Result "mo:base/Result";
import Random "mo:base/Random";
import Buffer "mo:base/Buffer";
import TextX "mo:xtended-text/TextX";
import WorldDao "../models/WorldDao";
import CommonTypes "../CommonTypes";
import GameHandler "../handlers/GameHandler";
import Class "../models/entities/Class";
import Race "../models/entities/Race";
import Item "../models/entities/Item";
import ScenarioMetaData "../models/entities/ScenarioMetaData";
import Action "../models/entities/Action";
import Weapon "../models/entities/Weapon";
import Zone "../models/entities/Zone";
import Achievement "../models/entities/Achievement";
import Creature "../models/entities/Creature";

actor MainActor : Types.Actor {
    // Types  ---------------------------------------------------------
    type Prng = PseudoRandomX.PseudoRandomGenerator;

    // Stables ---------------------------------------------------------

    stable var gameStableData : GameHandler.StableData = {
        playerDataList = [];
        classes = [];
        races = [];
        scenarioMetaDataList = [];
        items = [];
        zones = [];
        achievements = [];
        creatures = [];
        weapons = [];
        actions = [];
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

    var userHandler = UserHandler.Handler(userStableData);

    func onWorldProposalExecute(proposal : ProposalEngine.Proposal<WorldDao.ProposalContent>) : async* Result.Result<(), Text> {
        switch (proposal.content) {
            case (#motion(_)) {
                // Do nothing
                #ok;
            };
            case (#modifyGameContent(modifyGameContent)) {
                let result = switch (modifyGameContent) {
                    case (#item(item)) gameHandler.addOrUpdateItem(item);
                    case (#scenario(scenario)) gameHandler.addOrUpdateScenarioMetaData(scenario);
                    case (#race(race)) gameHandler.addOrUpdateRace(race);
                    case (#class_(class_)) gameHandler.addOrUpdateClass(class_);
                    case (#zone(zone)) gameHandler.addOrUpdateZone(zone);
                    case (#achievement(achievement)) gameHandler.addOrUpdateAchievement(achievement);
                    case (#creature(creature)) gameHandler.addOrUpdateCreature(creature);
                    case (#weapon(weapon)) gameHandler.addOrUpdateWeapon(weapon);
                    case (#action(action)) gameHandler.addOrUpdateAction(action);
                };
                switch (result) {
                    case (#ok) #ok;
                    case (#err(err)) #err("Failed to modify game content: " # debug_show (err));
                };
            };
        };
    };

    func onWorldProposalReject(_ : ProposalEngine.Proposal<WorldDao.ProposalContent>) : async* () {}; // TODO
    func onWorldProposalValidate(content : WorldDao.ProposalContent) : async* Result.Result<(), [Text]> {
        switch (content) {
            case (#motion(motion)) {
                let errors = Buffer.Buffer<Text>(0);
                if (TextX.isEmpty(motion.title)) {
                    errors.add("Title cannot be empty");
                };
                if (TextX.isEmpty(motion.description)) {
                    errors.add("Description cannot be empty");
                };
                if (errors.size() > 0) {
                    #err(Buffer.toArray(errors));
                } else {
                    #ok;
                };
            };
            case (#modifyGameContent(modifyGameContent)) {
                switch (modifyGameContent) {
                    case (#item(item)) gameHandler.validateItem(item);
                    case (#scenario(scenario)) gameHandler.validateScenarioMetaData(scenario);
                    case (#race(race)) gameHandler.validateRace(race);
                    case (#class_(class_)) gameHandler.validateClass(class_);
                    case (#zone(zone)) gameHandler.validateZone(zone);
                    case (#achievement(achievement)) gameHandler.validateAchievement(achievement);
                    case (#creature(creature)) gameHandler.validateCreature(creature);
                    case (#weapon(weapon)) gameHandler.validateWeapon(weapon);
                    case (#action(action)) gameHandler.validateAction(action);
                };
            };
        };
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

    public shared ({ caller }) func createGame(_ : Types.CreateGameRequest) : async Types.CreateGameResult {
        let prng = PseudoRandomX.fromBlob(await Random.blob(), #xorshift32);
        if (Principal.isAnonymous(caller)) {
            return #err(#notAuthenticated);
        };
        gameHandler.createInstance(prng, caller);
    };

    public shared ({ caller }) func startGame(request : Types.StartGameRequest) : async Types.StartGameResult {
        let prng = PseudoRandomX.fromBlob(await Random.blob(), #xorshift32);
        gameHandler.startGame<system>(prng, caller, request.characterId);
    };

    public shared ({ caller }) func abandonGame() : async Types.AbandonGameResult {
        gameHandler.abandon(caller);
    };

    public shared ({ caller }) func register() : async Types.RegisterResult {
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
        await* worldDao.createProposal<system>(caller, request, members);
    };

    public shared ({ caller }) func voteOnWorldProposal(request : Types.VoteOnWorldProposalRequest) : async Types.VoteOnWorldProposalResult {
        await* worldDao.vote(request.proposalId, caller, request.vote);
    };

    public query ({ caller }) func getScenario(request : Types.GetScenarioRequest) : async Types.GetScenarioResult {
        gameHandler.getScenario(caller, request.scenarioId);
    };

    public query ({ caller }) func getScenarios() : async Types.GetScenariosResult {
        gameHandler.getScenarios(caller);
    };

    public shared ({ caller }) func selectScenarioChoice(request : Types.SelectScenarioChoiceRequest) : async Types.SelectScenarioChoiceResult {
        let prng = PseudoRandomX.fromBlob(await Random.blob(), #xorshift32);
        switch (
            gameHandler.selectScenarioChoice(
                prng,
                caller,
                userHandler,
                request.choice,
            )
        ) {
            case (#ok) #ok;
            case (#err(err)) #err(err);
        };
    };

    public shared query ({ caller }) func getCurrentGame() : async Types.GetCurrentGameResult {
        if (Principal.isAnonymous(caller)) {
            return #err(#notAuthenticated);
        };

        let game = gameHandler.getActiveInstance(caller);
        #ok(game);
    };

    public shared query ({ caller }) func getCompletedGames(request : Types.GetCompletedGamesRequest) : async CommonTypes.PagedResult<GameHandler.CompletedGameWithMetaData> {
        gameHandler.getCompletedGames(caller, request.offset, request.count);
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

    public query func getScenarioMetaDataList() : async [ScenarioMetaData.ScenarioMetaData] {
        gameHandler.getScenarioMetaDataList();
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

    public query func getActions() : async [Action.Action] {
        gameHandler.getActions();
    };

    public query func getWeapons() : async [Weapon.Weapon] {
        gameHandler.getWeapons();
    };

    public query func getZones() : async [Zone.Zone] {
        gameHandler.getZones();
    };

    public query func getAchievements() : async [Achievement.Achievement] {
        gameHandler.getAchievements();
    };

    public query func getCreatures() : async [Creature.Creature] {
        gameHandler.getCreatures();
    };

    public shared query func getTopUsers(request : Types.GetTopUsersRequest) : async Types.GetTopUsersResult {
        let result = userHandler.getTopUsers(request.count, request.offset);
        #ok(result);
    };

    // Private Methods ---------------------------------------------------------

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
