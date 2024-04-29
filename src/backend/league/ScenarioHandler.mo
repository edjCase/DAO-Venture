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
import Prelude "mo:base/Prelude";
import Principal "mo:base/Principal";
import TextX "mo:xtended-text/TextX";
import IterTools "mo:itertools/Iter";
import UsersActor "canister:users";
import UserTypes "../users/Types";

module {
    type Prng = PseudoRandomX.PseudoRandomGenerator;

    public type StableData = {
        scenarios : [ScenarioData];
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

    public type VoterInfo = {
        teamId : Nat;
        id : Principal;
        votingPower : Nat;
    };

    public type Vote = VoterInfo and {
        option : ?Nat;
    };

    type ScenarioDataWithoutVotes = {
        id : Nat;
        title : Text;
        description : Text;
        options : [Scenario.ScenarioOptionWithEffect];
        metaEffect : Scenario.MetaEffect;
        state : ScenarioState;
        startTime : Time.Time;
        endTime : Time.Time;
        teamIds : [Nat];
    };

    public type ScenarioData = ScenarioDataWithoutVotes and {
        votes : [Vote];
    };

    type MutableScenarioData = ScenarioDataWithoutVotes and {
        votes : HashMap.HashMap<Principal, Vote>;
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
        teamChoices : [TeamVotingResult];
        effectOutcomes : [EffectOutcomeData];
    };

    public type EffectOutcomeData = {
        processed : Bool;
        outcome : Scenario.EffectOutcome;
    };
    public type TeamVotingResult = {
        id : Nat;
        option : Nat;
    };

    public class Handler<system>(
        data : StableData,
        processEffectOutcomes : (
            outcomes : [Scenario.EffectOutcome]
        ) -> async* ProcessEffectOutcomesResult,
    ) {
        let scenarios : HashMap.HashMap<Nat, MutableScenarioData> = toHashMap(data.scenarios);
        var nextScenarioId = scenarios.size(); // TODO max id + 1

        public func toStableData() : StableData {
            {
                scenarios = scenarios.vals()
                |> Iter.map<MutableScenarioData, ScenarioData>(
                    _,
                    toStableScenarioData,
                )
                |> Iter.toArray(_);
            };
        };

        public func getScenario(id : Nat) : ?Scenario.Scenario {
            do ? {
                let data = scenarios.get(id)!;
                mapScenarioDataToScenario(data);
            };
        };

        public func getScenarios(includeNotStarted : Bool) : [Scenario.Scenario] {
            scenarios.vals()
            |> Iter.filter(
                _,
                func(scenario : MutableScenarioData) : Bool = switch (scenario.state) {
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

        public func vote(
            scenarioId : Nat,
            voterId : Principal,
            option : Nat,
        ) : async* {
            #ok;
            #invalidOption;
            #alreadyVoted;
            #notEligible;
            #scenarioNotFound;
        } {

            let ?scenario = scenarios.get(scenarioId) else return #scenarioNotFound;
            let choiceExists = option < scenario.options.size();
            if (not choiceExists) {
                return #invalidOption;
            };
            let ?vote = scenario.votes.get(voterId) else return #notEligible;
            if (vote.option != null) {
                return #alreadyVoted;
            };
            scenario.votes.put(
                voterId,
                {
                    vote with
                    option = ?option;
                },
            );
            switch (calculateResultsInternal(scenario, false)) {
                case (#noConsensus) ();
                case (#consensus(_)) {
                    await* end(scenario);
                };
            };
            #ok;
        };

        public func getVote(scenarioId : Nat, voterId : Principal) : {
            #ok : { option : ?Nat; votingPower : Nat };
            #notEligible;
            #scenarioNotFound;
        } {
            let ?scenario = scenarios.get(scenarioId) else return #scenarioNotFound;
            switch (scenario.votes.get(voterId)) {
                case (null) #notEligible;
                case (?v) #ok(v);
            };
        };

        private func calculateResultsInternal(scenario : MutableScenarioData, votingClosed : Bool) : {
            #consensus : [TeamVotingResult];
            #noConsensus;
        } {
            type TeamStats = {
                var totalVotingPower : Nat;
                optionVotingPowers : [var Nat];
            };
            let teamStats = HashMap.HashMap<Nat, TeamStats>(0, Nat.equal, Nat32.fromNat);

            for (vote in scenario.votes.vals()) {
                let stats : TeamStats = switch (teamStats.get(vote.teamId)) {
                    case (null) {
                        let initStats : TeamStats = {
                            var totalVotingPower = 0;
                            optionVotingPowers = Array.init<Nat>(scenario.options.size(), 0);
                        };
                        teamStats.put(vote.teamId, initStats);
                        initStats;
                    };
                    case (?voterTeamStats) voterTeamStats;
                };
                stats.totalVotingPower += vote.votingPower;
                switch (vote.option) {
                    case (?option) stats.optionVotingPowers[option] += vote.votingPower;
                    case (null) ();
                };
            };
            let teamResults = Buffer.Buffer<TeamVotingResult>(teamStats.size());
            for ((teamId, stats) in teamStats.entries()) {
                var optionWithMostVotes : (Nat, Nat) = (0, 0);

                // Calculate the option with the most votes
                for ((option, optionVotingPower) in IterTools.enumerate(stats.optionVotingPowers.vals())) {
                    if (optionVotingPower > optionWithMostVotes.1) {
                        // TODO what to do in a tie?
                        optionWithMostVotes := (option, optionVotingPower);
                    };
                };

                // If voting is not closed, check to see if there is a majority to end early or not
                if (not votingClosed) {
                    // Validate that the majority has been reached, if voting is still active
                    let minMajorityVotingPower : Nat = Int.abs(Float.toInt(Float.floor(Float.fromInt(stats.totalVotingPower) / 2.) + 1));
                    if (minMajorityVotingPower >= optionWithMostVotes.1) {
                        return #noConsensus; // If any team hasnt reached a consensus, wait till its forced (end of voting period)
                    };
                };
                teamResults.add({
                    id = teamId;
                    option = optionWithMostVotes.0;
                });
            };

            #consensus(Buffer.toArray(teamResults));
        };

        public func add<system>(scenario : Types.AddScenarioRequest) : async* AddScenarioResult {
            switch (validateScenario(scenario)) {
                case (#ok) {};
                case (#invalid(errors)) return #invalid(errors);
            };

            let members = try {
                switch (await UsersActor.getTeamOwners(#all)) {
                    case (#ok(members)) members;
                };
            } catch (err) {
                Debug.trap("Failed to get team owners from user canister: " # Error.message(err));
            };
            let votes = members.vals()
            |> Iter.map<UserTypes.UserVotingInfo, (Principal, Vote)>(
                _,
                func(member : UserTypes.UserVotingInfo) : (Principal, Vote) = (
                    member.id,
                    {
                        id = member.id;
                        teamId = member.teamId;
                        votingPower = member.votingPower;
                        option = null;
                    },
                ),
            )
            |> HashMap.fromIter<Principal, Vote>(_, members.size(), Principal.equal, Principal.hash);

            let scenarioId = nextScenarioId;
            nextScenarioId += 1;
            let startTimerId = createStartTimer<system>(scenarioId, scenario.startTime);
            scenarios.put(
                scenarioId,
                {

                    id = scenarioId;
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
                    votes = votes;
                },
            );
            #ok;
        };

        private func start(scenarioId : Nat) : async* StartScenarioResult {
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
                    #ok;
                };
                case (#inProgress(_)) #alreadyStarted;
                case (#resolved(_)) #alreadyStarted;
            };
        };

        private func end(scenario : MutableScenarioData) : async* () {
            let prng = PseudoRandomX.fromBlob(await Random.blob());
            let teamVotingResult = switch (calculateResultsInternal(scenario, true)) {
                case (#consensus(teamVotingResult)) teamVotingResult;
                case (#noConsensus) Prelude.unreachable();
            };
            let resolvedScenarioState = resolveScenario(
                prng,
                scenario,
                teamVotingResult,
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
                scenario.id,
                {
                    scenario with
                    state = #resolved(processedScenarioState);
                },
            );
        };

        private func createStartTimer<system>(scenarioId : Nat, startTime : Time.Time) : Nat {
            createTimer<system>(
                startTime,
                func() : async* () {
                    Debug.print("Starting scenario with timer. Scenario id: " # Nat.toText(scenarioId));
                    switch (await* start(scenarioId)) {
                        case (#ok) ();
                        case (#alreadyStarted) Debug.trap("Scenario already started: " # Nat.toText(scenarioId));
                        case (#notFound) Debug.trap("Scenario not found: " # Nat.toText(scenarioId));
                    };
                },
            );
        };

        private func createEndTimer<system>(scenarioId : Nat, endTime : Time.Time) : Nat {
            createTimer<system>(
                endTime,
                func() : async* () {
                    Debug.print("Ending scenario with timer. Scenario id: " # Nat.toText(scenarioId));
                    let ?scenario = scenarios.get(scenarioId) else Debug.trap("Scenario not found: " # Nat.toText(scenarioId));
                    await* end(scenario);
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

        resetTimers<system>();
    };

    private func mapScenarioDataToScenario(data : MutableScenarioData) : Scenario.Scenario {
        let state : Scenario.ScenarioState = switch (data.state) {
            case (#notStarted(_)) #notStarted;
            case (#inProgress(_)) #inProgress;
            case (#resolved(resolved)) #resolved({
                teamChoices = resolved.teamChoices.vals()
                |> Iter.map(
                    _,
                    func(team : TeamVotingResult) : {
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
            startTime = data.startTime;
            endTime = data.endTime;
            description = data.description;
            options = data.options;
            metaEffect = data.metaEffect;
            state = state;
        };
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
        #team : Nat;
    };

    public func validateScenario(scenario : Types.AddScenarioRequest) : ValidateScenarioResult {
        let errors = Buffer.Buffer<Text>(0);
        if (TextX.isEmptyOrWhitespace(scenario.title)) {
            errors.add("Scenario must have a title");
        };
        if (TextX.isEmptyOrWhitespace(scenario.description)) {
            errors.add("Scenario must have a description");
        };
        if (scenario.options.size() < 2) {
            errors.add("Scenario must have at least 2 options");
        };
        if (scenario.teamIds.size() < 1) {
            errors.add("Scenario must have at least 1 team");
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
        scenario : ScenarioDataWithoutVotes,
        teamChoices : [TeamVotingResult],
    ) : ScenarioStateResolved {
        let effectOutcomes = Buffer.Buffer<Scenario.EffectOutcome>(0);
        for (teamData in Iter.fromArray(teamChoices)) {
            let choice = scenario.options[teamData.option];
            resolveEffectInternal(
                prng,
                #team(teamData.id),
                scenario,
                choice.effect,
                effectOutcomes,
            );
        };
        switch (scenario.metaEffect) {
            case (#noEffect) ();
            case (#leagueChoice(leagueChoice)) {
                let leagueOptionIndex = getMajorityOption(prng, teamChoices);
                let leagueOption = leagueChoice.options[leagueOptionIndex];
                resolveEffectInternal(prng, #league, scenario, leagueOption.effect, effectOutcomes);
            };
            case (#lottery(lottery)) {
                let weightedTickets : [(Nat, Float)] = teamChoices.vals()
                |> Iter.map<TeamVotingResult, (Nat, Float)>(
                    _,
                    func(teamData : TeamVotingResult) : (Nat, Float) = (teamData.id, Float.fromInt(lottery.options[teamData.option].tickets)),
                )
                |> Iter.toArray(_);
                let winningTeamId = prng.nextArrayElementWeighted(weightedTickets);
                resolveEffectInternal(prng, #team(winningTeamId), scenario, lottery.prize, effectOutcomes);
            };
            case (#proportionalBid(proportionalBid)) {
                let totalBid = Array.foldLeft(
                    teamChoices,
                    0,
                    func(total : Nat, teamData : TeamVotingResult) : Nat = total + proportionalBid.options[teamData.option].bidValue,
                );
                for (teamData in teamChoices.vals()) {
                    let percentOfPrize = Float.fromInt(proportionalBid.options[teamData.option].bidValue) / Float.fromInt(totalBid);
                    let purpotionalValue = Float.toInt(percentOfPrize * Float.fromInt(proportionalBid.prize.amount)); // Round down
                    if (purpotionalValue > 0) {

                        let effect : Scenario.Effect = switch (proportionalBid.prize.kind) {
                            case (#skill(s)) {
                                let target : Scenario.Target = switch (s.target) {
                                    case (#position(p)) #positions([{
                                        position = p;
                                        teamId = #choosingTeam;
                                    }]);
                                };
                                #skill({
                                    delta = purpotionalValue;
                                    duration = s.duration;
                                    target = target;
                                    skill = s.skill;
                                });
                            };
                        };
                        resolveEffectInternal(
                            prng,
                            #team(teamData.id),
                            scenario,
                            effect,
                            effectOutcomes,
                        );
                    };
                };
            };
            case (#threshold(threshold)) {
                type TeamValue = {
                    teamId : Nat;
                    value : Int;
                };
                let teamThresholdValues : [TeamValue] = teamChoices.vals()
                |> Iter.map<TeamVotingResult, TeamValue>(
                    _,
                    func(teamData : TeamVotingResult) : TeamValue {
                        let value : Int = switch (threshold.options[teamData.option].value) {
                            case (#fixed(fixed)) fixed;
                            case (#weightedChance(w)) {
                                let wFloat : [(Int, Float)] = w.vals()
                                |> Iter.map<(Int, Nat), (Int, Float)>(
                                    _,
                                    func((value, weight) : (Int, Nat)) : (Int, Float) = (value, Float.fromInt(weight)),
                                )
                                |> Iter.toArray(_);
                                prng.nextArrayElementWeighted(wFloat);
                            };
                        };
                        {
                            teamId = teamData.id;
                            value = value;
                        };
                    },
                )
                |> Iter.toArray(_);
                let valueSum = Array.foldLeft(
                    teamThresholdValues,
                    0,
                    func(total : Int, teamData : TeamValue) : Int = total + teamData.value,
                );
                let thresholdEffect = if (valueSum >= threshold.threshold) {
                    threshold.over;
                } else {
                    threshold.under;
                };

                resolveEffectInternal(prng, #league, scenario, thresholdEffect, effectOutcomes);
            };
        };
        {
            teamChoices = teamChoices;
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
        scenario : ScenarioDataWithoutVotes,
        effect : Scenario.Effect,
    ) : [Scenario.EffectOutcome] {
        let buffer = Buffer.Buffer<Scenario.EffectOutcome>(0);
        resolveEffectInternal(prng, context, scenario, effect, buffer);
        Buffer.toArray(buffer);
    };

    private func resolveEffectInternal(
        prng : Prng,
        context : EffectContext,
        scenario : ScenarioDataWithoutVotes,
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
                let teamIds : [Nat] = switch (entropyEffect.target) {
                    case (#league) scenario.teamIds;
                    case (#teams(teams)) teams.vals()
                    |> Iter.map(_, func(team : Scenario.TargetTeam) : Nat = getTeamId(team, context))
                    |> Iter.toArray(_);
                };
                for (teamId in teamIds.vals()) {
                    outcomes.add(
                        #entropy({
                            teamId = teamId;
                            delta = entropyEffect.delta;
                        })
                    );
                };
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
        teamChoices : [TeamVotingResult],
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
            case (#choosingTeam) choosingTeam;
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

    private func toHashMap(scenarios : [ScenarioData]) : HashMap.HashMap<Nat, MutableScenarioData> {
        scenarios
        |> Iter.fromArray(_)
        |> Iter.map<ScenarioData, (Nat, MutableScenarioData)>(
            _,
            func(scenario : ScenarioData) : (Nat, MutableScenarioData) = (scenario.id, fromStableScenarioData(scenario)),
        )
        |> HashMap.fromIter<Nat, MutableScenarioData>(_, scenarios.size(), Nat.equal, Nat32.fromNat);

    };

    private func fromStableScenarioData(scenario : ScenarioData) : MutableScenarioData {
        let votes = scenario.votes.vals()
        |> Iter.map<Vote, (Principal, Vote)>(
            _,
            func(vote : Vote) : (Principal, Vote) = (vote.id, vote),
        )
        |> HashMap.fromIter<Principal, Vote>(_, scenario.votes.size(), Principal.equal, Principal.hash);
        {
            scenario with
            votes = votes;
        };
    };

    private func toStableScenarioData(scenario : MutableScenarioData) : ScenarioData {
        let votes = scenario.votes.vals()
        |> Iter.toArray(_);
        {
            scenario with
            votes = votes;
        };
    };
};
