import PseudoRandomX "mo:random/PseudoRandomX";
import Iter "mo:base/Iter";
import Principal "mo:base/Principal";
import Buffer "mo:base/Buffer";
import Debug "mo:base/Debug";
import Array "mo:base/Array";
import Float "mo:base/Float";
import Nat "mo:base/Nat";
import Text "mo:base/Text";
import Trie "mo:base/Trie";
import Option "mo:base/Option";
import Nat32 "mo:base/Nat32";
import Scenario "../models/Scenario";
import IterTools "mo:itertools/Iter";
import TextX "mo:xtended-text/TextX";
import FieldPosition "../models/FieldPosition";

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

    type EffectContext = {
        #league;
        #team : Team;
    };

    public type Team = {
        id : Principal;
        positions : FieldPosition.TeamPositions;
        option : Nat;
    };

    public func validateScenario(scenario : Scenario.Scenario, traitIds : [Text]) : ValidateScenarioResult {
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
            case (#skill(s)) {
                // TODO
            };
            case (#energy(e)) {
                // TODO
            };
            case (#entropy(_)) {};
            case (#injury(_)) {};
            case (#noEffect) {};
        };
        #ok;
    };

    public func resolveScenario(
        prng : Prng,
        scenario : Scenario.Scenario,
        teams : [Team],
    ) : Scenario.ResolvedScenario {
        let effectOutcomes = Buffer.Buffer<Scenario.EffectOutcome>(0);
        let teamChoices = Buffer.Buffer<{ teamId : Principal; option : Nat }>(0);
        for (team in Iter.fromArray(teams)) {
            let choice = scenario.options[team.option];
            teamChoices.add({
                teamId = team.id;
                option = team.option;
            });
            resolveEffectInternal(
                prng,
                #team(team),
                scenario,
                choice.effect,
                effectOutcomes,
            );
        };
        switch (scenario.effect) {
            case (#simple) ();
            case (#leagueChoice(leagueChoice)) {
                let leagueOptionIndex = getMajorityOption(prng, teams);
                let leagueOption = leagueChoice.options[leagueOptionIndex];
                resolveEffectInternal(prng, #league, scenario, leagueOption.effect, effectOutcomes);
            };
            case (#lottery(lottery)) {

            };
            case (#pickASide(pickASide)) {

            };
            case (#proportionalBid(proportionalBid)) {

            };
            case (#threshold(threshold)) {

            };
        };
        {
            scenario with
            teamChoices = Buffer.toArray(teamChoices);
            effectOutcomes = Buffer.toArray(effectOutcomes);
        };
    };

    public func resolveEffect(
        prng : Prng,
        context : EffectContext,
        scenario : Scenario.Scenario,
        effect : Scenario.Effect,
    ) : [Scenario.EffectOutcome] {
        let buffer = Buffer.Buffer<Scenario.EffectOutcome>(0);
        resolveEffectInternal(prng, context, scenario, effect, buffer);
        Buffer.toArray(buffer);
    };

    private func resolveEffectInternal(
        prng : Prng,
        context : EffectContext,
        scenario : Scenario.Scenario,
        effect : Scenario.Effect,
        outcomes : Buffer.Buffer<Scenario.EffectOutcome>,
    ) {
        switch (effect) {
            case (#allOf(subEffects)) {
                for (subEffect in Iter.fromArray(subEffects)) {
                    resolveEffectInternal(prng, context, scenario, subEffect, outcomes);
                };
            };
            case (#oneOf(subEffects)) {
                let weightedSubEffects = Array.map<(Nat, Scenario.Effect), (Scenario.Effect, Float)>(
                    subEffects,
                    func((weight, effect) : (Nat, Scenario.Effect)) : (Scenario.Effect, Float) = (effect, Float.fromInt(weight)),
                );
                let subEffect = prng.nextArrayElementWeighted(weightedSubEffects);
                resolveEffectInternal(prng, context, scenario, subEffect, outcomes);
            };
            case (#entropy(entropyEffect)) {
                outcomes.add(
                    #entropy({
                        teamId = getTeamId(entropyEffect.team, context);
                        delta = entropyEffect.delta;
                    })
                );
            };
            case (#injury(injuryEffect)) {
                outcomes.add(
                    #injury({
                        target = getTargetInstance(scenario, context, injuryEffect.target);
                        injury = injuryEffect.injury;
                    })
                );
            };
            case (#skill(s)) {
                outcomes.add(
                    #skill({
                        target = getTargetInstance(scenario, context, s.target);
                        skill = s.skill;
                        duration = s.duration;
                        delta = s.delta;
                    })
                );
            };
            case (#energy(e)) {
                let delta = switch (e.value) {
                    case (#flat(fixed)) fixed;
                };
                outcomes.add(
                    #energy({
                        teamId = getTeamId(e.team, context);
                        delta = delta;
                    })
                );
            };
            case (#noEffect) ();
        };
    };

    private func getMajorityOption(
        prng : Prng,
        teamChoices : [Team],
    ) : Nat {
        if (teamChoices.size() < 1) {
            Debug.trap("No team choices");
        };
        // Get the top choice(s), if there is a tie, choose randomly
        var choiceCounts = Trie.empty<Nat, Nat>();
        var maxCount = 0;
        for (teamChoice in Iter.fromArray(teamChoices)) {
            let choiceKey = {
                key = teamChoice.option;
                hash = Nat32.fromNat(teamChoice.option);
            };
            let currentCount = Option.get(Trie.get(choiceCounts, choiceKey, Nat.equal), 0);
            let newCount = currentCount + 1;
            let (newChoiceCounts, _) = Trie.put(choiceCounts, choiceKey, Nat.equal, newCount);
            choiceCounts := newChoiceCounts;
            if (newCount > maxCount) {
                maxCount := newCount;
            };
        };
        let topChoices = Buffer.Buffer<Nat>(0);
        for ((option, choiceCount) in Trie.iter(choiceCounts)) {
            if (choiceCount == maxCount) {
                topChoices.add(option);
            };
        };
        if (topChoices.size() == 1) {
            topChoices.get(0);
        } else {
            prng.nextBufferElement(topChoices);
        };

    };

    private func getTeamId(
        team : Scenario.TargetTeam,
        context : EffectContext,
    ) : Principal {
        let choosingTeam = switch (context) {
            case (#league) Debug.trap("Cannot get team id for league context");
            case (#team(team)) team;
        };
        switch (team) {
            case (#choosingTeam) choosingTeam.id;
        };
    };

    private func getPlayerId(
        player : Scenario.TargetPlayer,
        context : EffectContext,
    ) : Nat32 {
        let choosingTeam = switch (context) {
            case (#league) Debug.trap("Cannot get team id for league context");
            case (#team(team)) team;
        };
        switch (player) {
            case (#position(p)) FieldPosition.getTeamPosition(choosingTeam.positions, p);
        };
    };

    private func getTargetInstance(
        scenario : Scenario.Scenario,
        context : EffectContext,
        target : Scenario.Target,
    ) : Scenario.TargetInstance {
        switch (target) {
            case (#league) #league;
            case (#teams(teams)) {
                let teamIds = teams
                |> Iter.fromArray(_)
                |> Iter.map(
                    _,
                    func(team : Scenario.TargetTeam) : Principal = getTeamId(team, context),
                )
                |> Iter.toArray(_);
                #teams(teamIds);
            };
            case (#players(players)) {
                let playerIds = players
                |> Iter.fromArray(_)
                |> Iter.map(
                    _,
                    func(player : Scenario.TargetPlayer) : Nat32 = getPlayerId(player, context),
                )
                |> Iter.toArray(_);
                #players(playerIds);
            };
        };
    };

};
