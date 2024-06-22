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
        scenarios : [StableScenarioData];
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

    public type StableScenarioData = {
        id : Nat;
        title : Text;
        description : Text;
        undecidedEffect : Scenario.Effect;
        kind : StableScenarioKind;
        state : ScenarioState;
        startTime : Time.Time;
        endTime : Time.Time;
        teamIds : [Nat];
        votes : [Vote];
    };

    type StableScenarioKind = {
        #noLeagueEffect : Scenario.NoLeagueEffectScenario;
        #threshold : Scenario.ThresholdScenario;
        #leagueChoice : Scenario.LeagueChoiceScenario;
        #lottery : StableLotteryScenario;
        #proportionalBid : StableProportionalBidScenario;
    };

    type StableLotteryScenario = Scenario.LotteryScenario and {
        teamTicketOptions : [(Nat, [Nat])];
    };

    type StableProportionalBidScenario = Scenario.ProportionalBidScenario and {
        teamBidOptions : [(Nat, [Nat])];
    };

    type MutableScenarioData = {
        id : Nat;
        title : Text;
        description : Text;
        undecidedEffect : Scenario.Effect;
        kind : MutableScenarioKind;
        state : ScenarioState;
        startTime : Time.Time;
        endTime : Time.Time;
        teamIds : [Nat];
        votes : HashMap.HashMap<Principal, Vote>;
    };

    type MutableScenarioKind = {
        #noLeagueEffect : Scenario.NoLeagueEffectScenario;
        #threshold : Scenario.ThresholdScenario;
        #leagueChoice : Scenario.LeagueChoiceScenario;
        #lottery : MutableLotteryScenario;
        #proportionalBid : MutableProportionalBidScenario;
    };

    type MutableLotteryScenario = Scenario.LotteryScenario and {
        teamTicketOptions : HashMap.HashMap<Nat, [Nat]>;
    };

    type MutableProportionalBidScenario = Scenario.ProportionalBidScenario and {
        teamBidOptions : HashMap.HashMap<Nat, [Nat]>;
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
                |> Iter.map<MutableScenarioData, StableScenarioData>(
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
            let ?vote = scenario.votes.get(voterId) else return #err(#notEligible);
            if (vote.option != null) {
                return #err(#alreadyVoted);
            };

            let ?optionCount = getOptionCount(scenario, vote.teamId) else return #err(#invalidOption);
            if (option >= optionCount) {
                return #err(#invalidOption);
            };
            Debug.print("Voter " # Principal.toText(voterId) # " voted for option " # Nat.toText(option) # " in scenario " # Nat.toText(scenarioId));
            scenario.votes.put(
                voterId,
                {
                    vote with
                    option = ?option;
                },
            );
            switch (calculateResultsInternal(scenario, false)) {
                case (#noConsensus) ();
                case (#consensus(teamVotingResult)) {
                    await* end(scenario, teamVotingResult);
                };
            };
            #ok;
        };

        private func getOptionCount(scenario : MutableScenarioData, teamId : Nat) : ?Nat {
            switch (scenario.kind) {
                case (#lottery(lottery)) {
                    let ?ticketOptions = lottery.teamTicketOptions.get(teamId) else return null;
                    ?ticketOptions.size();
                };
                case (#proportionalBid(proportionalBid)) {
                    let ?bidOptions = proportionalBid.teamBidOptions.get(teamId) else return null;
                    ?bidOptions.size();
                };
                case (#leagueChoice(leagueChoice)) ?leagueChoice.options.size();
                case (#threshold(threshold)) ?threshold.options.size();
                case (#noLeagueEffect(noLeague)) ?noLeague.options.size();
            };
        };

        public func getVote(scenarioId : Nat, voterId : Principal) : Result.Result<Types.ScenarioVote, { #notEligible; #scenarioNotFound }> {
            let ?scenario = scenarios.get(scenarioId) else return #err(#scenarioNotFound);
            let ?vote = scenario.votes.get(voterId) else return #err(#notEligible);

            let optionCount = switch (getOptionCount(scenario, vote.teamId)) {
                case (null) 0;
                case (?count) count;
            };
            let optionVotingPowersForTeam : [Nat] = IterTools.range(0, optionCount)
            |> Iter.map(
                _,
                func(i : Nat) : Nat {
                    let optionVotingPowerForTeam : ?Nat = scenario.votes.vals()
                    |> Iter.filter(
                        _,
                        func(otherVote : Vote) : Bool = otherVote.option == ?i and otherVote.teamId == vote.teamId,
                    )
                    |> Iter.map(
                        _,
                        func(otherVote : Vote) : Nat = otherVote.votingPower,
                    )
                    |> IterTools.sum(
                        _,
                        func(x : Nat, y : Nat) : Nat = x + y,
                    );
                    switch (optionVotingPowerForTeam) {
                        case (null) 0;
                        case (?v) v;
                    };
                },
            )
            |> Iter.toArray(_);
            #ok({
                option = vote.option;
                votingPower = vote.votingPower;
                optionVotingPowersForTeam = optionVotingPowersForTeam;
                teamId = vote.teamId;
            });
        };

        public func addCustomTeamOption(scenarioId : Nat, teamId : Nat, value : { #nat : Nat }) : Result.Result<(), { #scenarioNotFound; #invalidValueType; #customOptionNotAllowed; #duplicate }> {
            let ?scenario = scenarios.get(scenarioId) else return #err(#scenarioNotFound);
            switch (scenario.kind) {
                case (#lottery(lottery)) {
                    let #nat(natValue) = value else return #err(#invalidValueType);
                    let ticketOptions = Option.get(lottery.teamTicketOptions.get(teamId), []);
                    if (IterTools.any(ticketOptions.vals(), func(tickets : Nat) : Bool = tickets == natValue)) {
                        return #err(#duplicate);
                    };
                    let newTicketOptions = Buffer.fromArray<Nat>(ticketOptions);
                    newTicketOptions.add(natValue);
                    lottery.teamTicketOptions.put(
                        teamId,
                        Buffer.toArray(newTicketOptions),
                    );
                };
                case (#proportionalBid(proportionalBid)) {
                    let #nat(natValue) = value else return #err(#invalidValueType);
                    let bidOptions = Option.get(proportionalBid.teamBidOptions.get(teamId), []);
                    if (IterTools.any(bidOptions.vals(), func(tickets : Nat) : Bool = tickets == natValue)) {
                        return #err(#duplicate);
                    };
                    let newBidOptions = Buffer.fromArray<Nat>(bidOptions);
                    newBidOptions.add(natValue);
                    proportionalBid.teamBidOptions.put(
                        teamId,
                        Buffer.toArray(newBidOptions),
                    );
                };
                case (_) {
                    return #err(#customOptionNotAllowed);
                };
            };
            #ok;
        };

        private func calculateResultsInternal(scenario : MutableScenarioData, votingClosed : Bool) : {
            #consensus : [TeamVotingResult];
            #noConsensus;
        } {
            type TeamStats = {
                var totalVotingPower : Nat;
                optionVotingPowers : Buffer.Buffer<Nat>;
            };
            let teamStats = HashMap.HashMap<Nat, TeamStats>(0, Nat.equal, Nat32.fromNat);

            for (vote in scenario.votes.vals()) {
                let stats : TeamStats = switch (teamStats.get(vote.teamId)) {
                    case (null) {
                        let initStats : TeamStats = {
                            var totalVotingPower = 0;
                            optionVotingPowers = Buffer.Buffer<Nat>(0);
                        };
                        teamStats.put(vote.teamId, initStats);
                        initStats;
                    };
                    case (?voterTeamStats) voterTeamStats;
                };
                stats.totalVotingPower += vote.votingPower;
                switch (vote.option) {
                    case (?option) {
                        let currentVotingPower = Option.get(stats.optionVotingPowers.getOpt(option), 0);
                        stats.optionVotingPowers.put(option, currentVotingPower + vote.votingPower);
                    };
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
                var optionsWithMostVotes = Buffer.Buffer<{ option : Nat; votingPower : Nat }>(0);

                // Calculate the options with the most votes
                label f for ((option, optionVotingPower) in IterTools.enumerate(stats.optionVotingPowers.vals())) {
                    if (optionVotingPower < 1) {
                        // Skip non votes
                        continue f;
                    };
                    let add = if (optionsWithMostVotes.size() < 1) {
                        // If there are no options with most votes, add this as the first
                        true;
                    } else {
                        let maxVotingPower = optionsWithMostVotes.get(0).votingPower;
                        let isNewOrSameMax = optionVotingPower >= maxVotingPower;
                        if (optionVotingPower > maxVotingPower) {
                            optionsWithMostVotes.clear(); // Reset options if a new max is found
                        };
                        isNewOrSameMax;
                    };
                    if (add) {
                        optionsWithMostVotes.add({
                            option = option;
                            votingPower = optionVotingPower;
                        });
                    };
                };
                let optionWithMostVotes = if (optionsWithMostVotes.size() == 1) {
                    ?optionsWithMostVotes.get(0);
                } else {
                    if (optionsWithMostVotes.size() > 1) {
                        Debug.print("Team " # Nat.toText(teamId) # " has a tie in option voting, no consensus was reached");
                    };
                    null;
                };

                // If voting is not closed, check to see if there is a majority to end early or not
                if (not votingClosed) {
                    switch (optionWithMostVotes) {
                        case (null) return #noConsensus;
                        case (?o) {
                            // Validate that the majority has been reached, if voting is still active
                            let minMajorityVotingPower : Nat = Int.abs(Float.toInt(Float.floor(Float.fromInt(stats.totalVotingPower) / 2.) + 1));
                            if (minMajorityVotingPower > o.votingPower) {
                                return #noConsensus;
                            };
                        };
                    };
                };
                let chosenOption : ?Nat = switch (optionWithMostVotes) {
                    case (null) null;
                    case (?o) ?o.option;
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

            let kind : MutableScenarioKind = switch (scenario.kind) {
                case (#noLeagueEffect(noLeague)) #noLeagueEffect(noLeague);
                case (#threshold(threshold)) #threshold(threshold);
                case (#leagueChoice(leagueChoice)) #leagueChoice(leagueChoice);
                case (#lottery(lottery)) {
                    #lottery({
                        lottery with
                        teamTicketOptions = HashMap.HashMap<Nat, [Nat]>(0, Nat.equal, Nat32.fromNat);
                    });
                };
                case (#proportionalBid(proportionalBid)) {
                    #proportionalBid({
                        prize = proportionalBid.prize;
                        teamBidOptions = HashMap.HashMap<Nat, [Nat]>(0, Nat.equal, Nat32.fromNat);
                    });
                };
            };
            scenarios.put(
                scenarioId,
                {

                    id = scenarioId;
                    title = scenario.title;
                    description = scenario.description;
                    undecidedEffect = scenario.undecidedEffect;
                    kind = kind;
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

        private func end(scenario : MutableScenarioData, teamVotingResult : [TeamVotingResult]) : async* () {
            Debug.print("Ending scenario " # Nat.toText(scenario.id));
            let prng = PseudoRandomX.fromBlob(await Random.blob());
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
                    let teamVotingResult = switch (calculateResultsInternal(scenario, true)) {
                        case (#consensus(teamVotingResult)) teamVotingResult;
                        case (#noConsensus) Prelude.unreachable();
                    };
                    await* end(scenario, teamVotingResult);
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
            undecidedEffect = data.undecidedEffect;
            kind = data.kind;
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
        switch (scenario.kind) {
            case (#lottery(lottery)) {

            };
            case (#proportionalBid(proportionalBid)) {};
            case (#noLeagueEffect(noLeagueEffect)) {
                if (noLeagueEffect.options.size() < 2) {
                    errors.add("Scenario must have at least 2 options");
                };
                validateGenericOptions(noLeagueEffect.options, errors);
            };
            case (#leagueChoice(leagueChoice)) {
                if (leagueChoice.options.size() < 2) {
                    errors.add("Scenario must have at least 2 options");
                };
                validateGenericOptions(leagueChoice.options, errors);
            };
            case (#threshold(threshold)) {
                if (threshold.options.size() < 2) {
                    errors.add("Scenario must have at least 2 options");
                };
                validateGenericOptions(threshold.options, errors);
            };
        };
        if (scenario.teamIds.size() < 1) {
            errors.add("Scenario must have at least 1 team");
        };
        if (errors.size() > 0) {
            #invalid(Buffer.toArray(errors));
        } else {
            #ok;
        };
    };

    private func validateGenericOptions(
        options : [Scenario.ScenarioOptionWithEffect],
        errors : Buffer.Buffer<Text>,
    ) {
        var index = 0;
        for (option in Iter.fromArray(options)) {
            validateGenericOption(option, index, errors);
            index += 1;
        };
    };

    private func validateGenericOption(
        option : Scenario.ScenarioOptionWithEffect,
        index : Nat,
        errors : Buffer.Buffer<Text>,
    ) {
        if (TextX.isEmptyOrWhitespace(option.description)) {
            errors.add("Option with index " # Nat.toText(index) # " must have a description");
        };
        switch (validateEffect(option.teamEffect)) {
            case (#ok) {};
            case (#invalid(effectErrors)) {
                for (effectError in Iter.fromArray(effectErrors)) {
                    errors.add("Option with index " # Nat.toText(index) # " has an invalid effect: " # effectError);
                };
            };
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
        scenario : MutableScenarioData,
        teamChoices : [TeamVotingResult],
    ) : ScenarioStateResolved {
        let effectOutcomes = Buffer.Buffer<Scenario.EffectOutcome>(0);
        for (teamData in Iter.fromArray(teamChoices)) {
            let teamEffect : Scenario.Effect = switch (teamData.option) {
                case (null) scenario.undecidedEffect;
                case (?option) switch (scenario.kind) {
                    case (#noLeagueEffect(noLeagueEffect)) noLeagueEffect.options[option].teamEffect;
                    case (#leagueChoice(leagueChoice)) leagueChoice.options[option].teamEffect;
                    case (#threshold(threshold)) threshold.options[option].teamEffect;
                    case (#lottery(lottery)) #noEffect;
                    case (#proportionalBid(proportionalBid)) #noEffect;
                };
            };
            resolveEffectInternal(
                prng,
                #team(teamData.id),
                scenario,
                teamEffect,
                effectOutcomes,
            );
        };
        let metaEffectOutcome : Scenario.MetaEffectOutcome = switch (scenario.kind) {
            case (#noLeagueEffect(noLeagueEffect)) #noEffect;
            case (#leagueChoice(leagueChoice)) {
                let leagueOptionId = getMajorityOption(prng, teamChoices);
                switch (leagueOptionId) {
                    case (null) ();
                    case (?leagueOptionId) {
                        // Resolve the league choice effect if there is a majority
                        let leagueOption = leagueChoice.options[leagueOptionId];
                        resolveEffectInternal(prng, #league, scenario, leagueOption.leagueEffect, effectOutcomes);
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
                            case (?option) {
                                switch (lottery.teamTicketOptions.get(teamData.id)) {
                                    case (null) false;
                                    case (?ticketOptions) ticketOptions[option] > 0;
                                };
                            };
                        };
                    },
                )
                |> Iter.map<TeamVotingResult, (Nat, Float)>(
                    _,
                    func(teamData : TeamVotingResult) : (Nat, Float) {
                        let ticketCount = switch (teamData.option) {
                            case (null) Prelude.unreachable();
                            case (?option) {
                                switch (lottery.teamTicketOptions.get(teamData.id)) {
                                    case (null) 0;
                                    case (?ticketOptions) ticketOptions[option];
                                };
                            };
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
                            case (?option) {
                                switch (proportionalBid.teamBidOptions.get(teamData.id)) {
                                    case (null) 0;
                                    case (?bidOptions) bidOptions[option];
                                };
                            };
                        };
                        total + bidValue;
                    },
                );
                let winningBids = Buffer.Buffer<{ teamId : Nat; amount : Nat }>(0);
                label f for (teamData in teamChoices.vals()) {
                    let teamBidValue = switch (teamData.option) {
                        case (null) continue f;
                        case (?option) {
                            switch (proportionalBid.teamBidOptions.get(teamData.id)) {
                                case (null) 0;
                                case (?bidOptions) bidOptions[option];
                            };
                        };
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
                                #skill({
                                    delta = purpotionalValue;
                                    duration = s.duration;
                                    target = s.target;
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
                            case (null) threshold.undecidedAmount;
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
        scenario : MutableScenarioData,
        effect : Scenario.Effect,
    ) : [Scenario.EffectOutcome] {
        let buffer = Buffer.Buffer<Scenario.EffectOutcome>(0);
        resolveEffectInternal(prng, context, scenario, effect, buffer);
        Buffer.toArray(buffer);
    };

    private func resolveEffectInternal(
        prng : Prng,
        context : EffectContext,
        scenario : MutableScenarioData,
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
                let teamIds = getTeamIdsFromTarget(prng, scenario.teamIds, entropyEffect.target, context);
                for (teamId in teamIds.vals()) {
                    let outcome = #entropy({
                        teamId = teamId;
                        delta = entropyEffect.delta;
                    });
                    outcomes.add(outcome);
                };
            };
            case (#injury(injuryEffect)) {
                let positions = getPositionsFromTarget(prng, scenario.teamIds, injuryEffect.target, context);
                for (position in positions.vals()) {
                    let outcome = #injury({
                        target = position;
                    });
                    outcomes.add(outcome);
                };
            };
            case (#skill(s)) {
                let positions = getPositionsFromTarget(prng, scenario.teamIds, s.target, context);
                for (position in positions.vals()) {
                    let skill = switch (s.skill) {
                        case (#random) Skill.getRandom(prng);
                        case (#chosen(skill)) skill;
                    };
                    outcomes.add(
                        #skill({
                            target = position;
                            skill = skill;
                            duration = s.duration;
                            delta = s.delta;
                        })
                    );
                };
            };
            case (#energy(e)) {
                let delta = switch (e.value) {
                    case (#flat(fixed)) fixed;
                };
                let teamIds = getTeamIdsFromTarget(prng, scenario.teamIds, e.target, context);
                for (teamId in teamIds.vals()) {
                    let outcome = #energy({
                        teamId = teamId;
                        delta = delta;
                    });
                    outcomes.add(outcome);
                };
            };
            case (#teamTrait(t)) {
                let teamIds = getTeamIdsFromTarget(prng, scenario.teamIds, t.target, context);
                for (teamId in teamIds.vals()) {
                    let outcome = #teamTrait({
                        teamId = teamId;
                        traitId = t.traitId;
                        kind = t.kind;
                    });
                    outcomes.add(outcome);
                };
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

    private func getTeamIdsFromTarget(
        prng : Prng,
        teamIds : [Nat],
        target : Scenario.TargetTeam,
        context : EffectContext,
    ) : [Nat] {
        switch (target) {
            case (#contextual) switch (context) {
                case (#league) teamIds;
                case (#team(team)) [team];
            };
            case (#chosen(teamIds)) teamIds;
            case (#random(count)) {
                let teamIdBuffer = Buffer.fromArray<Nat>(teamIds);
                prng.shuffleBuffer(teamIdBuffer);
                teamIdBuffer.vals()
                |> IterTools.take(_, count)
                |> Iter.toArray(_);
            };
            case (#all) teamIds;
        };
    };

    private func getPositionsFromTarget(
        prng : Prng,
        teamIds : [Nat],
        target : Scenario.TargetPosition,
        context : EffectContext,
    ) : [Scenario.TargetPositionInstance] {
        getTeamIdsFromTarget(prng, teamIds, target.team, context).vals()
        |> Iter.map<Nat, Scenario.TargetPositionInstance>(
            _,
            func(teamId : Nat) : Scenario.TargetPositionInstance {
                let position = switch (target.position) {
                    case (#random) FieldPosition.getRandom(prng);
                    case (#chosen(p)) p;
                };
                {
                    teamId = teamId;
                    position = position;
                };
            },
        )
        |> Iter.toArray(_);
    };

    private func toHashMap(scenarios : [StableScenarioData]) : HashMap.HashMap<Nat, MutableScenarioData> {
        scenarios
        |> Iter.fromArray(_)
        |> Iter.map<StableScenarioData, (Nat, MutableScenarioData)>(
            _,
            func(scenario : StableScenarioData) : (Nat, MutableScenarioData) = (scenario.id, fromStableScenarioData(scenario)),
        )
        |> HashMap.fromIter<Nat, MutableScenarioData>(_, scenarios.size(), Nat.equal, Nat32.fromNat);

    };

    private func fromStableScenarioData(scenario : StableScenarioData) : MutableScenarioData {
        let kind = switch (scenario.kind) {
            case (#noLeagueEffect(noLeague)) #noLeagueEffect(noLeague);
            case (#threshold(threshold)) #threshold(threshold);
            case (#leagueChoice(leagueChoice)) #leagueChoice(leagueChoice);
            case (#lottery(lottery)) {
                #lottery({
                    lottery with
                    teamTicketOptions = HashMap.HashMap<Nat, [Nat]>(0, Nat.equal, Nat32.fromNat);
                });
            };
            case (#proportionalBid(proportionalBid)) {
                #proportionalBid({
                    prize = proportionalBid.prize;
                    teamBidOptions = HashMap.HashMap<Nat, [Nat]>(0, Nat.equal, Nat32.fromNat);
                });
            };
        };
        let votes = scenario.votes.vals()
        |> Iter.map<Vote, (Principal, Vote)>(
            _,
            func(vote : Vote) : (Principal, Vote) = (vote.id, vote),
        )
        |> HashMap.fromIter<Principal, Vote>(_, scenario.votes.size(), Principal.equal, Principal.hash);
        {
            scenario with
            kind = kind;
            votes = votes;
        };
    };

    private func toStableScenarioData(scenario : MutableScenarioData) : StableScenarioData {
        let kind : StableScenarioKind = switch (scenario.kind) {
            case (#noLeagueEffect(noLeague)) #noLeagueEffect(noLeague);
            case (#threshold(threshold)) #threshold(threshold);
            case (#leagueChoice(leagueChoice)) #leagueChoice(leagueChoice);
            case (#lottery(lottery)) {
                #lottery({
                    lottery with
                    teamTicketOptions = Iter.toArray(lottery.teamTicketOptions.entries());
                });
            };
            case (#proportionalBid(proportionalBid)) {
                #proportionalBid({
                    proportionalBid with
                    teamBidOptions = Iter.toArray(proportionalBid.teamBidOptions.entries());
                });
            };
        };
        let votes = scenario.votes.vals()
        |> Iter.toArray(_);
        {
            scenario with
            kind = kind;
            votes = votes;
        };
    };
};
