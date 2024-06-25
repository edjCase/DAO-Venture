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
import Order "mo:base/Order";
import TextX "mo:xtended-text/TextX";
import IterTools "mo:itertools/Iter";
import UsersActor "canister:users";
import UserTypes "../users/Types";
import Skill "../models/Skill";
import TeamsActor "canister:teams";
import TeamTypes "../team/Types";
import FieldPosition "../models/FieldPosition";
import Trait "../models/Trait";

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
        kind : Scenario.ScenarioKind;
        state : ScenarioState;
        startTime : Time.Time;
        endTime : Time.Time;
        teamIds : [Nat];
        votes : [Vote];
        teamOptions : [(Nat, [Types.ScenarioTeamOption])];
    };

    type MutableScenarioData = {
        id : Nat;
        title : Text;
        description : Text;
        undecidedEffect : Scenario.Effect;
        kind : Scenario.ScenarioKind;
        state : ScenarioState;
        startTime : Time.Time;
        endTime : Time.Time;
        teamIds : [Nat];
        votes : HashMap.HashMap<Principal, Vote>;
        teamOptions : HashMap.HashMap<Nat, HashMap.HashMap<Nat, Types.ScenarioTeamOption>>; // TeamId => OptionId => Option
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
        teamChoices : [Scenario.ResolvedTeamChoice];
        scenarioOutcome : Scenario.ScenarioOutcome;
        effectOutcomes : [EffectOutcomeData];
    };

    public type EffectOutcomeData = {
        processed : Bool;
        outcome : Scenario.EffectOutcome;
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
            optionId : Nat,
        ) : async* Result.Result<(), { #invalidOption; #notEligible; #scenarioNotFound }> {

            let ?scenario = scenarios.get(scenarioId) else return #err(#scenarioNotFound);
            let ?vote = scenario.votes.get(voterId) else return #err(#notEligible);
            let ?teamOptions = scenario.teamOptions.get(vote.teamId) else return #err(#notEligible);
            let optionExists = IterTools.any(
                teamOptions.vals(),
                func(option : Types.ScenarioTeamOption) : Bool = option.id == optionId,
            );
            if (not optionExists) {
                return #err(#invalidOption);
            };
            Debug.print("Voter " # Principal.toText(voterId) # " voted for option with id '" # Nat.toText(optionId) # "'' in scenario " # Nat.toText(scenarioId));
            scenario.votes.put(
                voterId,
                {
                    vote with
                    optionId = ?optionId;
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

        public func getVote(scenarioId : Nat, voterId : Principal) : Result.Result<Types.ScenarioVote, { #notEligible; #scenarioNotFound }> {
            let ?scenario = scenarios.get(scenarioId) else return #err(#scenarioNotFound);
            let ?vote = scenario.votes.get(voterId) else return #err(#notEligible);
            let ?teamOptions = scenario.teamOptions.get(vote.teamId) else return #err(#notEligible);
            let orderedTeamOptions = teamOptions.vals()
            |> Iter.sort<Types.ScenarioTeamOption>(
                _,
                func(x : Types.ScenarioTeamOption, y : Types.ScenarioTeamOption) : Order.Order = Nat.compare(x.id, y.id),
            )
            |> Iter.toArray(_);
            let teamVotingPower = IterTools.fold<Vote, Nat>(
                scenario.votes.vals(),
                0,
                func(total : Nat, option : Vote) : Nat = total + option.votingPower,
            );
            #ok({
                option = vote.option;
                votingPower = vote.votingPower;
                teamVotingPower = teamVotingPower;
                teamOptions = orderedTeamOptions;
                teamId = vote.teamId;
            });
        };

        public func addCustomTeamOption(scenarioId : Nat, teamId : Nat, value : { #nat : Nat }) : Result.Result<(), { #scenarioNotFound; #invalidValueType; #customOptionNotAllowed; #duplicate }> {
            let ?scenario = scenarios.get(scenarioId) else return #err(#scenarioNotFound);

            let teamOptions = switch (scenario.teamOptions.get(teamId)) {
                case (null) HashMap.HashMap<Nat, Types.ScenarioTeamOption>(0, Nat.equal, Nat32.fromNat);
                case (?options) options;
            };
            let newOptionId = teamOptions.size();
            if (teamOptions.get(newOptionId) != null) {
                Debug.trap("Failed to create new custom team option, duplicate id");
            };
            let newOption = switch (scenario.kind) {
                case (#lottery(_)) {
                    let #nat(natValue) = value else return #err(#invalidValueType);

                    {
                        id = newOptionId;
                        title = "Buy " # Nat.toText(natValue);
                        description = "Buy " # Nat.toText(natValue) # " tickets";
                        energyCost = natValue;
                        votingPower = 0;
                        value = #nat(natValue);
                        traitRequirements = [];
                    };
                };
                case (#proportionalBid(_)) {
                    let #nat(natValue) = value else return #err(#invalidValueType);

                    {
                        id = newOptionId;
                        title = "Bid " # Nat.toText(natValue);
                        description = "Bid " # Nat.toText(natValue) # "💰";
                        energyCost = natValue;
                        votingPower = 0;
                        value = #nat(natValue);
                        traitRequirements = [];
                    };
                };
                case (_) return #err(#customOptionNotAllowed);
            };

            teamOptions.put(
                newOptionId,
                newOption,
            );
            #ok;
        };

        private func calculateResultsInternal(scenario : MutableScenarioData, votingClosed : Bool) : {
            #consensus : [Scenario.ResolvedTeamChoice];
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
            let teamResults = Buffer.Buffer<Scenario.ResolvedTeamChoice>(teamStats.size());
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
                    teamId = teamId;
                    optionId = chosenOption;
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

            let teamIds = HashMap.HashMap<Nat, ()>(0, Nat.equal, Nat32.fromNat);

            let allTeams : [TeamTypes.Team] = await TeamsActor.getTeams();

            let votes = members.vals()
            |> Iter.map<UserTypes.UserVotingInfo, (Principal, Vote)>(
                _,
                func(member : UserTypes.UserVotingInfo) : (Principal, Vote) {
                    teamIds.put(member.teamId, ());
                    (
                        member.id,
                        {
                            id = member.id;
                            teamId = member.teamId;
                            votingPower = member.votingPower;
                            option = null;
                        },
                    );
                },
            )
            |> HashMap.fromIter<Principal, Vote>(_, members.size(), Principal.equal, Principal.hash);

            let teams = allTeams.vals()
            |> Iter.filter(
                _,
                func(team : TeamTypes.Team) : Bool = teamIds.get(team.id) != null,
            )
            |> Iter.toArray(_);

            let teamOptionsFunc = buildTeamOptionsFunc(scenario.kind);

            let teamOptions = teams.vals()
            |> Iter.map<TeamTypes.Team, (Nat, HashMap.HashMap<Nat, Types.ScenarioTeamOption>)>(
                _,
                func(team : TeamTypes.Team) : (Nat, HashMap.HashMap<Nat, Types.ScenarioTeamOption>) {
                    let teamOptions = teamOptionsFunc(team);
                    let teamOptionsMap = teamOptions.vals()
                    |> Iter.map<Types.ScenarioTeamOption, (Nat, Types.ScenarioTeamOption)>(
                        _,
                        func(option : Types.ScenarioTeamOption) : (Nat, Types.ScenarioTeamOption) = (option.id, option),
                    )
                    |> HashMap.fromIter<Nat, Types.ScenarioTeamOption>(_, teamOptions.size(), Nat.equal, Nat32.fromNat);
                    (team.id, teamOptionsMap);
                },
            )
            |> HashMap.fromIter<Nat, HashMap.HashMap<Nat, Types.ScenarioTeamOption>>(_, teams.size(), Nat.equal, Nat32.fromNat);

            let scenarioId = nextScenarioId;
            nextScenarioId += 1;
            let startTimerId = createStartTimer<system>(scenarioId, startTime);

            scenarios.put(
                scenarioId,
                {

                    id = scenarioId;
                    title = scenario.title;
                    description = scenario.description;
                    undecidedEffect = scenario.undecidedEffect;
                    kind = scenario.kind;
                    state = #notStarted({
                        startTimerId = startTimerId;
                    });
                    startTime = startTime;
                    endTime = scenario.endTime;
                    teamIds = Iter.toArray(teamIds.keys());
                    votes = votes;
                    teamOptions = teamOptions;
                },
            );
            #ok;
        };

        private func buildTeamOptionsFunc(scenarioKind : Scenario.ScenarioKind) : (TeamTypes.Team) -> [Types.ScenarioTeamOption] {
            switch (scenarioKind) {
                case (#noLeagueEffect(noLeagueEffect)) func(team : TeamTypes.Team) : [Types.ScenarioTeamOption] {
                    noLeagueEffect.options.vals()
                    |> IterTools.enumerate(_)
                    |> IterTools.mapFilter<(Nat, Scenario.ScenarioOption), Types.ScenarioTeamOption>(
                        _,
                        func((optionId, option) : (Nat, Scenario.ScenarioOption)) : ?Types.ScenarioTeamOption {
                            let meetsRequirements = teamMeetsRequirements(team, option.traitRequirements);
                            if (not meetsRequirements) {
                                return null;
                            };
                            ?{
                                id = optionId;
                                title = option.description;
                                description = option.description;
                                energyCost = option.energyCost;
                                votingPower = 0;
                                value = #none;
                                traitRequirements = option.traitRequirements;
                            };
                        },
                    )
                    |> Iter.toArray(_);
                };
                case (#leagueChoice(leagueChoice)) func(team : TeamTypes.Team) : [Types.ScenarioTeamOption] {
                    leagueChoice.options.vals()
                    |> IterTools.enumerate(_)
                    |> IterTools.mapFilter<(Nat, Scenario.ScenarioOption), Types.ScenarioTeamOption>(
                        _,
                        func((optionId, option) : (Nat, Scenario.ScenarioOption)) : ?Types.ScenarioTeamOption {
                            let meetsRequirements = teamMeetsRequirements(team, option.traitRequirements);
                            if (not meetsRequirements) {
                                return null;
                            };
                            ?{
                                id = optionId;
                                title = option.description;
                                description = option.description;
                                energyCost = option.energyCost;
                                votingPower = 0;
                                value = #none;
                                traitRequirements = option.traitRequirements;
                            };
                        },
                    )
                    |> Iter.toArray(_);
                };
                case (#threshold(threshold)) func(team : TeamTypes.Team) : [Types.ScenarioTeamOption] {
                    threshold.options.vals()
                    |> IterTools.enumerate(_)
                    |> IterTools.mapFilter<(Nat, Scenario.ScenarioOption), Types.ScenarioTeamOption>(
                        _,
                        func((optionId, option) : (Nat, Scenario.ScenarioOption)) : ?Types.ScenarioTeamOption {
                            let meetsRequirements = teamMeetsRequirements(team, option.traitRequirements);
                            if (not meetsRequirements) {
                                return null;
                            };
                            ?{
                                id = optionId;
                                title = option.description;
                                description = option.description;
                                energyCost = option.energyCost;
                                votingPower = 0;
                                value = #none;
                                traitRequirements = option.traitRequirements;
                            };
                        },
                    )
                    |> Iter.toArray(_);
                };
                case (#lottery(lottery)) func(team : TeamTypes.Team) : [Types.ScenarioTeamOption] = [];
                case (#proportionalBid(proportionalBid)) func(team : TeamTypes.Team) : [Types.ScenarioTeamOption] = [];
            };
        };

        private func teamMeetsRequirements(team : TeamTypes.Team, requirements : [Scenario.TraitRequirement]) : Bool {
            IterTools.all<Scenario.TraitRequirement>(
                requirements.vals(),
                func(requirement : Scenario.TraitRequirement) : Bool {
                    let teamHasTrait = IterTools.any<Trait.Trait>(
                        team.traits.vals(),
                        func(trait : Trait.Trait) : Bool = trait.id == requirement.id,
                    );
                    switch (requirement.kind) {
                        case (#required) teamHasTrait;
                        case (#prohibited) not teamHasTrait;
                    };
                },
            );
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

        private func end(scenario : MutableScenarioData, teamVotingResult : [Scenario.ResolvedTeamChoice]) : async* () {
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

        let effectOutcomes = resolved.effectOutcomes.vals()
        |> Iter.map(
            _,
            func(outcome : EffectOutcomeData) : Scenario.EffectOutcome = outcome.outcome,
        )
        |> Iter.toArray(_);
        {
            teamChoices = resolved.teamChoices;
            scenarioOutcome = resolved.scenarioOutcome;
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
        if (errors.size() > 0) {
            #invalid(Buffer.toArray(errors));
        } else {
            #ok;
        };
    };

    private func validateGenericOptions(
        options : [Scenario.ScenarioOption],
        errors : Buffer.Buffer<Text>,
    ) {
        var index = 0;
        for (option in Iter.fromArray(options)) {
            validateGenericOption(option, index, errors);
            index += 1;
        };
    };

    private func validateGenericOption(
        option : Scenario.ScenarioOption,
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
        teamChoices : [Scenario.ResolvedTeamChoice],
    ) : ScenarioStateResolved {
        let effectOutcomes = Buffer.Buffer<Scenario.EffectOutcome>(0);
        for (teamData in Iter.fromArray(teamChoices)) {
            let teamEffect : Scenario.Effect = switch (teamData.optionId) {
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
                #team(teamData.teamId),
                scenario,
                teamEffect,
                effectOutcomes,
            );
        };
        let scenarioOutcome : Scenario.ScenarioOutcome = switch (scenario.kind) {
            case (#noLeagueEffect(noLeagueEffect)) #noLeagueEffect;
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
                    func(teamData : Scenario.ResolvedTeamChoice) : Bool {
                        switch (teamData.optionId) {
                            case (null) false;
                            case (?optionId) {
                                switch (scenario.teamOptions.get(teamData.teamId)) {
                                    case (null) false;
                                    case (?options) {
                                        let ?option = options.get(optionId) else return false; // TODO error?
                                        switch (option.value) {
                                            case (#nat(natValue)) natValue > 0;
                                            case (#none) false;
                                        };
                                    };
                                };
                            };
                        };
                    },
                )
                |> Iter.map<Scenario.ResolvedTeamChoice, (Nat, Float)>(
                    _,
                    func(teamData : Scenario.ResolvedTeamChoice) : (Nat, Float) {
                        let ticketCount = switch (teamData.optionId) {
                            case (null) Prelude.unreachable();
                            case (?optionId) {
                                switch (scenario.teamOptions.get(teamData.teamId)) {
                                    case (null) 0;
                                    case (?options) {
                                        switch (options.get(optionId)) {
                                            case (null) 0; // TODO error?
                                            case (?option) {
                                                switch (option.value) {
                                                    case (#nat(natValue)) natValue;
                                                    case (#none) 0; // TODO error?
                                                };
                                            };
                                        };
                                    };
                                };
                            };
                        };
                        (teamData.teamId, Float.fromInt(ticketCount));
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
                    func(total : Nat, teamData : Scenario.ResolvedTeamChoice) : Nat {
                        let bidValue = switch (teamData.optionId) {
                            case (null) 0;
                            case (?option) {
                                switch (scenario.teamOptions.get(teamData.teamId)) {
                                    case (null) 0;
                                    case (?options) {
                                        switch (options.get(option)) {
                                            case (null) 0;
                                            case (?option) {
                                                switch (option.value) {
                                                    case (#nat(natValue)) natValue;
                                                    case (#none) 0; // TODO error?
                                                };
                                            };
                                        };
                                    };
                                };
                            };
                        };
                        total + bidValue;
                    },
                );
                let winningBids = Buffer.Buffer<{ teamId : Nat; proportion : Nat }>(0);
                label f for (teamData in teamChoices.vals()) {
                    let teamBidValue = switch (teamData.optionId) {
                        case (null) continue f;
                        case (?option) {
                            switch (scenario.teamOptions.get(teamData.teamId)) {
                                case (null) continue f;
                                case (?options) {
                                    switch (options.get(option)) {
                                        case (null) continue f;
                                        case (?option) {
                                            switch (option.value) {
                                                case (#nat(natValue)) natValue;
                                                case (#none) continue f; // TODO error?
                                            };
                                        };
                                    };
                                };
                            };
                        };
                    };
                    if (teamBidValue < 1) {
                        continue f;
                    };
                    let percentOfPrize = Float.fromInt(teamBidValue) / Float.fromInt(totalBid);
                    let proportionalValue = Float.toInt(percentOfPrize * Float.fromInt(proportionalBid.prize.amount)); // Round down
                    let proportionalValueNat = if (proportionalValue < 0) {
                        0; // Cannot bid negative
                    } else {
                        Int.abs(proportionalValue);
                    };

                    winningBids.add({
                        teamId = teamData.teamId;
                        proportion = proportionalValueNat;
                    });
                    if (proportionalValue > 0) {

                        let effect : Scenario.Effect = switch (proportionalBid.prize.kind) {
                            case (#skill(s)) {
                                #skill({
                                    delta = proportionalValue;
                                    duration = s.duration;
                                    target = s.target;
                                    skill = s.skill;
                                });
                            };
                        };
                        resolveEffectInternal(
                            prng,
                            #team(teamData.teamId),
                            scenario,
                            effect,
                            effectOutcomes,
                        );
                    };
                };
                #proportionalBid({
                    bids = Buffer.toArray(winningBids);
                });
            };
            case (#threshold(threshold)) {
                let teamContributions : [Scenario.ThresholdContribution] = teamChoices.vals()
                |> Iter.map<Scenario.ResolvedTeamChoice, Scenario.ThresholdContribution>(
                    _,
                    func(teamData : Scenario.ResolvedTeamChoice) : Scenario.ThresholdContribution {

                        let optionValue = switch (teamData.optionId) {
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
                            teamId = teamData.teamId;
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
            scenarioOutcome = scenarioOutcome;
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
        teamChoices : [Scenario.ResolvedTeamChoice],
    ) : ?Nat {
        if (teamChoices.size() < 1) {
            return null;
        };
        // Get the top choice(s), if there is a tie, choose randomly
        var choiceCounts = Trie.empty<Nat, Nat>();
        var maxCount = 0;
        label f for (teamChoice in Iter.fromArray(teamChoices)) {
            let option = switch (teamChoice.optionId) {
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
        let votes = scenario.votes.vals()
        |> Iter.map<Vote, (Principal, Vote)>(
            _,
            func(vote : Vote) : (Principal, Vote) = (vote.id, vote),
        )
        |> HashMap.fromIter<Principal, Vote>(_, scenario.votes.size(), Principal.equal, Principal.hash);

        let teamOptions = scenario.teamOptions.vals()
        |> Iter.map<(Nat, [Types.ScenarioTeamOption]), (Nat, HashMap.HashMap<Nat, Types.ScenarioTeamOption>)>(
            _,
            func((teamId, teamOptions) : (Nat, [Types.ScenarioTeamOption])) : (Nat, HashMap.HashMap<Nat, Types.ScenarioTeamOption>) {
                let teamOptionsMap = teamOptions.vals()
                |> Iter.map<Types.ScenarioTeamOption, (Nat, Types.ScenarioTeamOption)>(
                    _,
                    func(option : Types.ScenarioTeamOption) : (Nat, Types.ScenarioTeamOption) = (option.id, option),
                )
                |> HashMap.fromIter<Nat, Types.ScenarioTeamOption>(_, teamOptions.size(), Nat.equal, Nat32.fromNat);
                (teamId, teamOptionsMap);
            },
        )
        |> HashMap.fromIter<Nat, HashMap.HashMap<Nat, Types.ScenarioTeamOption>>(_, scenario.teamOptions.size(), Nat.equal, Nat32.fromNat);

        {
            scenario with
            votes = votes;
            teamOptions = teamOptions;
        };
    };

    private func toStableScenarioData(scenario : MutableScenarioData) : StableScenarioData {
        let votes = scenario.votes.vals()
        |> Iter.toArray(_);

        let teamOptions = scenario.teamOptions.entries()
        |> Iter.map<(Nat, HashMap.HashMap<Nat, Types.ScenarioTeamOption>), (Nat, [Types.ScenarioTeamOption])>(
            _,
            func((teamId, teamOptions) : (Nat, HashMap.HashMap<Nat, Types.ScenarioTeamOption>)) : (Nat, [Types.ScenarioTeamOption]) {
                let teamOptionsArray = teamOptions.vals()
                |> Iter.toArray(_);
                (teamId, teamOptionsArray);
            },
        )
        |> Iter.toArray(_);
        {
            scenario with
            votes = votes;
            teamOptions = teamOptions;
        };
    };
};
