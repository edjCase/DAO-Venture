import PseudoRandomX "mo:random/PseudoRandomX";
import Iter "mo:base/Iter";
import Principal "mo:base/Principal";
import Buffer "mo:base/Buffer";
import Debug "mo:base/Debug";
import Scenario "../models/Scenario";

module {

    type Prng = PseudoRandomX.PseudoRandomGenerator;

    public func getRandomScenario(
        prng : Prng,
        team1Id : Principal,
        team2Id : Principal,
        allTeamIds : [Principal],
        allPlayerIds : [Nat32],
        scenarios : [Scenario.Scenario],
    ) : Scenario.Instance {
        // Filter down buffers/adjust the weights of the scenarios

        let scenario = prng.nextArrayElementWeightedFunc(
            scenarios,
            func(s : Scenario.Scenario) : Float {
                1.0; // TODO
            },
        );
        let otherTeamIds = Buffer.Buffer<Principal>(scenario.otherTeams.size());
        if (scenario.otherTeams.size() > 0) {
            let unusedOtherTeamIds = Buffer.fromArray<Principal>(allTeamIds);
            unusedOtherTeamIds.filterEntries(func(i, id) = id != team1Id and id != team2Id);
            prng.shuffleBuffer(unusedOtherTeamIds); // Randomize

            // TODO filter/weigh the teams
            for (otherTeam in Iter.fromArray(scenario.otherTeams)) {
                let ?randomTeam = unusedOtherTeamIds.removeLast() else return Debug.trap("Not enough teams for scenario: " # scenario.id);
                otherTeamIds.add(randomTeam);
            };
        };

        let playerIds = Buffer.Buffer<Nat32>(scenario.players.size());

        if (scenario.players.size() > 0) {
            let unusedPlayerIds = Buffer.fromArray<Nat32>(allPlayerIds);
            prng.shuffleBuffer(unusedPlayerIds); // Randomize

            // TODO filter/weigh the players
            for (player in Iter.fromArray(scenario.players)) {
                let ?randomPlayer = unusedPlayerIds.removeLast() else return Debug.trap("Not enough players for scenario: " # scenario.id);
                playerIds.add(randomPlayer);
            };
        };
        {
            scenario = scenario;
            teamId = team1Id;
            opposingTeamId = team2Id;
            otherTeamIds = Buffer.toArray(otherTeamIds);
            playerIds = Buffer.toArray(playerIds);
        };
    };

};
