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
import RandomUtil "../RandomUtil";
import Division "../Division";
import DivisionActor "../division/DivisionActor";
import StadiumActor "../stadium/StadiumActor";

actor LeagueActor {
    type Division = League.Division;
    type DivisionWithId = League.DivisionWithId;
    type TeamWithId = Team.TeamWithId;
    type Prng = PseudoRandomX.PseudoRandomGenerator;
    type CloseSeasonResult = League.CloseSeasonResult;
    type CreateDivisionRequest = League.CreateDivisionRequest;
    type CreateDivisionResult = League.CreateDivisionResult;
    type ScheduleSeasonRequest = League.ScheduleSeasonRequest;
    type ScheduleSeasonResult = League.ScheduleSeasonResult;

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

    public shared ({ caller }) func createStadium() : async () {
        await* createStadiumInternal();
    };

    private func createStadiumInternal() : async* () {
        let canisterCreationCost = 100_000_000_000;
        let initialBalance = 1_000_000_000_000;
        Cycles.add(canisterCreationCost + initialBalance);
        let stadium = await StadiumActor.StadiumActor(Principal.fromActor(LeagueActor));
        stadiumIdOrNull := ?Principal.fromActor(stadium);
    };

    public shared ({ caller }) func createDivision(request : CreateDivisionRequest) : async CreateDivisionResult {
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
        let initialBalance = 1_000_000_000_000;
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

    public shared ({ caller }) func scheduleSeason(request : ScheduleSeasonRequest) : async ScheduleSeasonResult {
        let divisionErrors = Buffer.Buffer<(Principal, Division.ScheduleError)>(0);
        label f for (divisionRequest in Iter.fromArray(request.divisions)) {
            let divisionActor = actor (Principal.toText(divisionRequest.id)) : Division.DivisionActor;

            switch (await divisionActor.scheduleSeason(divisionRequest)) {
                case (#ok)();
                case (#error(e)) divisionErrors.add((divisionRequest.id, e));
            };

        };
        if (divisionErrors.size() > 0) {
            return #divisionErrors(Buffer.toArray(divisionErrors));
        };
        #ok;
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
