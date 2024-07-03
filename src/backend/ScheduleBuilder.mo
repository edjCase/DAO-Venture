import PseudoRandomX "mo:xtended-random/PseudoRandomX";
import Time "mo:base/Time";
import Iter "mo:base/Iter";
import Buffer "mo:base/Buffer";
import Debug "mo:base/Debug";
import Nat "mo:base/Nat";
import Order "mo:base/Order";
import Nat32 "mo:base/Nat32";
import Array "mo:base/Array";
import Prelude "mo:base/Prelude";
import Float "mo:base/Float";
import Int "mo:base/Int";
import IterTools "mo:itertools/Iter";
import DateTime "mo:datetime/DateTime";
import Season "../models/Season";
import Components "mo:datetime/Components";

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
        #err : {
            #invalidArgs : Text;
        };
    };

    public func build(
        startTime : Time.Time,
        teamIds : [Nat],
        weekDays : [Components.DayOfWeek],
    ) : BuildScheduleResult {

        if (weekDays.size() == 0) {
            return #err(#invalidArgs("No week days specified"));
        };

        if (teamIds.size() == 0) {
            return #err(#invalidArgs("No teams specified"));
        };
        if (teamIds.size() % 2 == 1) {
            return #err(#invalidArgs("Odd number of teams"));
        };

        let firstMatchDate = DateTime.fromTime(startTime);
        let firstDayOfWeek = firstMatchDate.dayOfWeek();
        if (not IterTools.any(weekDays.vals(), func(day : Components.DayOfWeek) : Bool = day == firstDayOfWeek)) {
            return #err(#invalidArgs("Start date is not on a specified week day"));
        };

        let matchDateIter = buildMatchDateIterator(firstMatchDate, weekDays);

        let matchGroups = Buffer.Buffer<MatchGroup>(20);
        // Regular season
        buildRegularMatchGroups(matchGroups, teamIds, matchDateIter);

        // Playoffs
        buildPlayoffMatchGroups(matchGroups, teamIds, matchDateIter);

        #ok({
            matchGroups = Buffer.toArray(matchGroups);
        });
    };

    private func buildMatchDateIterator(
        firstMatchDate : DateTime.DateTime,
        weekDays : [Components.DayOfWeek],
    ) : { next : () -> DateTime.DateTime } {

        let getDayOfWeekIndex = func(day : Components.DayOfWeek) : Nat {
            switch (day) {
                case (#sunday) 0;
                case (#monday) 1;
                case (#tuesday) 2;
                case (#wednesday) 3;
                case (#thursday) 4;
                case (#friday) 5;
                case (#saturday) 6;
            };
        };

        let compareDayOfWeek = func(a : Components.DayOfWeek, b : Components.DayOfWeek) : Order.Order {
            Nat.compare(getDayOfWeekIndex(a), getDayOfWeekIndex(b));
        };
        let equalDayOfWeek = func(a : Components.DayOfWeek, b : Components.DayOfWeek) : Bool {
            compareDayOfWeek(a, b) == #equal;
        };
        let hashDayOfWeek = func(day : Components.DayOfWeek) : Nat32 {
            Nat32.fromNat(getDayOfWeekIndex(day));
        };

        let orderedDaysOfWeek = weekDays.vals()
        |> IterTools.unique<Components.DayOfWeek>(_, hashDayOfWeek, equalDayOfWeek)
        |> Iter.sort(_, compareDayOfWeek)
        |> Iter.toArray(_);

        let firstDayOfWeek = firstMatchDate.dayOfWeek();
        let ?firstDayOfWeekIndex = Array.indexOf(firstDayOfWeek, orderedDaysOfWeek, equalDayOfWeek) else Prelude.unreachable();
        var dayOfWeekIndex = firstDayOfWeekIndex;
        let maxDayOfWeekIndex : Nat = orderedDaysOfWeek.size() - 1;
        let advanceOptions = {
            addWeekOnMatchingDay = true;
            resetToStartOfDay = false;
        };
        object {
            var dateOrNull : ?DateTime.DateTime = null;
            public func next() : DateTime.DateTime {
                let newDate : DateTime.DateTime = switch (dateOrNull) {
                    case (null) firstMatchDate; // On first call, use first match date
                    case (?lastDate) {
                        // On subsequent calls, advance to next week day specified
                        if (dayOfWeekIndex >= maxDayOfWeekIndex) {
                            dayOfWeekIndex := 0;
                        } else {
                            dayOfWeekIndex := dayOfWeekIndex + 1;
                        };
                        lastDate.advanceToDayOfWeek(orderedDaysOfWeek[dayOfWeekIndex], advanceOptions);
                    };
                };
                dateOrNull := ?newDate;
                newDate;
            };
        };
    };

    private func buildRegularMatchGroups(
        matchGroups : Buffer.Buffer<MatchGroup>,
        teamIds : [Nat],
        matchDateIter : { next : () -> DateTime.DateTime },
    ) {

        // Round robin tournament algorithm
        var teamOrderForWeek = Buffer.fromArray<Nat>(teamIds);

        let teamCount = teamIds.size();
        let matchUpCountPerWeek = teamCount / 2;
        let weekCount : Nat = teamCount - 1; // Round robin should be teamCount - 1 weeks
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
                time = matchDateIter.next().toTime();
                matches = matches;
            });
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
    };

    private func buildPlayoffMatchGroups(
        matchGroups : Buffer.Buffer<MatchGroup>,
        teamIds : [Nat],
        matchGroupIter : { next : () -> DateTime.DateTime },
    ) {
        let teamCount : Nat = Int.abs(Float.toInt(Float.floor(Float.fromInt(teamIds.size()) * (2. / 3.)))); // Only top 2/3 (rounded down) of teams make it to playoffs
        let addPlayoffRound = func(matches : [Match]) {
            if (matches.size() < 1) {
                Debug.trap("No matches in playoff round");
            };
            matchGroups.add({
                time = matchGroupIter.next().toTime();
                matches = matches;
            });
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
    };

    private func findNextPowerOfTwo(number : Nat) : Nat {
        var count : Nat = 1;
        while (count < number) {
            count := count * 2;
        };
        return count;
    };
};
