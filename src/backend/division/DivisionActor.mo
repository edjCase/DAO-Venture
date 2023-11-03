import Principal "mo:base/Principal";
import Trie "mo:base/Trie";
import Token "mo:icrc1/ICRC1/Canisters/Token";
import Division "../Division";
import Team "../Team";
import League "../League";
import TeamActor "../team/TeamActor";
import Cycles "mo:base/ExperimentalCycles";
import Hash "mo:base/Hash";
import Nat64 "mo:base/Nat64";
import Int "mo:base/Int";
import Time "mo:base/Time";
import Random "mo:base/Random";
import Blob "mo:base/Blob";
import Iter "mo:base/Iter";
import Buffer "mo:base/Buffer";
import Error "mo:base/Error";
import PseudoRandomX "mo:random/PseudoRandomX";
import DateTime "mo:datetime/DateTime";
import IterTools "mo:itertools/Iter";
import Stadium "../Stadium";

actor class DivisionActor(leagueId : Principal, stadiumId : Principal) : async Division.DivisionActor = this {
    type TeamWithId = Team.TeamWithId;
    type Team = Team.TeamWithoutDivision;
    type CreateTeamResult = Division.CreateTeamResult;
    type CreateTeamRequest = Division.CreateTeamRequest;
    type LedgerActor = Token.Token;
    type Prng = PseudoRandomX.PseudoRandomGenerator;
    type SeasonSchedule = Division.SeasonSchedule;
    type SeasonWeek = Division.SeasonWeek;
    type MatchUp = Division.MatchUp;

    stable var teams : Trie.Trie<Principal, Team> = Trie.empty();
    stable var schedule : ?SeasonSchedule = null;
    let stadium = actor (Principal.toText(stadiumId)) : Stadium.StadiumActor;

    public query func getTeams() : async [TeamWithId] {
        Trie.toArray(
            teams,
            func(k : Principal, v : Team) : TeamWithId = {
                id = k;
                name = v.name;
                logoUrl = v.logoUrl;
                ledgerId = v.ledgerId;
                divisionId = Principal.fromActor(this);
            },
        );
    };

    public shared ({ caller }) func createTeam(request : CreateTeamRequest) : async CreateTeamResult {

        let nameAlreadyTaken = Trie.some(
            teams,
            func(k : Principal, v : Team) : Bool = v.name == request.name,
        );
        if (nameAlreadyTaken) {
            return #nameTaken;
        };
        // Create canister for team ledger
        let ledger : LedgerActor = await createTeamLedger(request.tokenName, request.tokenSymbol);
        let ledgerId = Principal.fromActor(ledger);
        // Create canister for team logic
        let teamActor = await createTeamActor(ledgerId);
        let teamId = Principal.fromActor(teamActor);
        let team : Team = {
            name = request.name;
            canister = teamActor;
            logoUrl = request.logoUrl;
            ledgerId = ledgerId;
        };
        let teamKey = buildPrincipalKey(teamId);
        let (newTeams, _) = Trie.put(teams, teamKey, Principal.equal, team);
        teams := newTeams;
        return #ok(teamId);
    };

    public shared ({ caller }) func mint(request : Division.MintRequest) : async Division.MintResult {
        // TODO
        // if (caller != leagueId) {
        //   return #notAuthorized;
        // }
        let ?team = Trie.get(teams, buildPrincipalKey(request.teamId), Principal.equal) else return #teamNotFound;
        let ledger = actor (Principal.toText(team.ledgerId)) : Token.Token;

        let transferResult = await ledger.mint({
            amount = request.amount;
            created_at_time = ?Nat64.fromNat(Int.abs(Time.now()));
            memo = null;
            to = {
                owner = request.teamId;
                subaccount = ?Principal.toBlob(caller);
            };
        });
        switch (transferResult) {
            case (#Ok(txIndex)) #ok(txIndex);
            case (#Err(error)) #transferError(error);
        };
    };

    public shared ({ caller }) func updateDivisionCanisters() : async () {
        for ((teamId, team) in Trie.iter(teams)) {
            let teamActor = actor (Principal.toText(teamId)) : Team.TeamActor;
            let divisionId = Principal.fromActor(this);
            let ledgerId = team.ledgerId;
            let _ = await (system TeamActor.TeamActor)(#upgrade(teamActor))(leagueId, stadiumId, divisionId, ledgerId);
        };
    };

    public shared ({ caller }) func scheduleSeason(start : Time.Time) : async {
        #ok;
        #error : Division.ScheduleError;
    } {
        // TODO re-enable
        // if (division.schedule != null) {
        //     return #error(#alreadyScheduled);
        // };
        let seedBlob = await Random.blob();
        let prng = PseudoRandomX.fromSeed(Blob.hash(seedBlob));
        let schedule = switch (await* generateSchedule(start, prng)) {
            case (#ok(schedule)) schedule;
            case (#oddNumberOfTeams) return #error(#oddNumberOfTeams);
            case (#noTeamsInDivision) return #error(#noTeamsInDivision);
        };
        #ok;
    };

    private func generateSchedule(
        start : Time.Time,
        prng : Prng,
    ) : async* {
        #ok : SeasonSchedule;
        #oddNumberOfTeams;
        #noTeamsInDivision;
    } {
        var teamOrderForWeek = Trie.iter(teams)
        // Only have team ids
        |> Iter.map(_, func(v : (Principal, Team)) : Principal = v.0)
        |> Buffer.fromIter<Principal>(_);

        prng.shuffleBuffer(teamOrderForWeek);

        let teamCount = teamOrderForWeek.size();
        if (teamCount == 0) {
            return #noTeamsInDivision;
        };
        if (teamCount % 2 == 1) {
            return #oddNumberOfTeams;
        };
        let matchUpCountPerWeek = teamCount / 2;
        let weekCount : Nat = teamCount - 1; // Round robin should be teamCount - 1 weeks
        var nextMatchDate = DateTime.fromTime(start);

        let weeks = Buffer.Buffer<SeasonWeek>(weekCount);
        for (weekIndex in IterTools.range(0, weekCount)) {

            let matches : [Stadium.ScheduleMatchRequest] = IterTools.range(0, matchUpCountPerWeek)
            |> Iter.map(
                _,
                func(i : Nat) : Stadium.ScheduleMatchRequest {
                    let team1Id = teamOrderForWeek.get(i);
                    let team2Id = teamOrderForWeek.get(i + matchUpCountPerWeek); // Second half of teams
                    {
                        team1Id = team1Id;
                        team2Id = team2Id;
                        aura = aura;
                        offering = offering;
                    };
                },
            )
            |> Iter.toArray(_);

            // Round robin tournament algorithm
            let status = try {
                let scheduleResult = await stadium.scheduleMatchGroup({
                    time = nextMatchDate.toTime();
                    divisionId = Principal.fromActor(this);
                    matches = matches;
                });
                switch (scheduleResult) {
                    case (#ok(id)) #scheduled(id);
                    case (#matchErrors(e)) #failedToSchedule(#teamNotFound(t));
                    case (#teamFetchError(e)) #failedToSchedule(#teamFetchError(e));
                };
            } catch (err) {
                #failedToSchedule(#scheduleMatchError(Error.message(err)));
            };

            let matchUps = Buffer.Buffer<MatchUp>(matchUpCountPerWeek);
            weeks.add({
                matchUps = matchUps;
            });
            nextMatchDate := nextMatchDate.add(#weeks(1));
            // Rotate order of teams
            // 1) Freeze the first team
            // 2) Bring the last team to the second position
            // 3) Rotate the rest of the teams by one position
            let firstTeam = teamOrderForWeek.get(0);
            let lastTeam = teamOrderForWeek.get(teamOrderForWeek.size() - 1);
            let newOrder = Buffer.Buffer<Principal>(teamCount);
            newOrder.add(firstTeam);
            newOrder.add(lastTeam);
            for (i in IterTools.range(1, teamCount - 1)) {
                newOrder.add(teamOrderForWeek.get(i));
            };
            teamOrderForWeek := newOrder;
        };
        #ok({
            weeks = Buffer.toArray(weeks);
        });
    };

    private func createTeamActor(ledgerId : Principal) : async TeamActor.TeamActor {
        let canisterCreationCost = 100_000_000_000;
        let initialBalance = 1_000_000_000_000;
        Cycles.add(canisterCreationCost + initialBalance);
        let divisionId = Principal.fromActor(this);
        await TeamActor.TeamActor(
            leagueId,
            stadiumId,
            divisionId,
            ledgerId,
        );
    };

    private func createTeamLedger(tokenName : Text, tokenSymbol : Text) : async LedgerActor {
        let canisterCreationCost = 100_000_000_000;
        let initialBalance = 1_000_000_000_000;
        Cycles.add(canisterCreationCost + initialBalance);

        await Token.Token({
            name = tokenName;
            symbol = tokenSymbol;
            decimals = 0;
            fee = 0;
            max_supply = 1;
            initial_balances = [];
            min_burn_amount = 0;
            minting_account = ?{ owner = leagueId; subaccount = null };
            advanced_settings = null;
        });
    };
    private func buildPrincipalKey(id : Principal) : {
        key : Principal;
        hash : Hash.Hash;
    } {
        { key = id; hash = Principal.hash(id) };
    };
};
