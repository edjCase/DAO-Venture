import Array "mo:base/Array";
import Principal "mo:base/Principal";
import Trie "mo:base/Trie";
import Prelude "mo:base/Prelude";
import Cycles "mo:base/ExperimentalCycles";
import IterTools "mo:itertools/Iter";
import Hash "mo:base/Hash";
import Player "../models/Player";
import Iter "mo:base/Iter";
import Nat32 "mo:base/Nat32";
import Nat "mo:base/Nat";
import StadiumTypes "../stadium/Types";
import Time "mo:base/Time";
import Nat64 "mo:base/Nat64";
import Int "mo:base/Int";
import Buffer "mo:base/Buffer";
import Random "mo:base/Random";
import Debug "mo:base/Debug";
import Error "mo:base/Error";
import Blob "mo:base/Blob";
import Order "mo:base/Order";
import Timer "mo:base/Timer";
import TrieSet "mo:base/TrieSet";
import Text "mo:base/Text";
import HashMap "mo:base/HashMap";
import PseudoRandomX "mo:random/PseudoRandomX";
import Types "Types";
import Util "../Util";
import ScheduleBuilder "ScheduleBuilder";
import UsersActor "canister:users";
import Team "../models/Team";
import TeamTypes "../team/Types";
import Season "../models/Season";
import MatchAura "../models/MatchAura";
import StadiumFactoryActor "canister:stadiumFactory";
import PlayerTypes "../players/Types";
import FieldPosition "../models/FieldPosition";
import UserTypes "../users/Types";
import Scenario "../models/Scenario";
import Trait "../models/Trait";
import SeasonHandler "SeasonHandler";
import PredictionHandler "PredictionHandler";
import ScenarioHandler "ScenarioHandler";
import TeamsHandler "TeamsHandler";
import PlayersActor "canister:players";
import TeamFactoryActor "canister:teamFactory";

