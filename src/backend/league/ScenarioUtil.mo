import PseudoRandomX "mo:random/PseudoRandomX";
import Iter "mo:base/Iter";
import Principal "mo:base/Principal";
import Buffer "mo:base/Buffer";
import Debug "mo:base/Debug";
import Array "mo:base/Array";
import Float "mo:base/Float";
import Nat8 "mo:base/Nat8";
import Nat "mo:base/Nat";
import Text "mo:base/Text";
import Scenario "../models/Scenario";
import IterTools "mo:itertools/Iter";
import TextX "mo:xtended-text/TextX";

module {

    type Prng = PseudoRandomX.PseudoRandomGenerator;

    public type ValidateScenarioResult = {
        #ok;
        #invalid : [Text];
    };

    public type ValidateEffectResult = {
        #ok;
        #invalid : [Text];
    };

    public func validateScenario(scenario : Scenario.Template, traitIds : [Text]) : ValidateScenarioResult {
        let errors = Buffer.Buffer<Text>(0);
        if (TextX.isEmptyOrWhitespace(scenario.id)) {
            errors.add("Scenario must have an id");
        };
        if (TextX.isEmptyOrWhitespace(scenario.title)) {
            errors.add("Scenario must have a title");
        };
        if (TextX.isEmptyOrWhitespace(scenario.description)) {
            errors.add("Scenario must have a description");
        };
        if (scenario.options.size() < 2) {
            errors.add("Scenario must have at least 2 options");
        };
        var index = 0;
        for (option in Iter.fromArray(scenario.options)) {
            if (TextX.isEmptyOrWhitespace(option.description)) {
                errors.add("Option " # Nat.toText(index) # " must have a description");
            };
            switch (validateEffect(option.effect, traitIds)) {
                case (#ok) {};
                case (#invalid(effectErrors)) {
                    for (effectError in Iter.fromArray(effectErrors)) {
                        errors.add("Option " # Nat.toText(index) # " has an invalid effect: " # effectError);
                    };
                };
            };
            index += 1;
        };
        if (errors.size() > 0) {
            #invalid(Buffer.toArray(errors));
        } else {
            #ok;
        };
    };

    private func validateEffect(effect : Scenario.Effect, traitIds : [Text]) : ValidateEffectResult {
        let errors = Buffer.Buffer<Text>(0);
        switch (effect) {
            case (#allOf(subEffects)) {
                var index = 0;
                for (subEffect in Iter.fromArray(subEffects)) {
                    switch (validateEffect(subEffect, traitIds)) {
                        case (#ok) {};
                        case (#invalid(subEffectErrors)) {
                            for (subEffectError in Iter.fromArray(subEffectErrors)) {
                                errors.add("Effect allOf has an invalid subeffect " # Nat.toText(index) # ": " # subEffectError);
                            };
                        };
                    };
                    index += 1;
                };
            };
            case (#oneOf(subEffects)) {
                var index = 0;
                for ((weight, subEffect) in Iter.fromArray(subEffects)) {
                    if (weight < 1) {
                        errors.add("Weight must be at least 1");
                    };
                    switch (validateEffect(subEffect, traitIds)) {
                        case (#ok) {};
                        case (#invalid(subEffectErrors)) {
                            for (subEffectError in Iter.fromArray(subEffectErrors)) {
                                errors.add("Effect oneOf has an invalid subeffect " # Nat.toText(index) # ": " # subEffectError);
                            };
                        };
                    };
                    index += 1;
                };
            };
            case (#trait(traitEffect)) {
                if (Array.indexOf(traitEffect.traitId, traitIds, Text.equal) == null) {
                    return #invalid(["Trait not found: " # traitEffect.traitId]);
                };
            };
            case (#removeTrait(removeTraitEffect)) {
                if (Array.indexOf(removeTraitEffect.traitId, traitIds, Text.equal) == null) {
                    return #invalid(["Trait not found: " # removeTraitEffect.traitId]);
                };
            };
            case (#entropy(_)) {};
            case (#injury(_)) {};
            case (#noEffect) {};
        };
        #ok;
    };

    public func resolveScenario(
        prng : Prng,
        scenarioTemplate : Scenario.Template,
        scenario : Scenario.Instance,
        choiceIndex : Nat8,
    ) : [Scenario.EffectOutcome] {
        let choice = scenarioTemplate.options[Nat8.toNat(choiceIndex)];
        let effectOutcomes = resolveEffect(prng, scenarioTemplate, scenario, choice.effect);
        Iter.toArray(effectOutcomes);
    };

    public func resolveEffect(
        prng : Prng,
        scenarioTemplate : Scenario.Template,
        scenario : Scenario.Instance,
        effect : Scenario.Effect,
    ) : Iter.Iter<Scenario.EffectOutcome> {
        let singleEffect : Scenario.EffectOutcome = switch (effect) {
            case (#allOf(subEffects)) {
                return subEffects
                |> Iter.fromArray(_)
                |> Iter.map(
                    _,
                    func(subEffect : Scenario.Effect) : Iter.Iter<Scenario.EffectOutcome> = resolveEffect(prng, scenarioTemplate, scenario, subEffect),
                )
                |> IterTools.flatten(_);
            };
            case (#oneOf(subEffects)) {
                let weightedSubEffects = Array.map<(Nat, Scenario.Effect), (Scenario.Effect, Float)>(
                    subEffects,
                    func((weight, effect) : (Nat, Scenario.Effect)) : (Scenario.Effect, Float) = (effect, Float.fromInt(weight)),
                );
                let subEffect = prng.nextArrayElementWeighted(weightedSubEffects);
                return resolveEffect(prng, scenarioTemplate, scenario, subEffect);
            };
            case (#trait(trait)) {
                #trait({
                    trait with
                    target = getTargetInstance(scenario, trait.target)
                });
            };
            case (#removeTrait(removeTrait)) {
                #removeTrait({
                    removeTrait with
                    target = getTargetInstance(scenario, removeTrait.target)
                });
            };
            case (#entropy(entropyEffect)) {
                #entropy({
                    teamId = getTeamId(scenario, entropyEffect.team);
                    delta = entropyEffect.delta;
                });
            };
            case (#injury(injuryEffect)) {
                #injury({
                    target = getTargetInstance(scenario, injuryEffect.target);
                    injury = injuryEffect.injury;
                });
            };
            case (#noEffect) {
                return {
                    next = func() : ?Scenario.EffectOutcome = null;
                };
            };
        };
        var used = false;
        {
            next = func() : ?Scenario.EffectOutcome {
                if (used) {
                    return null;
                };
                used := true;
                ?singleEffect;
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
            templateId = scenario.id;
            teamId = team1Id;
            opposingTeamId = team2Id;
            otherTeamIds = Buffer.toArray(otherTeamIds);
            playerIds = Buffer.toArray(playerIds);
        };
    };

};
