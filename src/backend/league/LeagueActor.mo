import Team "../Team";
import Array "mo:base/Array";
import Principal "mo:base/Principal";
import Trie "mo:base/Trie";
import Prelude "mo:base/Prelude";
import Cycles "mo:base/ExperimentalCycles";
import IterTools "mo:itertools/Iter";
import Hash "mo:base/Hash";
import Player "../Player";
import Iter "mo:base/Iter";
import Nat32 "mo:base/Nat32";
import Nat "mo:base/Nat";
import Stadium "../Stadium";
import TeamActor "../team/TeamActor";
import { ic } "mo:ic";
import Time "mo:base/Time";
import Nat8 "mo:base/Nat8";
import Nat64 "mo:base/Nat64";
import Int "mo:base/Int";
import Buffer "mo:base/Buffer";
import Random "mo:base/Random";
import Debug "mo:base/Debug";
import Error "mo:base/Error";
import Blob "mo:base/Blob";
import Token "mo:icrc1/ICRC1/Canisters/Token";
import ICRC1 "mo:icrc1/ICRC1";
import TimeZone "mo:datetime/TimeZone";
import LocalDateTime "mo:datetime/LocalDateTime";
import Components "mo:datetime/Components";
import DateTime "mo:datetime/DateTime";
import RandomX "mo:random/RandomX";
import PseudoRandomX "mo:random/PseudoRandomX";
import League "../League";
import Util "../Util";
import Division "../Division";
import DivisionActor "../division/DivisionActor";
import StadiumActor "../stadium/StadiumActor";

