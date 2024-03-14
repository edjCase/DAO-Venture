import PseudoRandomX "mo:random/PseudoRandomX";
import Time "mo:base/Time";
import Iter "mo:base/Iter";
import Buffer "mo:base/Buffer";
import Debug "mo:base/Debug";
import Nat "mo:base/Nat";
import IterTools "mo:itertools/Iter";
import DateTime "mo:datetime/DateTime";
import Season "../models/Season";

module {
    type Prng = PseudoRandomX.PseudoRandomGenerator;

    public type Match = {
        team1 : Season.TeamAssignment;
        team2 : Season.TeamAssignment;
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
        teamIds : [Nat],
        timeBetweenMatchGroups : DateTime.Duration,
    ) : BuildScheduleResult {

        let teamCount = teamIds.size();
        if (teamCount == 0) {
            return #noTeams;
        };
        if (teamCount % 2 == 1) {
            return #oddNumberOfTeams;
        };

        // Round robin tournament algorithm
        var teamOrderForWeek = Buffer.fromArray<Nat>(teamIds);

        let matchUpCountPerWeek = teamCount / 2;
        let weekCount : Nat = teamCount - 1; // Round robin should be teamCount - 1 weeks
        var nextMatchDate = DateTime.fromTime(startTime);

        let matchGroups = Buffer.Buffer<MatchGroup>(weekCount);
        for (weekIndex in IterTools.range(0, weekCount)) {

            let matches : [Match] = IterTools.range(0, matchUpCountPerWeek)
            |> Iter.map(
                _,
                func(i : Nat) : Match {
                    let team1Id = teamOrderForWeek.get(i);
                    let team2Id = teamOrderForWeek.get(teamCount - 1 - i); // First plays last, second plays second last, etc.
                    {
                        team1 = #predetermined(team1Id);
                        team2 = #predetermined(team2Id);
                    };
                },
            )
            |> Iter.toArray(_);
            matchGroups.add({
                time = nextMatchDate.toTime();
                matches = matches;
            });
            nextMatchDate := nextMatchDate.add(timeBetweenMatchGroups);
            // Rotate order of teams
            // 1) Freeze the first team
            // 2) Bring the last team to the second position
            // 3) Rotate the rest of the teams by one position
            let firstTeamId = teamOrderForWeek.get(0);
            let lastTeamId = teamOrderForWeek.get(teamOrderForWeek.size() - 1);
            let newOrder = Buffer.Buffer<Nat>(teamCount);
            newOrder.add(firstTeamId);
            newOrder.add(lastTeamId);
            for (i in IterTools.range(1, teamCount - 1)) {
                newOrder.add(teamOrderForWeek.get(i));
            };
            teamOrderForWeek := newOrder;
        };

        let addPlayoffRound = func(matches : [Match]) {
            if (matches.size() < 1) {
                Debug.trap("No matches in playoff round");
            };
            matchGroups.add({
                time = nextMatchDate.toTime();
                matches = matches;
            });
            nextMatchDate := nextMatchDate.add(timeBetweenMatchGroups);
        };
        let nextPowerOfTwo = findNextPowerOfTwo(teamCount);
        let byeTeamCount : Nat = nextPowerOfTwo - teamCount; // Number of teams that get a bye in the first round

        // Split the teams up into two halves, but exclude the teams that get a bye in the first round
        let teamsInFirstRound = IterTools.range(byeTeamCount, teamCount);
        let firstRoundMatchupCount : Nat = (teamCount - byeTeamCount) / 2;
        let (firstHalfOfTeams, secondHalfOfTeams) = teamsInFirstRound
        |> Buffer.fromIter<Nat>(_)
        |> Buffer.split(_, firstRoundMatchupCount);
        // Reverse the second half to pair first - last, second - second last, etc.
        Buffer.reverse(secondHalfOfTeams);
        let firstRoundMatches = IterTools.zip(firstHalfOfTeams.vals(), secondHalfOfTeams.vals())
        |> Iter.map(
            _,
            func((team1StandingIndex, team2StandingIndex) : (Nat, Nat)) : Match {
                {
                    team1 = #seasonStandingIndex(team1StandingIndex);
                    team2 = #seasonStandingIndex(team2StandingIndex);
                };
            },
        )
        |> Iter.toArray(_);

        // First Round
        addPlayoffRound(firstRoundMatches);

        // If there are byes, then make a second round
        if (byeTeamCount > 0) {
            let byeTeams = IterTools.range(0, byeTeamCount);

            // Second round has the top teams against the winners of the first round
            // If team count is not a power of two, then some teams get a bye in the first round
            let secondRoundMatches = byeTeams
            |> IterTools.mapEntries(
                _,
                func(index : Nat, byeTeamStandingIndex : Nat) : Match {
                    {
                        team1 = #seasonStandingIndex(byeTeamStandingIndex);
                        team2 = #winnerOfMatch(index);
                    };
                },
            )
            |> Iter.toArray(_);
            addPlayoffRound(secondRoundMatches);
        };

        label l loop {
            // Loop, halving the number of matches each time, until there is only one match left
            let lastMatchCount = matchGroups.get(matchGroups.size() - 1).matches.size();
            if (lastMatchCount <= 1) {
                break l;
            };
            let nextRoundMatches = Buffer.Buffer<Match>(lastMatchCount / 2);
            for (i in IterTools.range(0, lastMatchCount / 2)) {
                nextRoundMatches.add({
                    team1 = #winnerOfMatch(i * 2);
                    team2 = #winnerOfMatch(i * 2 + 1);
                });
            };
            addPlayoffRound(Buffer.toArray(nextRoundMatches));
        };

        #ok({
            matchGroups = Buffer.toArray(matchGroups);
        });
    };

    private func findNextPowerOfTwo(number : Nat) : Nat {
        var count : Nat = 1;
        while (count < number) {
            count := count * 2;
        };
        return count;
    };
};
