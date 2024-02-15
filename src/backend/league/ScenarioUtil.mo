import PseudoRandomX "mo:random/PseudoRandomX";
import Iter "mo:base/Iter";
import Principal "mo:base/Principal";
import Buffer "mo:base/Buffer";
import Debug "mo:base/Debug";
import Array "mo:base/Array";
import Float "mo:base/Float";
import Nat8 "mo:base/Nat8";
import Scenario "../models/Scenario";
import IterTools "mo:itertools/Iter";

module {

    type Prng = PseudoRandomX.PseudoRandomGenerator;

    public func resolveScenario(
        prng : Prng,
        scenario : Scenario.Instance,
        choiceIndex : Nat8,
    ) : [Scenario.EffectOutcome] {
        let choice = scenario.template.options[Nat8.toNat(choiceIndex)];
        let effectOutcomes = resolveEffect(prng, scenario, choice.effect);
        Iter.toArray(effectOutcomes);
    };

    public func resolveEffect(
        prng : Prng,
        scenario : Scenario.Instance,
        effect : Scenario.Effect,
    ) : Iter.Iter<Scenario.EffectOutcome> {
        switch (effect) {
            case (#allOf(subEffects)) {
                subEffects
                |> Iter.fromArray(_)
                |> Iter.map(
                    _,
                    func(subEffect : Scenario.Effect) : Iter.Iter<Scenario.EffectOutcome> = resolveEffect(prng, scenario, subEffect),
                )
                |> IterTools.flatten(_);
            };
            case (#oneOf(subEffects)) {
                let weightedSubEffects = Array.map<(Nat, Scenario.Effect), (Scenario.Effect, Float)>(
                    subEffects,
                    func((weight, effect) : (Nat, Scenario.Effect)) : (Scenario.Effect, Float) = (effect, Float.fromInt(weight)),
                );
                let subEffect = prng.nextArrayElementWeighted(weightedSubEffects);
                resolveEffect(prng, scenario, subEffect);
            };
            case (#trait(trait)) {
                Iter.make(
                    #trait({
                        trait with
                        target = getTargetInstance(scenario, trait.target)
                    })
                );
            };
            case (#entropy(entropyEffect)) {
                Iter.make(
                    #entropy({
                        teamId = getTeamId(scenario, entropyEffect.team);
                        delta = entropyEffect.delta;
                    })
                );
            };
            case (#noEffect) {
                {
                    next = func() : ?Scenario.EffectOutcome = null;
                };
            };
        };
    };

    private func getTeamId(scenario : Scenario.Instance, team : Scenario.Team) : Principal {
        switch (team) {
            case (#scenarioTeam) scenario.teamId;
            case (#opposingTeam) scenario.opposingTeamId;
            case (#otherTeam(index)) scenario.otherTeamIds[index];
        };
    };

    private func getTargetInstance(scenario : Scenario.Instance, target : Scenario.Target) : Scenario.TargetInstance {
        switch (target) {
            case (#league) #league;
            case (#teams(teams)) {
                let teamIds = teams
                |> Iter.fromArray(_)
                |> Iter.map(
                    _,
                    func(team : Scenario.Team) : Principal = getTeamId(scenario, team),
                )
                |> Iter.toArray(_);
                #teams(teamIds);
            };
            case (#players(players)) {
                let playerIds = players
                |> Iter.fromArray(_)
                |> Iter.map(
                    _,
                    func(i : Scenario.ScenarioPlayerIndex) : Nat32 = scenario.playerIds[i],
                )
                |> Iter.toArray(_);
                #players(playerIds);
            };
        };
    };

    public func getRandomScenario(
        prng : Prng,
        team1Id : Principal,
        team2Id : Principal,
        allTeamIds : [Principal],
        allPlayerIds : [Nat32],
        scenarios : [Scenario.Template],
    ) : Scenario.Instance {
        // Filter down buffers/adjust the weights of the scenarios

        let scenario = prng.nextArrayElementWeightedFunc(
            scenarios,
            func(s : Scenario.Template) : Float {
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
            template = scenario;
            teamId = team1Id;
            opposingTeamId = team2Id;
            otherTeamIds = Buffer.toArray(otherTeamIds);
            playerIds = Buffer.toArray(playerIds);
        };
    };

};
