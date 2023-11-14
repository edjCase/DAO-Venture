import PseudoRandomX "mo:random/PseudoRandomX";
import Time "mo:base/Time";
import Trie "mo:base/Trie";
import Iter "mo:base/Iter";
import Buffer "mo:base/Buffer";
import Nat32 "mo:base/Nat32";
import League "../League";
import Util "../Util";
import Team "../Team";
import IterTools "mo:itertools/Iter";
import DateTime "mo:datetime/DateTime";
module {
    type Prng = PseudoRandomX.PseudoRandomGenerator;

    public type BuildScheduleResult = {
        #ok : League.SeasonSchedule;
        #error : [League.StartDivisionSeasonErrorResult];
    };

    type DivisionSchedule = {
        id : Nat32;
        matchGroups : [MatchGroupSchedule];
    };

    type MatchGroupSchedule = {
        startTime : Time.Time;
        matches : [MatchSchedule];
    };

    type MatchSchedule = {
        team1Id : Principal;
        team2Id : Principal;
    };

    type BuildDivisionScheduleResult = {
        #ok : DivisionSchedule;
        #error : League.StartDivisionSeasonErrorResult;
    };

    public func build(
        request : League.StartSeasonRequest,
        divisions : [League.DivisionWithId],
        teams : [Team.TeamWithId],
        prng : Prng,
    ) : BuildScheduleResult {

        // Build division schedules without ids
        let allOkOrError = request.divisions
        |> Iter.fromArray(_)
        |> Iter.map<League.StartDivisionSeasonRequest, BuildDivisionScheduleResult>(
            _,
            func(division) = buildDivisionSchedule(division, divisions, teams, prng),
        )
        |> Util.allOkOrError(_);

        let divisionSchedulesPre = switch (allOkOrError) {
            case (#ok(divisions)) divisions;
            case (#error(error)) return #error(error);
        };

        // Assign ids to match groups and make division => match group id map
        let divisionSchedules = Buffer.Buffer<League.DivisionScheduleWithId>(divisionSchedulesPre.size());
        let matchGroupSchedules = Buffer.Buffer<League.MatchGroupScheduleWithId>(12);
        for (division in Iter.fromArray(divisionSchedulesPre)) {
            let divisionMatchGroupIds = Buffer.Buffer<Nat32>(division.matchGroups.size());
            for (matchGroup in Iter.fromArray(division.matchGroups)) {
                let nextMatchGroupId = Nat32.fromNat(matchGroupSchedules.size() + 1);
                divisionMatchGroupIds.add(nextMatchGroupId);
                matchGroupSchedules.add({
                    id = nextMatchGroupId;
                    time = matchGroup.startTime;
                    matches = matchGroup.matches;
                    status = #notOpen;
                });
            };
            divisionSchedules.add({
                id = division.id;
                matchGroupIds = Buffer.toArray(divisionMatchGroupIds);
            });
        };

        #ok({
            divisions = Buffer.toArray(divisionSchedules);
            matchGroups = Buffer.toArray(matchGroupSchedules);
        });
    };

    private func buildDivisionSchedule(
        request : League.StartDivisionSeasonRequest,
        divisions : [League.DivisionWithId],
        teams : [Team.TeamWithId],
        prng : Prng,
    ) : BuildDivisionScheduleResult {
        let divisionExists = IterTools.any(
            Iter.fromArray(divisions),
            func(d : League.DivisionWithId) : Bool = d.id == request.id,
        );
        if (not divisionExists) {
            return #error({ id = request.id; error = #divisionNotFound });
        };
        let teamIds = teams
        |> Iter.fromArray(_)
        |> Iter.filter(_, func(team : Team.TeamWithId) : Bool = team.divisionId == request.id)
        |> Iter.map(_, func(team : Team.TeamWithId) : Principal = team.id)
        |> Iter.toArray(_);

        let teamCount = teamIds.size();
        if (teamCount == 0) {
            return #error({ id = request.id; error = #noTeamsInDivision });
        };
        if (teamCount % 2 == 1) {
            return #error({ id = request.id; error = #oddNumberOfTeams });
        };

        // Round robin tournament algorithm
        var teamOrderForWeek = Buffer.fromArray<Principal>(teamIds);

        prng.shuffleBuffer(teamOrderForWeek);
        let matchUpCountPerWeek = teamCount / 2;
        let weekCount : Nat = teamCount - 1; // Round robin should be teamCount - 1 weeks
        var nextMatchDate = DateTime.fromTime(request.startTime);

        let matchGroupSchedules = Buffer.Buffer<MatchGroupSchedule>(weekCount);
        for (weekIndex in IterTools.range(0, weekCount)) {

            let matches : [League.MatchSchedule] = IterTools.range(0, matchUpCountPerWeek)
            |> Iter.map(
                _,
                func(i : Nat) : League.MatchSchedule {
                    let team1Id = teamOrderForWeek.get(i);
                    let team2Id = teamOrderForWeek.get(i + matchUpCountPerWeek); // Second half of teams
                    {
                        team1Id = team1Id;
                        team2Id = team2Id;
                    };
                },
            )
            |> Iter.toArray(_);
            matchGroupSchedules.add({
                startTime = nextMatchDate.toTime();
                matches = matches;
            });
            // nextMatchDate := nextMatchDate.add(#weeks(1)); // TODO revert
            nextMatchDate := nextMatchDate.add(#minutes(5));
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

        #ok({
            id = request.id;
            matchGroups = Buffer.toArray(matchGroupSchedules);
        });
    };
};
