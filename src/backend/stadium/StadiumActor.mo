import Player "../Player";
import Principal "mo:base/Principal";
import Team "../Team";
import Trie "mo:base/Trie";
import Hash "mo:base/Hash";
import Nat32 "mo:base/Nat32";
import Debug "mo:base/Debug";
import Prelude "mo:base/Prelude";
import Stadium "../Stadium";
import Nat "mo:base/Nat";
import Util "./StadiumUtil";
import Array "mo:base/Array";
import Buffer "mo:base/Buffer";
import Time "mo:base/Time";
import Iter "mo:base/Iter";
import TrieSet "mo:base/TrieSet";
import PlayerLedgerActor "canister:playerLedger";
import LiveStreamHubActor "canister:liveStreamHub";
import Order "mo:base/Order";
import Int "mo:base/Int";
import Timer "mo:base/Timer";
import MatchSimulator "MatchSimulator";
import Random "mo:base/Random";
import Error "mo:base/Error";
import Blob "mo:base/Blob";
import RandomX "mo:random/RandomX";
import PseudoRandomX "mo:random/PseudoRandomX";
import RandomUtil "../RandomUtil";
import League "../League";

actor class StadiumActor(leagueId : Principal) : async Stadium.StadiumActor = this {

    type Match = Stadium.Match;
    type MatchWithTimer = Stadium.MatchWithTimer;
    type MatchWithId = Stadium.MatchWithId;
    type MatchTeamInfo = Stadium.MatchTeamInfo;
    type Player = Player.Player;
    type PlayerWithId = Player.PlayerWithId;
    type PlayerState = Stadium.PlayerState;
    type FieldPosition = Player.FieldPosition;
    type MatchOptions = Stadium.MatchOptions;
    type Offering = Stadium.Offering;
    type MatchAura = Stadium.MatchAura;
    type Prng = PseudoRandomX.PseudoRandomGenerator;

    stable var matches : Trie.Trie<Nat32, MatchWithTimer> = Trie.empty();

    stable var nextMatchId : Nat32 = 1;

    public query func getMatch(id : Nat32) : async ?MatchWithId {
        switch (getMatchOrNull(id)) {
            case (null) return null;
            case (?m) {
                ?{ m with id = id; stadiumId = Principal.fromActor(this) };
            };
        };
    };

    public query func getMatches() : async [MatchWithId] {
        let compare = func(a : MatchWithId, b : MatchWithId) : Order.Order = Int.compare(a.time, b.time);
        let map = func(v : (Nat32, Match)) : MatchWithId = {
            v.1 with
            id = v.0;
            stadiumId = Principal.fromActor(this);
        };
        matches |> Trie.iter _ |> Iter.map(_, map) |> Iter.sort(_, compare) |> Iter.toArray(_);
    };

    public shared ({ caller }) func startMatch(matchId : Nat32) : async Stadium.StartMatchResult {
        // TODO: only can call itself after the designated time
        let ?match = getMatchOrNull(matchId) else return #matchNotFound;
        let (result, newMatch) = switch (await startMatchInternal(matchId, match)) {
            case (#matchAlreadyStarted) return #matchAlreadyStarted;
            case (#matchNotFound) return #matchNotFound;
            case (#completed(s)) {
                let newMatch : MatchWithTimer = {
                    match with
                    timer = null;
                    state = #completed(s);
                };
                (#completed(s), newMatch);
            };
            case (#ok(s)) {
                let timerId = Timer.recurringTimer(
                    #seconds(5),
                    func() : async () {
                        let _ = await tickMatch(matchId);
                    },
                );
                let newMatch : MatchWithTimer = {
                    match with
                    timerId = ?timerId;
                    state = #inProgress(s);
                };
                (#ok(s), newMatch);
            };
        };
        // Clear timer if set on original match
        switch (match.timerId) {
            case (null)();
            case (?timerId) Timer.cancelTimer(timerId);
        };
        addOrUpdateMatch(matchId, newMatch);
        result;
    };

    public shared ({ caller }) func scheduleMatch(request : Stadium.ScheduleMatchRequest) : async Stadium.ScheduleMatchResult {
        assertLeague(caller);
        if (not isTimeAvailable(request.time)) {
            return #timeNotAvailable;
        };
        if (request.team1Id == request.team2Id) {
            return #duplicateTeams;
        };
        let seedBlob = await Random.blob();
        let prng = PseudoRandomX.fromSeed(Blob.hash(seedBlob));
        let leagueActor = actor (Principal.toText(leagueId)) : League.LeagueActor;
        let teams = try {
            await leagueActor.getTeams();
        } catch (err) {
            return #teamFetchError(Error.message(err));
        };
        let team1OrNull = Array.find(teams, func(t : League.TeamInfo) : Bool { t.id == request.team1Id }) else return #teamNotFound(#team1);
        let team2OrNull = Array.find(teams, func(t : League.TeamInfo) : Bool { t.id == request.team2Id }) else return #teamNotFound(#team1);
        let (team1, team2) = switch ((team1OrNull, team2OrNull)) {
            case (null, null) return #teamNotFound(#bothTeams);
            case (null, ?_) return #teamNotFound(#team1);
            case (?_, null) return #teamNotFound(#team2);
            case (?t1, ?t2)(t1, t2);
        };
        let correctedTeamIds = Util.sortTeamIds((request.team1Id, request.team2Id));
        let timeDiff : Time.Time = request.time - Time.now();
        let natTimeDiff = if (timeDiff < 0) {
            1;
        } else {
            Int.abs(timeDiff);
        };
        let timerDuration = #nanoseconds(natTimeDiff);
        let matchId = nextMatchId; // This needs to be here to preserve the matchId value for the callback
        let callbackFunc = func() : async () {
            let message = switch (await startMatch(matchId)) {
                case (#matchAlreadyStarted) "Failed to start match: Match already started";
                case (#matchNotFound) "Failed to start match: Match not found";
                case (#completed(_)) "Failed to start match: Match completed";
                case (#ok(_)) "Started match: " # Nat32.toText(matchId);
            };
            Debug.print("Start Match Callback Result - " # message);
        };
        let timerId = Timer.setTimer(timerDuration, callbackFunc);
        let offerings = getRandomOfferings(4);
        let aura = getRandomMatchAura(prng);
        let match : Stadium.MatchWithTimer = {
            id = nextMatchId;
            time = request.time;
            team1 = {
                id = correctedTeamIds.0;
                name = team1.name;
                options = null;
                score = null;
                predictionVotes = 0;
            };
            team2 = {
                id = correctedTeamIds.1;
                name = team2.name;
                options = null;
                score = null;
                predictionVotes = 0;
            };
            offerings = offerings;
            aura = aura;
            timerId = ?timerId;
            state = #notStarted;
        };
        let nextMatchKey = {
            hash = nextMatchId;
            key = nextMatchId;
        };
        switch (Trie.put(matches, nextMatchKey, Nat32.equal, match)) {
            case (_, ?previous) Prelude.unreachable(); // Cant duplicate ids
            case (newMatches, _) {
                nextMatchId += 1;
                matches := newMatches;
                #ok(nextMatchKey.key);
            };
        };
    };

    private func startMatchInternal(matchId : Nat32, match : Match) : async Stadium.StartMatchResult {
        switch (match.state) {
            case (#completed(s)) return #completed(s);
            case (#inProgress(_)) return #matchAlreadyStarted;
            case (#notStarted) {};
        };
        let team1InitOrNull = await createTeamInit(matchId, match.team1);
        let team2InitOrNull = await createTeamInit(matchId, match.team2);
        let (team1Init, team2Init) : (MatchSimulator.TeamInitData, MatchSimulator.TeamInitData) = switch (team1InitOrNull, team2InitOrNull) {
            case (null, null) return #completed(#allAbsent);
            case (null, ?_) return #completed(#absentTeam(#team1));
            case (?_, null) return #completed(#absentTeam(#team2));
            case (?t1, ?t2)(t1, t2);
        };
        let seedBlob = await Random.blob();
        let { prng; seed } = RandomUtil.buildPrng(seedBlob);
        let team1IsOffense = prng.nextCoin();
        let initState = MatchSimulator.initState(match.aura, team1Init, team2Init, team1IsOffense, prng, seed);
        #ok(initState);
    };

    private func createTeamInit(matchId : Nat32, team : Stadium.MatchTeamInfo) : async ?MatchSimulator.TeamInitData {
        let teamPlayers = await PlayerLedgerActor.getTeamPlayers(?team.id);
        let teamActor = actor (Principal.toText(team.id)) : Team.TeamActor;
        let stadiumId = Principal.fromActor(this);
        let options : MatchOptions = try {
            // Get match options from the team itself
            let result = await teamActor.getMatchOptions(stadiumId, matchId);
            switch (result) {
                case (#noVotes) return null;
                case (#ok(o)) o;
                case (#notAuthorized) Debug.trap("Stadium is not authorized to get match options from team: " # Principal.toText(team.id));
            };
        } catch (err : Error.Error) {
            Debug.print("Failed to get team '" # Principal.toText(team.id) # "': " # Error.message(err));
            return null;
        };
        ?{
            id = team.id;
            name = team.name;
            players = teamPlayers;
            offering = options.offering;
            champion = options.champion;
        };
    };

    public shared ({ caller }) func tickMatch(matchId : Nat32) : async Stadium.TickMatchResult {
        let ?match = getMatchOrNull(matchId) else return #matchNotFound;
        let state = switch (match.state) {
            case (#completed(completedState)) return #completed(completedState);
            case (#inProgress(s)) s;
            case (#notStarted) return #notStarted;
        };
        let prng = PseudoRandomX.LinearCongruentialGenerator(state.currentSeed);
        let newState = MatchSimulator.tick(state, prng);
        switch (newState) {
            case (#completed(completedState)) {
                switch (match.timerId) {
                    case (null) {};
                    // Cancel timer if set
                    case (?timerId) Timer.cancelTimer(timerId);
                };
            };
            case (_) {};
        };
        addOrUpdateMatch(
            matchId,
            {
                match with
                state = newState;
            },
        );
        ignore LiveStreamHubActor.broadcast({
            matchId = matchId;
            state = newState;
        });
        #inProgress(state);
    };

    private func getMatchOrNull(matchId : Nat32) : ?MatchWithTimer {
        let matchKey = {
            hash = matchId;
            key = matchId;
        };
        Trie.get(matches, matchKey, Nat32.equal);
    };

    private func addOrUpdateMatch(matchId : Nat32, match : MatchWithTimer) {
        let matchKey = {
            hash = matchId;
            key = matchId;
        };
        let (newMatches, _) = Trie.replace(matches, matchKey, Nat32.equal, ?match);
        matches := newMatches;
    };

    private func getRandomOfferings(count : Nat) : [Stadium.Offering] {
        // TODO
        [
            #mischief(#shuffleAndBoost),
            #war(#b),
            #indulgence(#c),
            #pestilence(#d),
        ];
    };

    private func getRandomMatchAura(prng : Prng) : Stadium.MatchAura {
        // TODO
        let auras = Buffer.fromArray<Stadium.MatchAura>([
            #lowGravity,
            #explodingBalls,
            #fastBallsHardHits,
            #highBlessingsAndCurses,
        ]);
        prng.shuffleBuffer(auras);
        auras.get(0);
    };

    private func isTimeAvailable(time : Time.Time) : Bool {
        for ((matchId, match) in Trie.iter(matches)) {
            // TODO better time window detection
            if (Time.now() >= time or match.time == time) {
                return false;
            };
        };
        true;
    };

    private func buildNewMatch(
        teamId : Principal,
        match : Match,
        options : Stadium.MatchOptions,
    ) : { #ok : Match; #teamNotInMatch } {

        let teamInfo = if (match.team1.id == teamId) {
            match.team1;
        } else if (match.team2.id == teamId) {
            match.team2;
        } else {
            return #teamNotInMatch;
        };
        let newTeam : MatchTeamInfo = {
            teamInfo with
            options = ?options;
        };
        let newTeams = if (match.team1.id == teamId) {
            (newTeam, match.team2);
        } else {
            (match.team1, newTeam);
        };

        #ok({
            match with
            teams = newTeams;
        });
    };

    private func hashNat32(n : Nat32) : Hash.Hash {
        n;
    };

    private func assertLeague(caller : Principal) {
        if (caller != leagueId) {
            Debug.trap("Only the league can schedule matches");
        };
    };
};
