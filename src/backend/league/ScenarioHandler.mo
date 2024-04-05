import Scenario "../models/Scenario";
import HashMap "mo:base/HashMap";
import Iter "mo:base/Iter";
import Text "mo:base/Text";
import Types "Types";
import PseudoRandomX "mo:random/PseudoRandomX";
import Buffer "mo:base/Buffer";
import Debug "mo:base/Debug";
import Array "mo:base/Array";
import Float "mo:base/Float";
import Nat "mo:base/Nat";
import Trie "mo:base/Trie";
import Option "mo:base/Option";
import Nat32 "mo:base/Nat32";
import Random "mo:base/Random";
import Error "mo:base/Error";
import Timer "mo:base/Timer";
import Time "mo:base/Time";
import Int "mo:base/Int";
import TextX "mo:xtended-text/TextX";
import TeamTypes "../team/Types";
import TeamsActor "canister:teams";
import IterTools "mo:itertools/Iter";

module {
    type Prng = PseudoRandomX.PseudoRandomGenerator;

    public type StableData = {
        scenarios : [ScenarioData];
    };

    public type TeamScenarioData = {
        id : Nat;
        option : Nat;
    };

    public type AddScenarioResult = {
        #ok;
        #invalid : [Text];
    };

    public type StartScenarioResult = {
        #ok;
        #alreadyStarted;
        #notFound;
    };

    public type ProcessEffectOutcomesResult = {
        #ok : [EffectOutcomeData];
    };

    type ScenarioData = {
        id : Text;
        title : Text;
        description : Text;
        options : [Scenario.ScenarioOptionWithEffect];
        metaEffect : Scenario.MetaEffect;
        state : ScenarioState;
        startTime : Time.Time;
        endTime : Time.Time;
        teamIds : [Nat];
    };

    type ScenarioState = {
        #notStarted : {
            startTimerId : Nat;
        };
        #inProgress : {
            endTimerId : Nat;
        };
        #resolved : ScenarioStateResolved;
    };

    public type ScenarioStateResolved = {
        teamChoices : [TeamScenarioData];
        effectOutcomes : [EffectOutcomeData];
    };

    public type EffectOutcomeData = {
        processed : Bool;
        outcome : Scenario.EffectOutcome;
    };

    public class Handler<system>(data : StableData, processEffectOutcomes : (outcomes : [Scenario.EffectOutcome]) -> async* ProcessEffectOutcomesResult) {
        let scenarios : HashMap.HashMap<Text, ScenarioData> = toHashMap(data.scenarios);

        public func toStableData() : StableData {
            {
                scenarios = scenarios.vals()
                |> Iter.toArray(_);
            };
        };

        public func getScenario(id : Text) : ?Scenario.Scenario {
            do ? {
                let data = scenarios.get(id)!;
                mapScenarioDataToScenario(data);
            };
        };

        public func getScenarios(includeNotStarted : Bool) : [Scenario.Scenario] {
            scenarios.vals()
            |> Iter.filter(
                _,
                func(scenario : ScenarioData) : Bool = switch (scenario.state) {
                    case (#notStarted(_)) includeNotStarted;
                    case (#inProgress(_) or #resolved(_)) true;
                },
            )
            |> Iter.map(
                _,
                mapScenarioDataToScenario,
            )
            |> Iter.toArray(_);
        };

        public func add<system>(scenario : Types.AddScenarioRequest) : AddScenarioResult {
            switch (validateScenario(scenario)) {
                case (#ok) {};
                case (#invalid(errors)) return #invalid(errors);
            };
            if (scenarios.get(scenario.id) != null) {
                return #invalid(["Scenario with id '" #scenario.id # "' already exists"]);
            };
            let startTimerId = createStartTimer<system>(scenario.id, scenario.startTime);
            scenarios.put(
                scenario.id,
                {

                    id = scenario.id;
                    title = scenario.title;
                    description = scenario.description;
                    options = scenario.options;
                    metaEffect = scenario.metaEffect;
                    state = #notStarted({
                        startTimerId = startTimerId;
                    });
                    startTime = scenario.startTime;
                    endTime = scenario.endTime;
                    teamIds = scenario.teamIds;
                },
            );
            #ok;
        };

        private func start(scenarioId : Text) : async* StartScenarioResult {
            let ?scenario = scenarios.get(scenarioId) else return #notFound;
            switch (scenario.state) {
                case (#notStarted({ startTimerId })) {
                    Timer.cancelTimer(startTimerId);
                    ignore scenarios.replace(
                        scenarioId,
                        {
                            scenario with
                            state = #inProgress({
                                endTimerId = createEndTimer<system>(scenarioId, scenario.endTime);
                            })
                        },
                    );
                    let onScenarioStartRequest = {
                        scenarioId = scenarioId;
                        optionCount = scenario.options.size();
                    };
                    switch (await TeamsActor.onScenarioStart(onScenarioStartRequest)) {
                        case (#ok) ();
                        case (#notAuthorized) Debug.print("ERROR: Not authorized to start scenario for teams");
                    };
                    #ok;
                };
                case (#inProgress(_)) #alreadyStarted;
                case (#resolved(_)) #alreadyStarted;
            };
        };

        private func end(scenarioId : Text) : async* {
            #ok;
            #scenarioNotFound;
        } {
            let prng = PseudoRandomX.fromBlob(await Random.blob());
            let ?scenario = scenarios.get(scenarioId) else return #scenarioNotFound;
            let teamScenarioData = await* buildTeamScenarioData(scenario);
            let resolvedScenarioState = resolve(
                scenarioId,
                teamScenarioData,
                prng,
            );

            let effectOutcomes = resolvedScenarioState.effectOutcomes.vals()
            |> Iter.filter(
                _,
                func(outcome : EffectOutcomeData) : Bool = not outcome.processed,
            )
            |> Iter.map(
                _,
                func(outcome : EffectOutcomeData) : Scenario.EffectOutcome = outcome.outcome,
            )
            |> Iter.toArray(_);

            // TODO how to reproccess them?
            let processedScenarioState : ScenarioStateResolved = switch (await* processEffectOutcomes(effectOutcomes)) {
                case (#ok(updatedEffectOutcomes)) {

                    // Rejoin already processed outcomes with the newly processed ones
                    let processedOutcomes = resolvedScenarioState.effectOutcomes.vals()
                    |> Iter.filter(
                        _,
                        func(outcome : EffectOutcomeData) : Bool = outcome.processed,
                    )
                    |> Buffer.fromIter<EffectOutcomeData>(_);

                    processedOutcomes.append(Buffer.fromArray(updatedEffectOutcomes));

                    {
                        resolvedScenarioState with
                        effectOutcomes = Buffer.toArray(processedOutcomes)
                    };
                };
            };
            scenarios.put(
                scenarioId,
                {
                    scenario with
                    state = #resolved(processedScenarioState);
                },
            );
            #ok;
        };

        private func resolve(
            scenarioId : Text,
            scenarioTeams : [TeamScenarioData],
            prng : Prng,
        ) : ScenarioStateResolved {
            let ?scenario = scenarios.get(scenarioId) else Debug.trap("Scenario not found: " # scenarioId);
            resolveScenario(
                prng,
                scenario,
                scenarioTeams,
            );
        };

        private func createStartTimer<system>(scenarioId : Text, startTime : Time.Time) : Nat {
            createTimer<system>(
                startTime,
                func() : async* () {
                    Debug.print("Starting scenario with timer. Scenario id: " # scenarioId);
                    switch (await* start(scenarioId)) {
                        case (#ok) ();
                        case (#alreadyStarted) Debug.trap("Scenario already started: " # scenarioId);
                        case (#notFound) Debug.trap("Scenario not found: " # scenarioId);
                    };
                },
            );
        };

        private func createEndTimer<system>(scenarioId : Text, endTime : Time.Time) : Nat {
            createTimer<system>(
                endTime,
                func() : async* () {
                    Debug.print("Ending scenario with timer. Scenario id: " # scenarioId);
                    switch (await* end(scenarioId)) {
                        case (#ok) ();
                        case (#scenarioNotFound) Debug.trap("Scenario not found: " # scenarioId);
                    };
                },
            );
        };

        private func createTimer<system>(time : Time.Time, func_ : () -> async* ()) : Nat {
            let durationNanos = time - Time.now();
            let durationNanosNat = if (durationNanos < 0) {
                0;
            } else {
                Int.abs(durationNanos);
            };
            Timer.setTimer<system>(
                #nanoseconds(durationNanosNat),
                func() : async () {
                    await* func_();
                },
            );
        };

        private func resetTimers<system>() : () {
            for (scenario in scenarios.vals()) {
                let updatedScenario = switch (scenario.state) {
                    case (#notStarted({ startTimerId })) {
                        Timer.cancelTimer(startTimerId);
                        ?{
                            scenario with
                            state = #notStarted({
                                startTimerId = createStartTimer<system>(scenario.id, scenario.startTime);
                            });
                        };
                    };
                    case (#inProgress({ endTimerId })) {
                        Timer.cancelTimer(endTimerId);
                        ?{
                            scenario with
                            state = #inProgress({
                                endTimerId = createEndTimer<system>(scenario.id, scenario.startTime);
                            });
                        };
                    };
                    case (#resolved(_)) null;
                };
                switch (updatedScenario) {
                    case (?s) scenarios.put(scenario.id, s);
                    case (null) ();
                };
            };

        };

        ignore resetTimers<system>();
    };

    private func mapScenarioDataToScenario(data : ScenarioData) : Scenario.Scenario {
        let state : Scenario.ScenarioState = switch (data.state) {
            case (#notStarted(_)) #notStarted;
            case (#inProgress(_)) #inProgress;
            case (#resolved(resolved)) #resolved({
                resolved with
                teamChoices = resolved.teamChoices.vals()
                |> Iter.map(
                    _,
                    func(team : TeamScenarioData) : {
                        teamId : Nat;
                        option : Nat;
                    } = {
                        teamId = team.id;
                        option = team.option;
                    },
                )
                |> Iter.toArray(_);
                effectOutcomes = resolved.effectOutcomes.vals()
                |> Iter.map(
                    _,
                    func(outcome : EffectOutcomeData) : Scenario.EffectOutcome = outcome.outcome,
                )
                |> Iter.toArray(_);
            });
        };
        {
            id = data.id;
            title = data.title;
            description = data.description;
            options = data.options;
            metaEffect = data.metaEffect;
            state = state;
        };
    };

    private func buildTeamScenarioData(scenario : ScenarioData) : async* [TeamScenarioData] {
        let teamScenarioData = Buffer.Buffer<TeamScenarioData>(scenario.teamIds.size());

        let scenarioResults = try {
            await TeamsActor.getScenarioVotingResults({
                scenarioId = scenario.id;
            });
        } catch (err : Error.Error) {
            return Debug.trap("Failed to get scenario voting results: " # Error.message(err));
        };
        let teamResults = switch (scenarioResults) {
            case (#ok(o)) o;
            case (#scenarioNotFound) return Debug.trap("Scenario not found: " # scenario.id);
            case (#notAuthorized) return Debug.trap("League is not authorized to get scenario results");
        };

        for (teamId in Iter.fromArray(scenario.teamIds)) {
            let optionOrNull = IterTools.find(teamResults.teamOptions.vals(), func(o : TeamTypes.ScenarioTeamVotingResult) : Bool = o.teamId == teamId);
            let option = switch (optionOrNull) {
                case (?o) o.option;
                case (null) 0; // TODO random if no votes?
            };

            teamScenarioData.add({
                id = teamId;
                option = option;
            });
        };

        let energyDividends = scenario.teamIds.vals()
        |> Iter.map<Nat, TeamTypes.EnergyDividend>(
            _,
            func(teamId : Nat) : TeamTypes.EnergyDividend {
                let energy = 5; // TODO
                {
                    teamId = teamId;
                    energy = energy;
                };
            },
        )
        |> Iter.toArray(_);
        let onScenarioEndRequest = {
            scenarioId = scenario.id;
            energyDividends = energyDividends;
        };
        switch (await TeamsActor.onScenarioEnd(onScenarioEndRequest)) {
            case (#ok) ();
            case (#notAuthorized) Debug.print("ERROR: Not authorized to end scenario for teams");
            case (#scenarioNotFound) Debug.print("ERROR: Scenario not found");
        };

        Buffer.toArray(teamScenarioData);
    };

    type ValidateScenarioResult = {
        #ok;
        #invalid : [Text];
    };

    type ValidateEffectResult = {
        #ok;
        #invalid : [Text];
    };

    type EffectContext = {
        #league;
        #team : TeamScenarioData;
    };

    public func validateScenario(scenario : Types.AddScenarioRequest) : ValidateScenarioResult {
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
            switch (validateEffect(option.effect)) {
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

    private func validateEffect(effect : Scenario.Effect) : ValidateEffectResult {
        let errors = Buffer.Buffer<Text>(0);
        switch (effect) {
            case (#allOf(subEffects)) {
                var index = 0;
                for (subEffect in Iter.fromArray(subEffects)) {
                    switch (validateEffect(subEffect)) {
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
                    switch (validateEffect(subEffect)) {
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
        scenario : ScenarioData,
        teams : [TeamScenarioData],
    ) : ScenarioStateResolved {
        let effectOutcomes = Buffer.Buffer<Scenario.EffectOutcome>(0);
        let teamChoices = Buffer.Buffer<TeamScenarioData>(0);
        for (team in Iter.fromArray(teams)) {
            let choice = scenario.options[team.option];
            teamChoices.add({
                id = team.id;
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
        switch (scenario.metaEffect) {
            case (#noEffect) ();
            case (#leagueChoice(leagueChoice)) {
                let leagueOptionIndex = getMajorityOption(prng, teams);
                let leagueOption = leagueChoice.options[leagueOptionIndex];
                resolveEffectInternal(prng, #league, scenario, leagueOption.effect, effectOutcomes);
            };
            case (#lottery(lottery)) {
                // TODO
            };
            case (#pickASide(pickASide)) {
                // TODO
            };
            case (#proportionalBid(proportionalBid)) {
                // TODO
            };
            case (#threshold(threshold)) {
                // TODO
            };
        };
        {
            teamChoices = Buffer.toArray(teamChoices);
            effectOutcomes = effectOutcomes.vals()
            |> Iter.map(
                _,
                func(outcome : Scenario.EffectOutcome) : EffectOutcomeData = {
                    processed = false;
                    outcome = outcome;
                },
            )
            |> Iter.toArray(_);
        };
    };

    public func resolveEffect(
        prng : Prng,
        context : EffectContext,
        scenario : ScenarioData,
        effect : Scenario.Effect,
    ) : [Scenario.EffectOutcome] {
        let buffer = Buffer.Buffer<Scenario.EffectOutcome>(0);
        resolveEffectInternal(prng, context, scenario, effect, buffer);
        Buffer.toArray(buffer);
    };

    private func resolveEffectInternal(
        prng : Prng,
        context : EffectContext,
        scenario : ScenarioData,
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
                        target = getTargetInstance(context, injuryEffect.target);
                        injury = injuryEffect.injury;
                    })
                );
            };
            case (#skill(s)) {
                outcomes.add(
                    #skill({
                        target = getTargetInstance(context, s.target);
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
        teamChoices : [TeamScenarioData],
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
    ) : Nat {
        let choosingTeam = switch (context) {
            case (#league) Debug.trap("Cannot get team id for league context");
            case (#team(team)) team;
        };
        switch (team) {
            case (#choosingTeam) choosingTeam.id;
        };
    };

    private func getTargetInstance(
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
                    func(team : Scenario.TargetTeam) : Nat = getTeamId(team, context),
                )
                |> Iter.toArray(_);
                #teams(teamIds);
            };
            case (#positions(positions)) {
                let mappedPositions = positions
                |> Iter.fromArray(_)
                |> Iter.map(
                    _,
                    func(target : Scenario.TargetPosition) : Scenario.TargetPositionInstance = {
                        teamId = getTeamId(target.teamId, context);
                        position = target.position;
                    },
                )
                |> Iter.toArray(_);
                #positions(mappedPositions);
            };
        };
    };

    private func toHashMap(scenarios : [ScenarioData]) : HashMap.HashMap<Text, ScenarioData> {
        scenarios
        |> Iter.fromArray(_)
        |> Iter.map<ScenarioData, (Text, ScenarioData)>(
            _,
            func(scenario : ScenarioData) : (Text, ScenarioData) = (scenario.id, scenario),
        )
        |> HashMap.fromIter<Text, ScenarioData>(_, scenarios.size(), Text.equal, Text.hash);

    };
};