actor LeagueActor {
    type Division = League.Division;
    type DivisionWithId = League.DivisionWithId;
    type TeamWithId = Team.TeamWithId;
    type Prng = PseudoRandomX.PseudoRandomGenerator;
    type BuildDivisionRequestResult = {
        #ok : [Stadium.ScheduleMatchGroupRequest];
        #error : League.ScheduleDivisionError;
    };
    type BuildDivisionRequestResultWithId = {
        #ok : Stadium.ScheduleDivisionRequest;
        #error : League.ScheduleDivisionErrorResult;
    };

    stable var divisions : Trie.Trie<Principal, Division> = Trie.empty();
    stable var stadiumIdOrNull : ?Principal = null;

    public composite query func getTeams() : async [TeamWithId] {
        let allTeams = Buffer.Buffer<TeamWithId>(12);
        for ((divisionId, division) in Trie.iter(divisions)) {
            let divisionActor = actor (Principal.toText(divisionId)) : Division.DivisionActor;
            let divisionTeams = await divisionActor.getTeams();
            allTeams.append(Buffer.fromArray(divisionTeams));
        };
        Buffer.toArray(allTeams);
    };

    public query func getDivisions() : async [DivisionWithId] {
        Trie.toArray(
            divisions,
            func(k : Principal, v : Division) : DivisionWithId = {
                v with
                id = k;
            },
        );
    };

    public shared query ({ caller }) func getStadiums() : async [Stadium.StadiumWithId] {
        return switch (stadiumIdOrNull) {
            case (null)[];
            case (?id) { [{ id = id }] };
        };
    };

    public shared ({ caller }) func createStadium() : async League.CreateStadiumResult {
        switch (stadiumIdOrNull) {
            case (null)();
            case (?id) return #alreadyCreated;
        };
        await* createStadiumInternal();
    };

    private func createStadiumInternal() : async* League.CreateStadiumResult {
        let canisterCreationCost = 100_000_000_000;
        let initialBalance = 1_000_000_000_000;
        Cycles.add(canisterCreationCost + initialBalance);
        let stadium = try {
            await StadiumActor.StadiumActor(Principal.fromActor(LeagueActor));
        } catch (err) {
            return #stadiumCreationError(Error.message(err));
        };
        let stadiumId = Principal.fromActor(stadium);
        stadiumIdOrNull := ?stadiumId;
        #ok(stadiumId);
    };

    public shared ({ caller }) func createDivision(request : League.CreateDivisionRequest) : async League.CreateDivisionResult {
        let leagueId = Principal.fromActor(LeagueActor);
        // TODO
        // if (caller != leagueId) {
        //   return #notAuthorized;
        // }

        let nameAlreadyTaken = Trie.some(
            divisions,
            func(k : Principal, v : Division) : Bool = v.name == request.name,
        );
        if (nameAlreadyTaken) {
            return #nameTaken;
        };
        let stadiumId = switch (stadiumIdOrNull) {
            case (null) return #noStadium;
            case (?id) id;
        };
        let canisterCreationCost = 100_000_000_000;
        let initialBalance = 10_000_000_000_000;
        Cycles.add(canisterCreationCost + initialBalance);
        let divisionActor = await DivisionActor.DivisionActor(leagueId, stadiumId);
        let divisionId : Principal = Principal.fromActor(divisionActor);
        let division : Division = {
            name = request.name;
        };
        let divisionKey = {
            key = divisionId;
            hash = Principal.hash(divisionId);
        };
        let (newDivisions, _) = Trie.put(divisions, divisionKey, Principal.equal, division);
        divisions := newDivisions;
        return #ok(divisionId);
    };

    public shared ({ caller }) func scheduleSeason(request : League.ScheduleSeasonRequest) : async League.ScheduleSeasonResult {

        let ?stadiumId = stadiumIdOrNull else return #noStadium;
        let seedBlob = await Random.blob();
        let prng = PseudoRandomX.fromSeed(Blob.hash(seedBlob));

        let divisionRequestResults = Buffer.Buffer<BuildDivisionRequestResultWithId>(request.divisions.size());
        for (division in Iter.fromArray(request.divisions)) {
            let divisionActor = actor (Principal.toText(division.id)) : Division.DivisionActor;
            let result = try {
                let teams = await divisionActor.getTeams();
                let teamIds = Array.map(teams, func(team : Team.TeamWithId) : Principal = team.id);
                await* buildDivisionRequest(teamIds, division.startTime, prng);
            } catch (err) {
                #error(#teamFetchError(Error.message(err)));
            };
            let resultWithId = switch (result) {
                case (#ok(divisionRequest)) #ok({
                    id = division.id;
                    matchGroups = divisionRequest;
                });
                case (#error(error)) #error({
                    id = division.id;
                    error = error;
                });
            };
            divisionRequestResults.add(resultWithId);
        };

        let divisionRequests : [Stadium.ScheduleDivisionRequest] = switch (Util.allOkOrError(divisionRequestResults.vals())) {
            case (#ok(schedules)) schedules;
            case (#error(errors)) return #divisionErrors(errors);
        };
        let stadiumRequest : Stadium.ScheduleSeasonRequest = {
            divisions = divisionRequests;
        };
        let stadiumActor = actor (Principal.toText(stadiumId)) : Stadium.StadiumActor;
        try {
            await stadiumActor.scheduleSeason(stadiumRequest);
        } catch (err) {
            #stadiumScheduleError(Error.message(err));
        };
    };

    private func buildDivisionRequest(
        teamIds : [Principal],
        start : Time.Time,
        prng : Prng,
    ) : async* BuildDivisionRequestResult {
        // Round robin tournament algorithm
        var teamOrderForWeek = Buffer.fromArray<Principal>(teamIds);

        prng.shuffleBuffer(teamOrderForWeek);

        let teamCount = teamOrderForWeek.size();
        if (teamCount == 0) {
            return #error(#noTeamsInDivision);
        };
        if (teamCount % 2 == 1) {
            return #error(#oddNumberOfTeams);
        };
        let matchUpCountPerWeek = teamCount / 2;
        let weekCount : Nat = teamCount - 1; // Round robin should be teamCount - 1 weeks
        var nextMatchDate = DateTime.fromTime(start);

        let matchGroupRequests = Buffer.Buffer<Stadium.ScheduleMatchGroupRequest>(weekCount);
        for (weekIndex in IterTools.range(0, weekCount)) {

            let matches : [Stadium.ScheduleMatchRequest] = IterTools.range(0, matchUpCountPerWeek)
            |> Iter.map(
                _,
                func(i : Nat) : Stadium.ScheduleMatchRequest {
                    let offerings = getRandomOfferings(4);
                    let aura = getRandomMatchAura(prng);
                    let team1Id = teamOrderForWeek.get(i);
                    let team2Id = teamOrderForWeek.get(i + matchUpCountPerWeek); // Second half of teams
                    {
                        team1Id = team1Id;
                        team2Id = team2Id;
                        aura = aura;
                        offerings = offerings;
                    };
                },
            )
            |> Iter.toArray(_);
            nextMatchDate := nextMatchDate.add(#weeks(1));
            // Rotate order of teams
            // 1) Freeze the first team
            // 2) Bring the last team to the second position
            // 3) Rotate the rest of the teams by one position
            let firstTeamId = teamOrderForWeek.get(0);
            let lastTeamId = teamOrderForWeek.get(teamOrderForWeek.size() - 1);
            let newOrder = Buffer.Buffer<Principal>(teamCount);
            newOrder.add(firstTeamId);
            newOrder.add(lastTeamId);
            for (i in IterTools.range(1, teamCount - 1)) {
                newOrder.add(teamOrderForWeek.get(i));
            };
            teamOrderForWeek := newOrder;
        };

        #ok(Buffer.toArray(matchGroupRequests));
    };

    private func getRandomOfferings(count : Nat) : [Stadium.Offering] {
        // TODO
        [
            #shuffleAndBoost
        ];
    };

    private func getRandomMatchAura(prng : Prng) : Stadium.MatchAura {
        // TODO
        let auras = Buffer.fromArray<Stadium.MatchAura>([
            #lowGravity,
            #explodingBalls,
            #fastBallsHardHits,
            #moreBlessingsAndCurses,
        ]);
        prng.shuffleBuffer(auras);
        auras.get(0);
    };
    public shared ({ caller }) func updateLeagueCanisters() : async () {
        let leagueId = Principal.fromActor(LeagueActor);
        for ((divisionId, division) in Trie.iter(divisions)) {
            let divisionActor = actor (Principal.toText(divisionId)) : Division.DivisionActor;
            await divisionActor.updateDivisionCanisters();
            let ?stadiumId = stadiumIdOrNull else Prelude.unreachable(); // Cant create a division without a stadium, so it will exist
            let _ = await (system DivisionActor.DivisionActor)(#upgrade(divisionActor))(leagueId, stadiumId);
        };
        switch (stadiumIdOrNull) {
            case (null)();
            case (?id) {
                let stadiumActor = actor (Principal.toText(id)) : Stadium.StadiumActor;
                let _ = await (system StadiumActor.StadiumActor)(#upgrade(stadiumActor))(leagueId);
            };
        };
    };

    private func buildPrincipalKey(id : Principal) : {
        key : Principal;
        hash : Hash.Hash;
    } {
        { key = id; hash = Principal.hash(id) };
    };
};