actor LeagueActor {
    type TeamWithId = Team.TeamWithId;
    type Prng = PseudoRandomX.PseudoRandomGenerator;

    stable var stableData = {
        season : SeasonHandler.Data = {
            seasonStatus = #notStarted;
            teamStandings = null;
            predictions = [];
        };
        predictions : PredictionHandler.Data = {
            matchGroups = [];
        };
        scenarios : ScenarioHandler.Data = {
            scenarios = [];
        };
        teams : TeamsHandler.Data = {
            teams = [];
            teamFactoryInitialized = false;
        };
    };

    stable var admins : TrieSet.Set<Principal> = TrieSet.empty();
    stable var stadiumIdOrNull : ?Principal = null;
    stable var stadiumFactoryInitialized = false;

    var seasonHandler = SeasonHandler.SeasonHandler(stableData.season);
    var predictionHandler = PredictionHandler.Handler(stableData.predictions);
    var scenarioHandler = ScenarioHandler.Handler(stableData.scenarios);
    var teamsHandler = TeamsHandler.Handler(Principal.fromActor(LeagueActor), stableData.teams);

    system func preupgrade() {
        stableData := {
            season = seasonHandler.toStableData();
            predictions = predictionHandler.toStableData();
            scenarios = scenarioHandler.toStableData();
            teams = teamsHandler.toStableData();
        };
    };

    system func postupgrade() {
        seasonHandler := SeasonHandler.SeasonHandler(stableData.season);
        predictionHandler := PredictionHandler.Handler(stableData.predictions);
        scenarioHandler := ScenarioHandler.Handler(stableData.scenarios);
        teamsHandler := TeamsHandler.Handler(Principal.fromActor(LeagueActor), stableData.teams);
    };

    public query func getTeams() : async [TeamWithId] {
        teamsHandler.getAll();
    };

    // TODO REMOVE ALL DELETING METHODS
    public shared func clearTeams() : async () {
        teamsHandler := TeamsHandler.Handler(
            Principal.fromActor(LeagueActor),
            {
                teamFactoryInitialized = stableData.teams.teamFactoryInitialized;
                teams = [];
            },
        );
    };

    public query func getSeasonStatus() : async Season.SeasonStatus {
        seasonHandler.seasonStatus;
    };

    public query func getTeamStandings() : async Types.GetTeamStandingsResult {
        switch (seasonHandler.teamStandings) {
            case (?standings) return #ok(Buffer.toArray(standings));
            case (null) return #notFound;
        };
    };

    public query func getScenario(scenarioId : Text) : async Types.GetScenarioResult {
        switch (scenarioHandler.getScenario(scenarioId)) {
            case (null) #notFound;
            case (?scenario) {
                let options : [Types.ScenarioOption] = scenario.options
                |> Iter.fromArray(_)
                |> IterTools.mapEntries(
                    _,
                    func(i : Nat, option : Scenario.ScenarioOption) : Types.ScenarioOption {
                        {
                            id = i;
                            title = option.title;
                            description = option.description;
                        };
                    },
                )
                |> Iter.toArray(_);
                #ok({
                    id = scenario.id;
                    title = scenario.title;
                    description = scenario.description;
                    options = options;
                    state = scenario.state;
                });
            };
        };
    };

    public shared query ({ caller }) func getAdmins() : async [Principal] {
        TrieSet.toArray(admins);
    };

    public shared ({ caller }) func setUserIsAdmin(id : Principal, isAdmin : Bool) : async Types.SetUserIsAdminResult {
        if (Principal.isAnonymous(id)) {
            Debug.trap("Anonymous user is not a valid user");
        };

        // Check to make sure only admins can update other users
        // BUT if there are no admins, skip the check
        if (Trie.size(admins) > 0) {
            let callerIsAdmin = isAdminId(caller);
            if (not callerIsAdmin) {
                return #notAuthorized;
            };
        };
        let newAdmins = if (isAdmin) {
            TrieSet.put(admins, id, Principal.hash(id), Principal.equal);
        } else {
            TrieSet.delete(admins, id, Principal.hash(id), Principal.equal);
        };
        admins := newAdmins;
        #ok;
    };

    public shared ({ caller }) func startSeason(request : Types.StartSeasonRequest) : async Types.StartSeasonResult {
        if (not isAdminId(caller)) {
            return #notAuthorized;
        };
        Debug.print("Starting season");
        let seedBlob = try {
            await Random.blob();
        } catch (err) {
            return #seedGenerationError(Error.message(err));
        };

        let stadiumId = switch (await* getOrCreateStadium()) {
            case (#ok(id)) id;
            case (#stadiumCreationError(error)) return Debug.trap("Failed to create stadium: " # error);
        };
        let teamsArray = teamsHandler.getAll();

        let allPlayers = await PlayersActor.getAllPlayers();

        let scenarioIds = Buffer.Buffer<Text>(request.scenarios.size());
        for (scenario in Iter.fromArray(request.scenarios)) {
            switch (scenarioHandler.add(scenario)) {
                case (#ok) ();
                case (#idTaken) return #idTaken;
                case (#invalid(errors)) return #invalidScenario({
                    id = scenario.id;
                    errors = errors;
                });
            };
            scenarioIds.add(scenario.id);
        };

        let prng = PseudoRandomX.fromBlob(seedBlob);
        seasonHandler.startSeason(
            prng,
            stadiumId,
            request.startTime,
            Buffer.toArray(scenarioIds),
            teamsArray,
            allPlayers,
        );
    };

    public shared ({ caller }) func createTeam(request : Types.CreateTeamRequest) : async Types.CreateTeamResult {
        if (not isAdminId(caller)) {
            return #notAuthorized;
        };
        await* teamsHandler.create(request);
    };

    public shared ({ caller }) func predictMatchOutcome(request : Types.PredictMatchOutcomeRequest) : async Types.PredictMatchOutcomeResult {
        let ?currentMatchGroupId = seasonHandler.getCurrentMatchGroupId() else return #predictionsClosed;
        predictionHandler.predictMatchOutcome(
            currentMatchGroupId,
            request.matchId,
            caller,
            request.winner,
        );
    };

    public shared query ({ caller }) func getMatchGroupPredictions(matchGroupId : Nat) : async Types.GetMatchGroupPredictionsResult {
        predictionHandler.getMatchGroupSummary(matchGroupId, ?caller);
    };

    public shared ({ caller }) func updateLeagueCanisters() : async Types.UpdateLeagueCanistersResult {
        if (not isAdminId(caller)) {
            return #notAuthorized;
        };
        await TeamFactoryActor.updateCanisters();
        await StadiumFactoryActor.updateCanisters();
        #ok;
    };

    public shared ({ caller }) func processEffectOutcomes(effectOutcomes : [Scenario.EffectOutcome]) : async Types.ProcessEffectOutcomesResult {
        if (not isAdminId(caller)) {
            return #notAuthorized;
        };

        let playerOutcomes = Buffer.Buffer<Scenario.PlayerEffectOutcome>(effectOutcomes.size());
        for (effectOutcome in Iter.fromArray(effectOutcomes)) {
            switch (effectOutcome) {
                case (#injury(injuryEffect)) playerOutcomes.add(#injury(injuryEffect));
                case (#entropy(entropyEffect)) {
                    teamsHandler.updateTeamEntropy(entropyEffect.teamId, entropyEffect.delta);
                };
                case (#energy(e)) {
                    teamsHandler.updateTeamEnergy(e.teamId, e.delta);
                };
                case (#skill(s)) {
                    playerOutcomes.add(#skill(s));
                };
            };
        };
        // TODO handle failure
        if (playerOutcomes.size() > 0) {
            let result = try {
                await PlayersActor.applyEffects(Buffer.toArray(playerOutcomes));
            } catch (err) {
                return Debug.trap("Failed to apply traits: " # Error.message(err));
            };
            switch (result) {
                case (#ok) ();
            };
        };
        #ok;
    };

    public shared ({ caller }) func startMatchGroup(matchGroupId : Nat) : async Types.StartMatchGroupResult {
        // TODO
        // if (not isAdminId(caller)) {
        //     return #notAuthorized;
        // };
        let stadiumId = switch (await* getOrCreateStadium()) {
            case (#ok(id)) id;
            case (#stadiumCreationError(error)) return Debug.trap("Failed to create stadium: " # error);
        };
        let #inProgress(inProgressSeason) = seasonHandler.seasonStatus else return #notScheduledYet;
        let teams = inProgressSeason.teams;
        let teamScenarioData = Buffer.Buffer<ScenarioHandler.TeamScenarioData>(teams.size());

        for (team in Iter.fromArray(teams)) {
            let teamActor = actor (Principal.toText(team.id)) : TeamTypes.TeamActor;
            let options : TeamTypes.ScenarioVoteResult = try {
                // Get match options from the team itself
                let result : TeamTypes.GetWinningScenarioOptionResult = await teamActor.getWinningScenarioOption({
                    scenarioId = scenarioId;
                });
                let option = switch (result) {
                    case (#ok(o)) o;
                    case (#noVotes) {
                        // If no votes, pick a random choice
                        let option : Nat = 0; // TODO
                        option;
                    };
                    case (#scenarioNotFound) return Debug.trap("Scenario not found: " # scenarioId);
                    case (#notAuthorized) return Debug.trap("League is not authorized to get match options from team: " # Principal.toText(team.id));
                };
                {
                    option = option;
                };
            } catch (err : Error.Error) {
                return Debug.trap("Failed to get team '" # Principal.toText(team.id) # "': " # Error.message(err));
            };
            teamScenarioData.add({
                team with
                positions = {
                    firstBase = team.positions.firstBase.id;
                    secondBase = team.positions.secondBase.id;
                    thirdBase = team.positions.thirdBase.id;
                    shortStop = team.positions.shortStop.id;
                    leftField = team.positions.leftField.id;
                    centerField = team.positions.centerField.id;
                    rightField = team.positions.rightField.id;
                    pitcher = team.positions.pitcher.id;
                };
            });
        };

        let effectOutcomes = scenarioHandler.resolve(
            scenarioId,
            teamScenarioData,
            prng,
        );

        // TODO handle failure
        try {
            let result = await processEffectOutcomes(resolvedScenario.effectOutcomes);
            switch (result) {
                case (#ok) ();
                case (#notAuthorized) Debug.trap("League is not authorized to process effect outcomes");
                case (#seasonNotInProgress) Debug.trap("Season is not in progress");
            };
        } catch (err) {
            Debug.print("Failed to process effect outcomes: " # Error.message(err));
        };
        // TO HERE
        seasonHandler.startMatchGroup(matchGroupId, stadiumId);

    };

    public shared ({ caller }) func onMatchGroupComplete(
        request : Types.OnMatchGroupCompleteRequest
    ) : async Types.OnMatchGroupCompleteResult {
        if (not isStadium(caller)) {
            return #notAuthorized;
        };
        Debug.print("On Match group complete called for: " # Nat.toText(request.id));
        let ?stadiumId = stadiumIdOrNull else return #notAuthorized;
        if (caller != stadiumId) {
            return #notAuthorized;
        };

        let seed = try {
            await Random.blob();
        } catch (err) {
            return #seedGenerationError(Error.message(err));
        };
        let prng = PseudoRandomX.fromSeed(Blob.hash(seed));

        let result = await* seasonHandler.onMatchGroupComplete(request, prng);
        // TODO handle failure
        await* awardUserPoints(request.id, request.matches);
        result;
    };

    public shared ({ caller }) func closeSeason() : async Types.CloseSeasonResult {
        if (not isAdminId(caller)) {
            return #notAuthorized;
        };
        let result = await* seasonHandler.close();
        await* teamsHandler.onSeasonComplete();
        result;
    };

    private func awardUserPoints(
        matchGroupId : Nat,
        completedMatches : [Season.CompletedMatch],
    ) : async* () {
        // Award users points for their predictions
        let ?matchGroupPredictions = predictionHandler.getMatchGroup(matchGroupId) else Debug.trap("Match group predictions not found: " # Nat.toText(matchGroupId));
        let awards = Buffer.Buffer<UserTypes.AwardPointsRequest>(0);
        var i = 0;
        for (match in Iter.fromArray(completedMatches)) {
            let matchPredictions = matchGroupPredictions[i];
            i += 1;
            for (p in Iter.fromArray(matchPredictions)) {
                if (p.teamId == match.winner) {
                    // Award points
                    awards.add({
                        userId = p.userId;
                        points = 10; // TODO amount?
                    });
                };
            };
        };

        let error : ?Text = try {
            switch (await UsersActor.awardPoints(Buffer.toArray(awards))) {
                case (#ok) null;
                case (#notAuthorized) ?"League is not authorized to award user points";
            };
        } catch (err) {
            // TODO how to handle this?
            ?Error.message(err);
        };
        switch (error) {
            case (null) ();
            case (?error) Debug.print("Failed to award user points: " # error);
        };
    };

    private func isAdminId(id : Principal) : Bool {
        if (id == Principal.fromActor(LeagueActor)) {
            // League is admin
            return true;
        };
        TrieSet.mem(admins, id, Principal.hash(id), Principal.equal);
    };

    private func isStadium(id : Principal) : Bool {
        let ?stadiumId = stadiumIdOrNull else return false;
        id == stadiumId;
    };

    private func hashNatAsNat32(matchGroupId : Nat) : Nat32 {
        Nat32.fromNat(matchGroupId);
    };

    private func getOrCreateStadium() : async* {
        #ok : Principal;
        #stadiumCreationError : Text;
    } {
        switch (stadiumIdOrNull) {
            case (null) ();
            case (?id) return #ok(id);
        };

        if (not stadiumFactoryInitialized) {
            let #ok = await StadiumFactoryActor.setLeague(Principal.fromActor(LeagueActor)) else Debug.trap("Failed to set league on stadium factory");
            stadiumFactoryInitialized := true;
        };
        let createStadiumResult = try {
            await StadiumFactoryActor.createStadiumActor();
        } catch (err) {
            return #stadiumCreationError(Error.message(err));
        };
        switch (createStadiumResult) {
            case (#ok(id)) {
                stadiumIdOrNull := ?id;
                #ok(id);
            };
            case (#stadiumCreationError(error)) return #stadiumCreationError(error);
        };
    };

    private func buildPrincipalKey(id : Principal) : {
        key : Principal;
        hash : Hash.Hash;
    } {
        { key = id; hash = Principal.hash(id) };
    };

    private func arrayToIdTrie<T>(items : [T], getId : (T) -> Nat32) : Trie.Trie<Nat32, T> {
        var trie = Trie.empty<Nat32, T>();
        for (item in Iter.fromArray(items)) {
            let id = getId(item);
            let key = {
                key = id;
                hash = id;
            };
            let (newTrie, _) = Trie.put(trie, key, Nat32.equal, item);
            trie := newTrie;
        };
        trie;
    };

};
