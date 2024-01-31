import PseudoRandomX "mo:random/PseudoRandomX";
import Time "mo:base/Time";
import Trie "mo:base/Trie";
import Iter "mo:base/Iter";
import Buffer "mo:base/Buffer";
import Nat32 "mo:base/Nat32";
import Debug "mo:base/Debug";
import LeagueTypes "Types";
import Util "../Util";
import IterTools "mo:itertools/Iter";
import DateTime "mo:datetime/DateTime";
import Team "../models/Team";
module {
    type Prng = PseudoRandomX.PseudoRandomGenerator;

    public type RegularMatch = {
        team1Id : Principal;
        team2Id : Principal;
    };

    public type RegularMatchGroup = {
        time : Time.Time;
        matches : [RegularMatch];
    };

    public type PlayoffTeam = {
        #seasonStandingIndex : Nat;
        #winnerOfMatch : Nat; // Match Id of last match group
    };

    public type PlayoffMatch = {
        team1 : PlayoffTeam;
        team2 : PlayoffTeam;
    };

    public type PlayoffMatchGroup = {
        time : Time.Time;
        matches : [PlayoffMatch];
    };

    public type SeasonSchedule = {
        regularSeason : [RegularMatchGroup];
        playoffs : [PlayoffMatchGroup];
    };

    public type BuildScheduleResult = {
        #ok : SeasonSchedule;
        #noTeams;
        #oddNumberOfTeams;
    };

    public func build(
        startTime : Time.Time,
        teamIds : [Principal],
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
        var teamOrderForWeek = Buffer.fromArray<Principal>(teamIds);

        let matchUpCountPerWeek = teamCount / 2;
        let weekCount : Nat = teamCount - 1; // Round robin should be teamCount - 1 weeks
        var nextMatchDate = DateTime.fromTime(startTime);

        let regularMatchGroups = Buffer.Buffer<RegularMatchGroup>(weekCount);
        for (weekIndex in IterTools.range(0, weekCount)) {

            let matches : [RegularMatch] = IterTools.range(0, matchUpCountPerWeek)
            |> Iter.map(
                _,
                func(i : Nat) : RegularMatch {
                    let team1Id = teamOrderForWeek.get(i);
                    let team2Id = teamOrderForWeek.get(teamCount - 1 - i); // First plays last, second plays second last, etc.
                    {
                        team1Id = team1Id;
                        team2Id = team2Id;
                    };
                },
            )
            |> Iter.toArray(_);
            regularMatchGroups.add({
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
            let newOrder = Buffer.Buffer<Principal>(teamCount);
            newOrder.add(firstTeamId);
            newOrder.add(lastTeamId);
            for (i in IterTools.range(1, teamCount - 1)) {
                newOrder.add(teamOrderForWeek.get(i));
            };
            teamOrderForWeek := newOrder;
        };

        let playoffMatchGroups = Buffer.Buffer<PlayoffMatchGroup>(4);
        let addPlayoffRound = func(matches : [PlayoffMatch]) {
            if (matches.size() < 1) {
                Debug.trap("No matches in playoff round");
            };
            playoffMatchGroups.add({
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
            func((team1StandingIndex, team2StandingIndex) : (Nat, Nat)) : PlayoffMatch {
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
                func(index : Nat, byeTeamStandingIndex : Nat) : PlayoffMatch {
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
            let lastMatchCount = playoffMatchGroups.get(playoffMatchGroups.size() - 1).matches.size();
            if (lastMatchCount <= 1) {
                break l;
            };
            let nextRoundMatches = Buffer.Buffer<PlayoffMatch>(lastMatchCount / 2);
            for (i in IterTools.range(0, lastMatchCount / 2)) {
                nextRoundMatches.add({
                    team1 = #winnerOfMatch(i * 2);
                    team2 = #winnerOfMatch(i * 2 + 1);
                });
            };
            addPlayoffRound(Buffer.toArray(nextRoundMatches));
        };

        #ok({
            regularSeason = Buffer.toArray(regularMatchGroups);
            playoffs = Buffer.toArray(playoffMatchGroups);
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
