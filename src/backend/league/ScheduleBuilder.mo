import PseudoRandomX "mo:random/PseudoRandomX";
import Time "mo:base/Time";
import Trie "mo:base/Trie";
import Iter "mo:base/Iter";
import Buffer "mo:base/Buffer";
import Nat32 "mo:base/Nat32";
import LeagueTypes "Types";
import Util "../Util";
import IterTools "mo:itertools/Iter";
import DateTime "mo:datetime/DateTime";
import Team "../models/Team";
module {
    type Prng = PseudoRandomX.PseudoRandomGenerator;

    public type Match = {
        team1Id : Principal;
        team2Id : Principal;
    };

    public type MatchGroup = {
        time : Time.Time;
        matches : [Match];
    };

    public type SeasonSchedule = {
        matchGroups : [MatchGroup];
    };

    public type BuildScheduleResult = {
        #ok : SeasonSchedule;
        #noTeams;
        #oddNumberOfTeams;
    };

    public func build(
        startTime : Time.Time,
        teamIds : [Principal],
    ) : BuildScheduleResult {

        let teamCount = teamIds.size();
        if (teamCount == 0) {
            return #noTeams;
        };
        if (teamCount % 2 == 1) {
            return #oddNumberOfTeams;
        };

        // Round robin tournament algorithm
        var teamOrderForWeek = Buffer.fromArray<Principal>(teamIds);

        let matchUpCountPerWeek = teamCount / 2;
        let weekCount : Nat = teamCount - 1; // Round robin should be teamCount - 1 weeks
        var nextMatchDate = DateTime.fromTime(startTime);

        let matchGroupSchedules = Buffer.Buffer<MatchGroup>(weekCount);
        for (weekIndex in IterTools.range(0, weekCount)) {

            let matches : [Match] = IterTools.range(0, matchUpCountPerWeek)
            |> Iter.map(
                _,
                func(i : Nat) : Match {
                    let team1Id = teamOrderForWeek.get(i);
                    let team2Id = teamOrderForWeek.get(teamCount - 1 - i); // First plays last, second plays second last, etc.
                    {
                        team1Id = team1Id;
                        team2Id = team2Id;
                    };
                },
            )
            |> Iter.toArray(_);
            matchGroupSchedules.add({
                time = nextMatchDate.toTime();
                matches = matches;
            });
            // nextMatchDate := nextMatchDate.add(#weeks(1)); // TODO revert
            nextMatchDate := nextMatchDate.add(#minutes(15));
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
            matchGroups = Buffer.toArray(matchGroupSchedules);
        });
    };
};
