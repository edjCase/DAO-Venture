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
import Result "mo:base/Result";
import TextX "mo:xtended-text/TextX";
import IterTools "mo:itertools/Iter";
import UsersActor "canister:users";
import UserTypes "../users/Types";
import Skill "../models/Skill";
import FieldPosition "../models/FieldPosition";

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
        abstainEffect : Scenario.Effect;
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
        metaEffectOutcome : Scenario.MetaEffectOutcome;
        effectOutcomes : [EffectOutcomeData];
    };

    public type EffectOutcomeData = {
        processed : Bool;
        outcome : Scenario.EffectOutcome;
    };
    public type TeamVotingResult = {
        id : Nat;
        option : ?Nat;
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
        ) : async* Result.Result<(), { #invalidOption; #alreadyVoted; #notEligible; #scenarioNotFound }> {

            let ?scenario = scenarios.get(scenarioId) else return #err(#scenarioNotFound);
            let choiceExists = option < scenario.options.size();
            if (not choiceExists) {
                return #err(#invalidOption);
            };
            let ?vote = scenario.votes.get(voterId) else return #err(#notEligible);
            if (vote.option != null) {
                return #err(#alreadyVoted);
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
            let teamsWithVoters = teamStats.entries()
            |> Iter.filter(
                _,
                func(entry : (Nat, TeamStats)) : Bool = entry.1.totalVotingPower > 0,
            );
            for ((teamId, stats) in teamsWithVoters) {
                var optionsWithMostVotes : Buffer.Buffer<(Nat, Nat)> = Buffer.Buffer<(Nat, Nat)>(0);

                // Calculate the options with the most votes
                for ((option, optionVotingPower) in IterTools.enumerate(stats.optionVotingPowers.vals())) {
                    if (optionsWithMostVotes.size() < 1) {
                        optionsWithMostVotes.add((option, optionVotingPower));
                    } else {
                        let maxVotes = optionsWithMostVotes.get(0).1;
                        if (optionVotingPower > maxVotes) {
                            optionsWithMostVotes.clear(); // Reset options if a new max is found
                        };
                        optionsWithMostVotes.add((option, optionVotingPower));
                    };
                };
                let optionWithMostVotes = if (optionsWithMostVotes.size() == 1) {
                    ?optionsWithMostVotes.get(0);
                } else {
                    null;
                };

                // If voting is not closed, check to see if there is a majority to end early or not
                if (not votingClosed) {
                    switch (optionWithMostVotes) {
                        case (null) return #noConsensus;
                        case (?o) {
                            // Validate that the majority has been reached, if voting is still active
                            let minMajorityVotingPower : Nat = Int.abs(Float.toInt(Float.floor(Float.fromInt(stats.totalVotingPower) / 2.) + 1));
                            if (minMajorityVotingPower > o.1) {
                                return #noConsensus;
                            };
                        };
                    };
                };
                let chosenOption : ?Nat = switch (optionWithMostVotes) {
                    case (null) null;
                    case (?o) ?o.0;
                };
                teamResults.add({
                    id = teamId;
                    option = chosenOption;
                });
            };

            #consensus(Buffer.toArray(teamResults));
        };

        public func add<system>(scenario : Types.AddScenarioRequest) : async* AddScenarioResult {
            switch (validateScenario(scenario)) {
                case (#ok) {};
                case (#invalid(errors)) return #invalid(errors);
            };
            let startTime = switch (scenario.startTime) {
                case (null) Time.now();
                case (?t) t;
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
            let startTimerId = createStartTimer<system>(scenarioId, startTime);
            scenarios.put(
                scenarioId,
                {

                    id = scenarioId;
                    title = scenario.title;
                    description = scenario.description;
                    abstainEffect = scenario.abstainEffect;
                    options = scenario.options;
                    metaEffect = scenario.metaEffect;
                    state = #notStarted({
                        startTimerId = startTimerId;
                    });
                    startTime = startTime;
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
            case (#resolved(resolved)) {
                let resolvedData = mapResolvedScenarioState(resolved);
                #resolved(resolvedData);
            };
        };
        {
            id = data.id;
            title = data.title;
            startTime = data.startTime;
            endTime = data.endTime;
            description = data.description;
            abstainEffect = data.abstainEffect;
            options = data.options;
            metaEffect = data.metaEffect;
            state = state;
        };
    };

    private func mapResolvedScenarioState(resolved : ScenarioStateResolved) : Scenario.ScenarioStateResolved {
        let teamChoices = resolved.teamChoices.vals()
        |> Iter.map(
            _,
            func(team : TeamVotingResult) : {
                teamId : Nat;
                option : ?Nat;
            } = {
                teamId = team.id;
                option = team.option;
            },
        )
        |> Iter.toArray(_);

        let effectOutcomes = resolved.effectOutcomes.vals()
        |> Iter.map(
            _,
            func(outcome : EffectOutcomeData) : Scenario.EffectOutcome = outcome.outcome,
        )
        |> Iter.toArray(_);
        {
            teamChoices = teamChoices;
            metaEffectOutcome = resolved.metaEffectOutcome;
            effectOutcomes = effectOutcomes;
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
        let startTime = switch (scenario.startTime) {
            case (null) Time.now();
            case (?t) {
                if (t < Time.now()) {
                    errors.add("Scenario start time must be in the future");
                };
                t;
            };
        };
        if (scenario.endTime < startTime) {
            errors.add("Scenario end time must be after the start time");
        };
        let dayInNanos = 24 * 60 * 60 * 1000000000; // 24 hours in nanoseconds
        if (scenario.endTime - startTime < dayInNanos) {
            errors.add("Scenario duration must be at least 1 day");
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
                for (subEffect in Iter.fromArray(subEffects)) {
                    if (subEffect.weight < 1) {
                        errors.add("Weight must be at least 1");
                    };
                    switch (validateEffect(subEffect.effect)) {
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
            case (#teamTrait(t)) {
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
            let effect = switch (teamData.option) {
                case (null) scenario.abstainEffect;
                case (?option) scenario.options[option].effect;
            };
            resolveEffectInternal(
                prng,
                #team(teamData.id),
                scenario,
                effect,
                effectOutcomes,
            );
        };
        let metaEffectOutcome : Scenario.MetaEffectOutcome = switch (scenario.metaEffect) {
            case (#noEffect) #noEffect;
            case (#leagueChoice(leagueChoice)) {
                let leagueOptionId = getMajorityOption(prng, teamChoices);
                switch (leagueOptionId) {
                    case (null) ();
                    case (?leagueOptionId) {
                        // Resolve the league choice effect if there is a majority
                        let leagueOption = leagueChoice.options[leagueOptionId];
                        resolveEffectInternal(prng, #league, scenario, leagueOption.effect, effectOutcomes);
                    };
                };
                #leagueChoice({
                    optionId = leagueOptionId;
                });
            };
            case (#lottery(lottery)) {
                let weightedTickets : [(Nat, Float)] = teamChoices.vals()
                |> Iter.filter(
                    _,
                    func(teamData : TeamVotingResult) : Bool {
                        switch (teamData.option) {
                            case (null) false;
                            case (?option) lottery.options[option].tickets > 0;
                        };
                    },
                )
                |> Iter.map<TeamVotingResult, (Nat, Float)>(
                    _,
                    func(teamData : TeamVotingResult) : (Nat, Float) {
                        let ticketCount = switch (teamData.option) {
                            case (null) Prelude.unreachable();
                            case (?option) lottery.options[option].tickets;
                        };
                        (teamData.id, Float.fromInt(ticketCount));
                    },
                )
                |> Iter.toArray(_);

                let winningTeamId = if (weightedTickets.size() < 1) {
                    null; // No teams have tickets
                } else {
                    ?prng.nextArrayElementWeighted(weightedTickets);
                };
                switch (winningTeamId) {
                    case (null) ();
                    case (?id) {
                        // Resolve the prize effect if there is a winner
                        resolveEffectInternal(prng, #team(id), scenario, lottery.prize, effectOutcomes);
                    };
                };
                #lottery({
                    winningTeamId = winningTeamId;
                });
            };
            case (#proportionalBid(proportionalBid)) {
                let totalBid = Array.foldLeft(
                    teamChoices,
                    0,
                    func(total : Nat, teamData : TeamVotingResult) : Nat {
                        let bidValue = switch (teamData.option) {
                            case (null) 0;
                            case (?option) proportionalBid.options[option].bidValue;
                        };
                        total + bidValue;
                    },
                );
                let winningBids = Buffer.Buffer<{ teamId : Nat; amount : Nat }>(0);
                label f for (teamData in teamChoices.vals()) {
                    let teamBidValue = switch (teamData.option) {
                        case (null) continue f;
                        case (?option) proportionalBid.options[option].bidValue;
                    };
                    if (teamBidValue < 1) {
                        continue f;
                    };
                    let percentOfPrize = Float.fromInt(teamBidValue) / Float.fromInt(totalBid);
                    let purpotionalValue = Float.toInt(percentOfPrize * Float.fromInt(proportionalBid.prize.amount)); // Round down
                    let purpotionalValueNat = if (purpotionalValue < 0) {
                        0; // Cannot bid negative
                    } else {
                        Int.abs(purpotionalValue);
                    };

                    winningBids.add({
                        teamId = teamData.id;
                        amount = purpotionalValueNat;
                    });
                    if (purpotionalValue > 0) {

                        let effect : Scenario.Effect = switch (proportionalBid.prize.kind) {
                            case (#skill(s)) {
                                let target : Scenario.Target = switch (s.target) {
                                    case (#position(p)) #positions([{
                                        position = p;
                                        team = #choosingTeam;
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
                #proportionalBid({
                    winningBids = Buffer.toArray(winningBids);
                });
            };
            case (#threshold(threshold)) {
                let teamContributions : [Scenario.ThresholdContribution] = teamChoices.vals()
                |> Iter.map<TeamVotingResult, Scenario.ThresholdContribution>(
                    _,
                    func(teamData : TeamVotingResult) : Scenario.ThresholdContribution {

                        let optionValue = switch (teamData.option) {
                            case (null) threshold.abstainAmount;
                            case (?option) threshold.options[option].value;
                        };
                        let value : Int = switch (optionValue) {
                            case (#fixed(fixed)) fixed;
                            case (#weightedChance(w)) {
                                let wFloat : [(Int, Float)] = w.vals()
                                |> Iter.map<{ weight : Nat; value : Int }, (Int, Float)>(
                                    _,
                                    func(w : { weight : Nat; value : Int }) : (Int, Float) = (w.value, Float.fromInt(w.weight)),
                                )
                                |> Iter.toArray(_);
                                prng.nextArrayElementWeighted(wFloat);
                            };
                        };
                        {
                            teamId = teamData.id;
                            amount = value;
                        };
                    },
                )
                |> Iter.toArray(_);
                let valueSum = Array.foldLeft(
                    teamContributions,
                    0,
                    func(total : Int, teamData : Scenario.ThresholdContribution) : Int = total + teamData.amount,
                );
                let successful = valueSum >= threshold.minAmount;
                let thresholdEffect = if (successful) {
                    threshold.success.effect;
                } else {
                    threshold.failure.effect;
                };

                resolveEffectInternal(prng, #league, scenario, thresholdEffect, effectOutcomes);

                #threshold({
                    contributions = teamContributions;
                    successful = successful;
                });
            };
        };
        {
            teamChoices = teamChoices;
            metaEffectOutcome = metaEffectOutcome;
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
                let weightedSubEffects = Array.map<Scenario.WeightedEffect, (Scenario.Effect, Float)>(
                    subEffects,
                    func(wEffect : Scenario.WeightedEffect) : (Scenario.Effect, Float) = (wEffect.effect, Float.fromInt(wEffect.weight)),
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
                        target = getTargetInstance(prng, context, injuryEffect.target);
                    })
                );
            };
            case (#skill(s)) {
                let skill = switch (s.skill) {
                    case (#random) Skill.getRandom(prng);
                    case (#chosen(skill)) skill;
                };
                outcomes.add(
                    #skill({
                        target = getTargetInstance(prng, context, s.target);
                        skill = skill;
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
            case (#teamTrait(t)) {
                outcomes.add(#teamTrait({ teamId = getTeamId(t.team, context); traitId = t.traitId; kind = t.kind }));
            };
            case (#noEffect) ();
        };
    };

    private func getMajorityOption(
        prng : Prng,
        teamChoices : [TeamVotingResult],
    ) : ?Nat {
        if (teamChoices.size() < 1) {
            return null;
        };
        // Get the top choice(s), if there is a tie, choose randomly
        var choiceCounts = Trie.empty<Nat, Nat>();
        var maxCount = 0;
        label f for (teamChoice in Iter.fromArray(teamChoices)) {
            let option = switch (teamChoice.option) {
                case (null) continue f;
                case (?option) option;
            };
            let choiceKey = {
                key = option;
                hash = Nat32.fromNat(option);
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
            ?topChoices.get(0);
        } else {
            ?prng.nextBufferElement(topChoices);
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
        prng : Prng,
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
                    func(target : Scenario.TargetPosition) : Scenario.TargetPositionInstance {
                        let position = switch (target.position) {
                            case (#random) FieldPosition.getRandom(prng);
                            case (#chosen(p)) p;
                        };
                        {
                            teamId = getTeamId(target.team, context);
                            position = position;
                        };
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
