import Scenario "../models/Scenario";
import HashMap "mo:base/HashMap";
import Iter "mo:base/Iter";
import Text "mo:base/Text";
import PseudoRandomX "mo:xtended-random/PseudoRandomX";
import Buffer "mo:base/Buffer";
import Debug "mo:base/Debug";
import Array "mo:base/Array";
import Float "mo:base/Float";
import Nat "mo:base/Nat";
import Option "mo:base/Option";
import Nat32 "mo:base/Nat32";
import Timer "mo:base/Timer";
import Time "mo:base/Time";
import Int "mo:base/Int";
import Principal "mo:base/Principal";
import Result "mo:base/Result";
import Order "mo:base/Order";
import Hash "mo:base/Hash";
import TextX "mo:xtended-text/TextX";
import IterTools "mo:itertools/Iter";
import Town "../models/Town";
import TimeUtil "../TimeUtil";
import World "../models/World";

module {
    type Prng = PseudoRandomX.PseudoRandomGenerator;

    type ValidatedTownChoice = {
        townId : Nat;
        choice : ?ValidatedChoice;
    };
    type ValidatedChoice = {
        value : Scenario.ScenarioOptionValue;
        townEffect : Scenario.Effect;
    };

    public type StableData = {
        scenarios : [StableScenarioData];
    };

    public type AddScenarioResult = Result.Result<(), { #invalid : [Text] }>;

    public type AddScenarioError = {
        #invalid : [Text];
    };

    public type StartScenarioResult = {
        #ok;
        #alreadyStarted;
        #notFound;
    };

    public type VoterInfo = {
        townId : Nat;
        id : Principal;
        votingPower : Nat;
    };

    public type Vote = VoterInfo and {
        value : ?Scenario.ScenarioOptionValue;
    };

    public type ScenarioMember = {
        id : Principal;
        townId : Nat;
        votingPower : Nat;
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
        townIds : [Nat];
        votes : [Vote];
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
        townIds : [Nat];
        votes : HashMap.HashMap<Principal, Vote>;
    };

    type ScenarioState = {
        #notStarted : {
            startTimerId : Nat;
        };
        #inProgress : {
            endTimerId : Nat;
        };
        #resolved : Scenario.ScenarioStateResolved;
    };

    type ResolvedTownChoice = {
        townId : Nat;
        value : ?Scenario.ScenarioOptionValue;
    };

    public type VotingData = {
        yourData : ?ScenarioVote;
        townIdsWithConsensus : [Nat];
    };

    public type ScenarioVote = {
        value : ?Scenario.ScenarioOptionValue;
        votingPower : Nat;
        townId : Nat;
        townVotingPower : TownVotingPower;
        townOptions : ScenarioTownOptions;
    };

    public type TownVotingPower = {
        total : Nat;
        voted : Nat;
    };

    public type ScenarioTownOptions = {
        #discrete : [ScenarioTownOptionDiscrete];
        #text : [ScenarioTownOptionText];
    };

    public type ScenarioTownOptionDiscrete = {
        id : Nat;
        title : Text;
        description : Text;
        resourceCosts : [Scenario.ResourceCost];
        currentVotingPower : Nat;
        requirements : [Scenario.Requirement];
    };

    public type ScenarioTownOptionText = ScenarioTownOptionRaw<Text>;

    public type ScenarioTownOptionRaw<T> = {
        value : T;
        currentVotingPower : Nat;
    };

    public type AddScenarioRequest = {
        startTime : ?Time.Time;
        endTime : Time.Time;
        title : Text;
        description : Text;
        undecidedEffect : Scenario.Effect;
        kind : ScenarioKindRequest;
    };

    public type ScenarioKindRequest = {
        #noWorldEffect : NoWorldEffectScenarioRequest;
        #threshold : ThresholdScenarioRequest;
        #worldChoice : WorldChoiceScenarioRequest;
        #textInput : Scenario.TextInputScenario;
    };

    public type ScenarioOptionDiscrete = {
        title : Text;
        description : Text;
        resourceCosts : [Scenario.ResourceCost];
        requirements : [Scenario.Requirement];
        townEffect : Scenario.Effect;
    };

    public type NoWorldEffectScenarioRequest = {
        options : [ScenarioOptionDiscrete];
    };

    public type ThresholdScenarioRequest = {
        minAmount : Nat;
        success : {
            description : Text;
            effect : Scenario.Effect;
        };
        failure : {
            description : Text;
            effect : Scenario.Effect;
        };
        undecidedAmount : ThresholdValue;
        options : [ThresholdScenarioOptionRequest];
    };

    public type ThresholdScenarioOptionRequest = ScenarioOptionDiscrete and {
        value : ThresholdValue;
    };

    public type ThresholdValue = {
        #fixed : Int;
        #weightedChance : [{
            value : Int;
            weight : Nat;
            description : Text;
        }];
    };

    public type WorldChoiceScenarioRequest = {
        options : [WorldChoiceScenarioOptionRequest];
    };

    public type WorldChoiceScenarioOptionRequest = ScenarioOptionDiscrete and {
        worldEffect : Scenario.Effect;
    };

    public class Handler<system>(
        data : StableData,
        processEffectOutcome : <system>(
            outcome : Scenario.EffectOutcome
        ) -> (),
        chargeTownResources : (townId : Nat, resources : [Scenario.ResourceCost]) -> Result.Result<(), { #notEnoughResources : [{ defecit : Nat; kind : World.ResourceKind }] }>,
    ) {

        var scenarios : HashMap.HashMap<Nat, MutableScenarioData> = toHashMap(data.scenarios);
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

        public func vote<system>(
            scenarioId : Nat,
            voterId : Principal,
            value : Scenario.ScenarioOptionValue,
        ) : Result.Result<(), { #notEligible; #invalidValue; #scenarioNotFound; #votingNotOpen }> {

            let ?scenario = scenarios.get(scenarioId) else return #err(#scenarioNotFound);
            let #inProgress(_) = scenario.state else return #err(#votingNotOpen);
            let ?vote = scenario.votes.get(voterId) else return #err(#notEligible);
            // Validate value/option
            switch (scenario.kind) {
                case (#noWorldEffect(noWorldEffect)) {
                    let #id(optionId) = value else return #err(#invalidValue);
                    let option = noWorldEffect.options[optionId];
                    if (not IterTools.any(option.allowedTownIds.vals(), func(townId : Nat) : Bool = townId == vote.townId)) {
                        return #err(#notEligible);
                    };
                };
                case (#worldChoice(worldChoice)) {
                    let #id(optionId) = value else return #err(#invalidValue);
                    let option = worldChoice.options[optionId];
                    if (not IterTools.any(option.allowedTownIds.vals(), func(townId : Nat) : Bool = townId == vote.townId)) {
                        return #err(#notEligible);
                    };
                };
                case (#threshold(threshold)) {
                    let #id(optionId) = value else return #err(#invalidValue);
                    let option = threshold.options[optionId];
                    if (not IterTools.any(option.allowedTownIds.vals(), func(townId : Nat) : Bool = townId == vote.townId)) {
                        return #err(#notEligible);
                    };
                };
                case (#textInput(_)) {
                    let #text(_) = value else return #err(#invalidValue);
                };
            };
            Debug.print("Voter " # Principal.toText(voterId) # " voted for value '" # debug_show (value) # "'' in scenario " # Nat.toText(scenarioId));
            scenario.votes.put(
                voterId,
                {
                    vote with
                    value = ?value;
                },
            );
            let towns = resolveTownChoices(scenario);
            if (IterTools.all(towns.vals(), func(townChoice : ResolvedTownChoice) : Bool = townChoice.value != null)) {
                // End early if all towns have voted
                end<system>(scenario, towns);
            };
            #ok;
        };

        public func getVote(scenarioId : Nat, voterId : Principal) : Result.Result<VotingData, { #notEligible; #scenarioNotFound }> {
            let ?scenario = scenarios.get(scenarioId) else return #err(#scenarioNotFound);
            let ?vote = scenario.votes.get(voterId) else return #err(#notEligible);

            let townOptions = buildTownOptions(scenario, vote.townId);

            let townVotingPower = IterTools.fold<Vote, TownVotingPower>(
                scenario.votes.vals() |> Iter.filter(_, func(v : Vote) : Bool = v.townId == vote.townId),
                {
                    total = 0;
                    voted = 0;
                },
                func(tvp : TownVotingPower, option : Vote) : TownVotingPower = {
                    total = tvp.total + option.votingPower;
                    voted = tvp.voted + (if (option.value != null) option.votingPower else 0);
                },
            );
            let towns = resolveTownChoices(scenario);
            let townIdWithConsensus = towns.vals()
            |> Iter.filter(
                _,
                func(townChoice : ResolvedTownChoice) : Bool = townChoice.value != null,
            )
            |> Iter.map(
                _,
                func(townChoice : ResolvedTownChoice) : Nat = townChoice.townId,
            )
            |> Iter.toArray(_);
            #ok({
                townIdsWithConsensus = townIdWithConsensus;
                yourData = ?{
                    value = vote.value;
                    votingPower = vote.votingPower;
                    townVotingPower = townVotingPower;
                    townOptions = townOptions;
                    townId = vote.townId;
                };
            });
        };

        public func add<system>(
            scenario : AddScenarioRequest,
            members : [ScenarioMember],
            allTowns : [Town.Town],
        ) : AddScenarioResult {
            switch (validateScenario(scenario)) {
                case (#ok) {};
                case (#invalid(errors)) return #err(#invalid(errors));
            };
            let startTime = switch (scenario.startTime) {
                case (null) Time.now();
                case (?t) t;
            };

            let townIds = HashMap.HashMap<Nat, ()>(0, Nat.equal, Nat32.fromNat);

            // TODO refactor the duplicatio
            let kind : Scenario.ScenarioKind = switch (scenario.kind) {
                case (#noWorldEffect(noWorldEffect)) #noWorldEffect({
                    noWorldEffect with
                    options = noWorldEffect.options.vals()
                    |> Iter.map<ScenarioOptionDiscrete, Scenario.ScenarioOptionDiscrete>(
                        _,
                        func(option : ScenarioOptionDiscrete) : Scenario.ScenarioOptionDiscrete {
                            let allowedTownIds = allTowns.vals()
                            |> IterTools.mapFilter(
                                _,
                                func(town : Town.Town) : ?Nat {
                                    if (townMeetsRequirements(town, option.requirements)) {
                                        ?town.id;
                                    } else {
                                        null;
                                    };
                                },
                            )
                            |> Iter.toArray(_);
                            {
                                option with
                                allowedTownIds = allowedTownIds;
                            };
                        },
                    )
                    |> Iter.toArray(_);
                });
                case (#worldChoice(worldChoice)) #worldChoice({
                    worldChoice with
                    options = worldChoice.options.vals()
                    |> Iter.map<WorldChoiceScenarioOptionRequest, Scenario.WorldChoiceScenarioOption>(
                        _,
                        func(option : WorldChoiceScenarioOptionRequest) : Scenario.WorldChoiceScenarioOption {
                            let allowedTownIds = allTowns.vals()
                            |> IterTools.mapFilter(
                                _,
                                func(town : Town.Town) : ?Nat {
                                    if (townMeetsRequirements(town, option.requirements)) {
                                        ?town.id;
                                    } else {
                                        null;
                                    };
                                },
                            )
                            |> Iter.toArray(_);
                            {
                                option with
                                allowedTownIds = allowedTownIds;
                            };
                        },
                    )
                    |> Iter.toArray(_);
                });
                case (#threshold(threshold)) #threshold({
                    threshold with
                    options = threshold.options.vals()
                    |> Iter.map<ThresholdScenarioOptionRequest, Scenario.ThresholdScenarioOption>(
                        _,
                        func(option : ThresholdScenarioOptionRequest) : Scenario.ThresholdScenarioOption {
                            let allowedTownIds = allTowns.vals()
                            |> IterTools.mapFilter(
                                _,
                                func(town : Town.Town) : ?Nat {
                                    if (townMeetsRequirements(town, option.requirements)) {
                                        ?town.id;
                                    } else {
                                        null;
                                    };
                                },
                            )
                            |> Iter.toArray(_);
                            {
                                option with
                                allowedTownIds = allowedTownIds;
                            };
                        },
                    )
                    |> Iter.toArray(_);
                });
                case (#textInput(textInput)) #textInput(textInput);
            };

            let votes = members.vals()
            |> Iter.map<ScenarioMember, (Principal, Vote)>(
                _,
                func(member : ScenarioMember) : (Principal, Vote) {
                    townIds.put(member.townId, ());
                    (
                        member.id,
                        {
                            id = member.id;
                            townId = member.townId;
                            votingPower = member.votingPower;
                            value = null;
                        },
                    );
                },
            )
            |> HashMap.fromIter<Principal, Vote>(_, members.size(), Principal.equal, Principal.hash);

            let scenarioId = nextScenarioId;
            nextScenarioId += 1;
            let state = if (startTime <= Time.now()) {
                #inProgress({
                    endTimerId = createEndTimer<system>(scenarioId, scenario.endTime);
                });
            } else {
                #notStarted({
                    startTimerId = createStartTimer<system>(scenarioId, startTime);
                });
            };

            scenarios.put(
                scenarioId,
                {

                    id = scenarioId;
                    title = scenario.title;
                    description = scenario.description;
                    undecidedEffect = scenario.undecidedEffect;
                    kind = kind;
                    state = state;
                    startTime = startTime;
                    endTime = scenario.endTime;
                    townIds = Iter.toArray(townIds.keys());
                    votes = votes;
                },
            );
            #ok;
        };

        private func buildTownOptions(scenario : MutableScenarioData, townId : Nat) : ScenarioTownOptions {

            // Create map of option id => town voting power for option
            let townOptionVotingPower : HashMap.HashMap<Scenario.ScenarioOptionValue, Nat> = scenario.votes.vals()
            |> Iter.filter(
                _,
                func(vote : Vote) : Bool = vote.townId == townId,
            )
            |> IterTools.fold(
                _,
                HashMap.HashMap<Scenario.ScenarioOptionValue, Nat>(0, scearioOptionValueEqual, scearioOptionValueHash),
                func(acc : HashMap.HashMap<Scenario.ScenarioOptionValue, Nat>, vote : Vote) : HashMap.HashMap<Scenario.ScenarioOptionValue, Nat> {
                    switch (vote.value) {
                        case (?v) {
                            let currentVotingPower = Option.get(acc.get(v), 0);
                            acc.put(v, currentVotingPower + vote.votingPower);
                        };
                        case (null) ();
                    };
                    acc;
                },
            );
            // Function to handle common logic for discrete options
            func mapDiscreteOptions(options : [Scenario.ScenarioOptionDiscrete]) : ScenarioTownOptions {
                let o = options.vals()
                |> IterTools.mapEntries(
                    _,
                    func(optionId : Nat, option : Scenario.ScenarioOptionDiscrete) : ScenarioTownOptionDiscrete {
                        {
                            option with
                            id = optionId;
                            currentVotingPower = Option.get(townOptionVotingPower.get(#id(optionId)), 0);
                        };
                    },
                )
                |> Iter.toArray(_);
                #discrete(o);
            };

            // Function to handle common logic for nat options
            func mapRawOptions<T>(
                options : Iter.Iter<Scenario.ScenarioOptionValue>,
                valueExtractor : Scenario.ScenarioOptionValue -> T,
            ) : [ScenarioTownOptionRaw<T>] {
                options
                |> Iter.map(
                    _,
                    func(value : Scenario.ScenarioOptionValue) : ScenarioTownOptionRaw<T> {
                        {
                            value = valueExtractor(value);
                            currentVotingPower = Option.get(townOptionVotingPower.get(value), 0);
                        };
                    },
                )
                |> Iter.toArray(_);
            };

            switch (scenario.kind) {
                case (#noWorldEffect(noWorldEffect)) mapDiscreteOptions(noWorldEffect.options);
                case (#worldChoice(worldChoice)) mapDiscreteOptions(worldChoice.options);
                case (#threshold(threshold)) mapDiscreteOptions(threshold.options);
                case (#textInput(_)) {
                    let values = mapRawOptions<Text>(
                        townOptionVotingPower.keys(),
                        func(v : Scenario.ScenarioOptionValue) : Text = switch (v) {
                            case (#text(t)) t;
                            case (_) Debug.trap("Expected nat value for text input bid scenario, but got: " # debug_show (v));
                        },
                    );
                    #text(values);
                };
            };
        };

        private func resolveTownChoices(scenario : MutableScenarioData) : [ResolvedTownChoice] {
            type TownInfo = {
                var total : Nat;
                towns : HashMap.HashMap<Nat, Nat>;
            };
            let votingPowerInfo : TownInfo = IterTools.fold(
                scenario.votes.vals(),
                {
                    var total = 0;
                    towns = HashMap.HashMap<Nat, Nat>(0, Nat.equal, Nat32.fromNat);
                },
                func(acc : TownInfo, vote : Vote) : TownInfo {
                    let currentVotingPower = Option.get(acc.towns.get(vote.townId), 0);
                    acc.towns.put(vote.townId, currentVotingPower + vote.votingPower);
                    acc.total += vote.votingPower;
                    acc;
                },
            );
            let allTownOptions = scenario.townIds.vals()
            |> Iter.map<Nat, (Nat, ScenarioTownOptions)>(
                _,
                func(townId : Nat) : (Nat, ScenarioTownOptions) {
                    (townId, buildTownOptions(scenario, townId));
                },
            )
            |> HashMap.fromIter<Nat, ScenarioTownOptions>(_, scenario.townIds.size(), Nat.equal, Nat32.fromNat);

            let townResults = Buffer.Buffer<ResolvedTownChoice>(scenario.townIds.size());
            label f for ((townId, townOptions) in allTownOptions.entries()) {
                let hasVotingPower = Option.get(votingPowerInfo.towns.get(townId), 0) > 0;
                if (not hasVotingPower) {
                    // Only include towns with voters
                    continue f;
                };
                var optionsWithMostVotes = Buffer.Buffer<{ value : Scenario.ScenarioOptionValue; votingPower : Nat }>(0);

                let optionVotingPowers : Iter.Iter<(Scenario.ScenarioOptionValue, Nat)> = switch (townOptions) {
                    case (#discrete(options)) options.vals()
                    |> Iter.map<ScenarioTownOptionDiscrete, (Scenario.ScenarioOptionValue, Nat)>(
                        _,
                        func(option : ScenarioTownOptionDiscrete) : (Scenario.ScenarioOptionValue, Nat) = (#id(option.id), option.currentVotingPower),
                    );
                    case (#text(options)) options.vals()
                    |> Iter.map<ScenarioTownOptionText, (Scenario.ScenarioOptionValue, Nat)>(
                        _,
                        func(option : ScenarioTownOptionText) : (Scenario.ScenarioOptionValue, Nat) = (#text(option.value), option.currentVotingPower),
                    );
                };

                // Calculate the options with the most votes
                label f for ((value, optionVotingPower) in optionVotingPowers) {
                    if (optionVotingPower < 1) {
                        // Skip non votes
                        continue f;
                    };
                    let add = if (optionsWithMostVotes.size() < 1) {
                        // If there are no options with most votes, add this as the first
                        true;
                    } else {
                        let maxVotingPower = optionsWithMostVotes.get(0).votingPower;
                        let eqyalToOrEqualsMax = optionVotingPower >= maxVotingPower;
                        if (optionVotingPower > maxVotingPower) {
                            optionsWithMostVotes.clear(); // Reset options if a new max is found
                        };
                        eqyalToOrEqualsMax;
                    };
                    if (add) {
                        optionsWithMostVotes.add({
                            value = value;
                            votingPower = optionVotingPower;
                        });
                    };
                };
                let optionWithMostVotes = if (optionsWithMostVotes.size() == 1) {
                    ?optionsWithMostVotes.get(0);
                } else {
                    if (optionsWithMostVotes.size() > 1) {
                        Debug.print("Town " # Nat.toText(townId) # " has a tie in option voting, no consensus was reached");
                    };
                    null;
                };

                let chosenValueId : ?Scenario.ScenarioOptionValue = switch (optionWithMostVotes) {
                    case (null) null;
                    case (?o) {
                        // Validate that the majority has been reached
                        let townVotingPower = Option.get(votingPowerInfo.towns.get(townId), 0);
                        let minMajorityVotingPower : Nat = Int.abs(Float.toInt(Float.floor(Float.fromInt(townVotingPower) / 2.) + 1));
                        if (minMajorityVotingPower > o.votingPower) {
                            null; // No majority, so undecided
                        } else {
                            ?o.value;
                        };
                    };
                };
                townResults.add({
                    townId = townId;
                    value = chosenValueId;
                });
            };

            Buffer.toArray(townResults);
        };

        private func townMeetsRequirements(townStats : Town.Town, requirements : [Scenario.Requirement]) : Bool {
            let testRange = func(townValue : Int, range : Scenario.RangeRequirement) : Bool {
                switch (range) {
                    case (#above(value)) townValue > value;
                    case (#below(value)) townValue < value;
                };
            };

            IterTools.all<Scenario.Requirement>(
                requirements.vals(),
                func(requirement : Scenario.Requirement) : Bool {
                    switch (requirement) {
                        case (#size(size)) testRange(townStats.size, size);
                        case (#population(population)) testRange(townStats.population, population);
                        case (#resource(resource)) {
                            switch (resource.kind) {
                                case (#gold) testRange(townStats.resources.gold, resource.range);
                                case (#wood) testRange(townStats.resources.wood, resource.range);
                                case (#food) testRange(townStats.resources.food, resource.range);
                                case (#stone) testRange(townStats.resources.stone, resource.range);
                            };
                        };
                        case (#age(age)) {
                            let currentAge = TimeUtil.getAge(townStats.genesisTime).days;
                            testRange(currentAge, age);
                        };
                    };
                },
            );
        };

        private func start<system>(scenarioId : Nat) : StartScenarioResult {
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

        private func end<system>(
            scenario : MutableScenarioData,
            townVotingResult : [ResolvedTownChoice],
        ) : () {
            // let prng = try {
            //     PseudoRandomX.fromBlob(await Random.blob());
            // } catch (err) {
            //     Debug.trap("Failed to end scenario, unable to get random entropy. Error: " # Error.message(err));
            // };
            // TODO get proper prng, async is complicating things
            let prng = PseudoRandomX.fromSeed(0, #xorshift32);

            switch (scenario.state) {
                case (#notStarted(state)) {
                    Timer.cancelTimer(state.startTimerId);
                };
                case (#inProgress(state)) {
                    Timer.cancelTimer(state.endTimerId);
                };
                case (_) Debug.trap("Scenario not in progress, cannot end");
            };
            Debug.print("Ending scenario " # Nat.toText(scenario.id));
            let resolvedScenarioState = resolveScenario(
                prng,
                scenario,
                townVotingResult,
            );

            for (effectOutcome in resolvedScenarioState.effectOutcomes.vals()) {
                processEffectOutcome<system>(effectOutcome);
            };

            scenarios.put(
                scenario.id,
                {
                    scenario with
                    state = #resolved(resolvedScenarioState);
                },
            );
        };

        private func isAllowedAndChargedFunc(townId : Nat, option : Scenario.ScenarioOptionDiscrete) : Bool {
            let isAllowed = IterTools.any(
                option.allowedTownIds.vals(),
                func(townId : Nat) : Bool = townId == townId,
            );
            if (not isAllowed) {
                return false;
            };
            switch (chargeTownResources(townId, option.resourceCosts)) {
                case (#ok) true;
                case (#err(#notEnoughResources(_))) false;
            };
        };

        private func validateResolvedOption(
            townChoice : ResolvedTownChoice,
            scenarioKind : Scenario.ScenarioKind,
        ) : ?ValidatedChoice {
            let ?value = townChoice.value else return null;
            switch (scenarioKind) {
                case (#noWorldEffect(noWorldEffect)) {
                    let #id(optionId) = value else return null;
                    let option = noWorldEffect.options[optionId];
                    let true = isAllowedAndChargedFunc(townChoice.townId, option) else return null;

                    return ?{
                        value = value;
                        townEffect = option.townEffect;
                    };
                };
                case (#worldChoice(worldChoice)) {
                    let #id(optionId) = value else return null;
                    let option = worldChoice.options[optionId];
                    let true = isAllowedAndChargedFunc(townChoice.townId, option) else return null;

                    return ?{
                        value = value;
                        townEffect = option.townEffect;
                    };
                };
                case (#threshold(threshold)) {
                    let #id(optionId) = value else return null;
                    let option = threshold.options[optionId];
                    let true = isAllowedAndChargedFunc(townChoice.townId, option) else return null;

                    return ?{
                        value = value;
                        townEffect = option.townEffect;
                    };
                };
                case (#textInput(_)) {
                    // No validation needed
                    return ?{
                        value = value;
                        townEffect = #noEffect;
                    };
                };
            };
        };

        private func getValuesFromTownChoices<T>(
            validatedTownChoices : [ValidatedTownChoice],
            compare : (T, T) -> Order.Order,
            getTValue : (Scenario.ScenarioOptionValue) -> T,
        ) : [Scenario.ScenarioResolvedOptionRaw<T>] {
            let valueToTownsMap = HashMap.HashMap<Scenario.ScenarioOptionValue, Buffer.Buffer<Nat>>(0, scearioOptionValueEqual, scearioOptionValueHash);
            label f for (validateTownChoice in validatedTownChoices.vals()) {
                let valueOrNull = switch (validateTownChoice.choice) {
                    case (?townChoice) townChoice.value;
                    case (null) continue f; // Skip undecided
                };
                let townIds = switch (valueToTownsMap.get(valueOrNull)) {
                    case (null) {
                        let emptyTownIds = Buffer.Buffer<Nat>(1);
                        valueToTownsMap.put(valueOrNull, emptyTownIds);
                        emptyTownIds;
                    };
                    case (?townIds) townIds;
                };
                townIds.add(validateTownChoice.townId);
            };
            valueToTownsMap.entries()
            |> Iter.map<(Scenario.ScenarioOptionValue, Buffer.Buffer<Nat>), (T, Buffer.Buffer<Nat>)>(
                _,
                func((value, townIds) : (Scenario.ScenarioOptionValue, Buffer.Buffer<Nat>)) : (T, Buffer.Buffer<Nat>) {
                    let tValue = getTValue(value);
                    (tValue, townIds);
                },
            )
            // Order by value
            |> Iter.sort<(T, Buffer.Buffer<Nat>)>(
                _,
                func((x, _) : (T, Buffer.Buffer<Nat>), (y, _) : (T, Buffer.Buffer<Nat>)) : Order.Order = compare(x, y),
            )
            |> Iter.map(
                _,
                func((value, townIds) : (T, Buffer.Buffer<Nat>)) : Scenario.ScenarioResolvedOptionRaw<T> {
                    {
                        value = value;
                        chosenByTownIds = Buffer.toArray(townIds);
                    };
                },
            )
            |> Iter.toArray(_);
        };

        private func resolveScenario(
            prng : Prng,
            scenario : MutableScenarioData,
            unvalidatedTownChoices : [ResolvedTownChoice],
        ) : Scenario.ScenarioStateResolved {
            // If missing town votes, add them as undecided
            // If voted for an option that is not allowed, add them as undecided
            let validatedTownChoices = scenario.townIds.vals()
            |> Iter.map<Nat, ValidatedTownChoice>(
                _,
                func(townId : Nat) : ValidatedTownChoice {
                    let ?townChoice = IterTools.find<ResolvedTownChoice>(
                        unvalidatedTownChoices.vals(),
                        func(townChoice : ResolvedTownChoice) : Bool = townChoice.townId == townId,
                    ) else return {
                        townId = townId;
                        choice = null;
                    };
                    let choice = validateResolvedOption(townChoice, scenario.kind);
                    {
                        townId = townId;
                        choice = choice;
                    };
                },
            )
            |> Iter.toArray(_);
            let effectOutcomes = Buffer.Buffer<Scenario.EffectOutcome>(0);
            for (townChoice in validatedTownChoices.vals()) {

                let townEffect = switch (townChoice.choice) {
                    case (?townChoice) townChoice.townEffect;
                    case (null) scenario.undecidedEffect;
                };

                resolveEffectInternal(
                    prng,
                    #town(townChoice.townId),
                    scenario,
                    townEffect,
                    effectOutcomes,
                );
            };

            let mapDiscrete = func(options : [Scenario.ScenarioOptionDiscrete]) : Scenario.ScenarioResolvedOptionsKind {
                let mappedOptions = options.vals()
                |> IterTools.mapEntries(
                    _,
                    func(optionId : Nat, option : Scenario.ScenarioOptionDiscrete) : Scenario.ScenarioResolvedOptionDiscrete {
                        let chosenByTownIds = option.allowedTownIds.vals()
                        |> IterTools.mapFilter(
                            _,
                            func(townId : Nat) : ?Nat {
                                let ?townChoice = IterTools.find<ValidatedTownChoice>(
                                    validatedTownChoices.vals(),
                                    func(townChoice : ValidatedTownChoice) : Bool = townChoice.townId == townId,
                                ) else return null;
                                let isChosen = switch (townChoice.choice) {
                                    case (?townChoice) townChoice.value == #id(optionId);
                                    case (null) false;
                                };
                                if (isChosen) ?townId else null;
                            },
                        )
                        |> Iter.toArray(_);
                        {
                            option with
                            id = optionId;
                            seenByTownIds = option.allowedTownIds;
                            chosenByTownIds = chosenByTownIds;
                        };
                    },
                )
                |> Iter.toArray(_);
                #discrete(mappedOptions);
            };

            let options : Scenario.ScenarioResolvedOptionsKind = switch (scenario.kind) {
                case (#noWorldEffect(noWorldEffect)) mapDiscrete(noWorldEffect.options);
                case (#worldChoice(worldChoice)) mapDiscrete(worldChoice.options);
                case (#threshold(threshold)) mapDiscrete(threshold.options);
                case (#textInput(_)) {
                    let textValues = getValuesFromTownChoices<Text>(
                        validatedTownChoices,
                        Text.compare,
                        func(value : Scenario.ScenarioOptionValue) : Text = switch (value) {
                            case (#text(textValue)) textValue;
                            case (_) Debug.trap("Invalid vote value for text input scenario. Expected #text, got " # debug_show (value));
                        },
                    );
                    #text(textValues);
                };
            };
            let scenarioOutcome : Scenario.ScenarioOutcome = buildScenarioOutcome(prng, scenario, validatedTownChoices, effectOutcomes);

            let undecidedTowns = validatedTownChoices.vals()
            |> Iter.filter(
                _,
                func(townChoice : ValidatedTownChoice) : Bool = townChoice.choice == null,
            )
            |> Iter.map(
                _,
                func(townChoice : ValidatedTownChoice) : Nat = townChoice.townId,
            )
            |> Iter.toArray(_);
            {
                scenarioOutcome = scenarioOutcome;
                options = {
                    undecidedOption = {
                        townEffect = scenario.undecidedEffect;
                        chosenByTownIds = undecidedTowns;
                    };
                    kind = options;
                };
                effectOutcomes = Buffer.toArray(effectOutcomes);
            };
        };

        private func createStartTimer<system>(scenarioId : Nat, startTime : Time.Time) : Nat {
            createTimer<system>(
                startTime,
                func<system>() : async* () {
                    Debug.print("Starting scenario with timer. Scenario id: " # Nat.toText(scenarioId));
                    switch (start<system>(scenarioId)) {
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
                func<system>() : async* () {
                    Debug.print("Ending scenario with timer. Scenario id: " # Nat.toText(scenarioId));
                    let ?scenario = scenarios.get(scenarioId) else Debug.trap("Scenario not found: " # Nat.toText(scenarioId));
                    let townVotingResult = resolveTownChoices(scenario);
                    end<system>(scenario, townVotingResult);
                },
            );
        };

        private func createTimer<system>(time : Time.Time, func_ : <system>() -> async* ()) : Nat {
            let durationNanos = time - Time.now();
            let durationNanosNat = if (durationNanos < 0) {
                0;
            } else {
                Int.abs(durationNanos);
            };
            Timer.setTimer<system>(
                #nanoseconds(durationNanosNat),
                func() : async () {
                    await* func_<system>();
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
                                endTimerId = createEndTimer<system>(scenario.id, scenario.endTime);
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
            case (#resolved(resolved)) #resolved(resolved);
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

    type ValidateScenarioResult = {
        #ok;
        #invalid : [Text];
    };

    type ValidateEffectResult = {
        #ok;
        #invalid : [Text];
    };

    type EffectContext = {
        #world;
        #town : Nat;
    };

    public func validateScenario(scenario : AddScenarioRequest) : ValidateScenarioResult {
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
            case (#textInput(_)) ();
            case (#noWorldEffect(noWorldEffect)) {
                if (noWorldEffect.options.size() < 2) {
                    errors.add("Scenario must have at least 2 options");
                };
                validateDiscreteOptions(noWorldEffect.options, errors);
            };
            case (#worldChoice(worldChoice)) {
                if (worldChoice.options.size() < 2) {
                    errors.add("Scenario must have at least 2 options");
                };
                validateDiscreteOptions(worldChoice.options, errors);
            };
            case (#threshold(threshold)) {
                if (threshold.options.size() < 2) {
                    errors.add("Scenario must have at least 2 options");
                };
                validateDiscreteOptions(threshold.options, errors);
            };
        };
        if (errors.size() > 0) {
            #invalid(Buffer.toArray(errors));
        } else {
            #ok;
        };
    };

    private func validateDiscreteOptions(
        options : [ScenarioOptionDiscrete],
        errors : Buffer.Buffer<Text>,
    ) {
        var index = 0;
        for (option in Iter.fromArray(options)) {
            validateDiscreteOption(option, index, errors);
            index += 1;
        };
    };

    private func validateDiscreteOption(
        option : ScenarioOptionDiscrete,
        index : Nat,
        errors : Buffer.Buffer<Text>,
    ) {
        if (TextX.isEmptyOrWhitespace(option.description)) {
            errors.add("Option with index " # Nat.toText(index) # " must have a description");
        };
        switch (validateEffect(option.townEffect)) {
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
            case (#resource(_)) {
                // TODO
            };
            case (#noEffect) {};
        };
        #ok;
    };

    private func buildScenarioOutcome(
        prng : Prng,
        scenario : MutableScenarioData,
        validatedTownChoices : [ValidatedTownChoice],
        effectOutcomes : Buffer.Buffer<Scenario.EffectOutcome>,
    ) : Scenario.ScenarioOutcome {
        switch (scenario.kind) {
            case (#noWorldEffect(_)) #noEffect;
            case (#worldChoice(worldChoice)) {
                let worldOptionValue = getMajorityOption(prng, validatedTownChoices);
                let worldOptionId : ?Nat = switch (worldOptionValue) {
                    case (null) null;
                    case (?worldOptionValue) {
                        let #id(worldOptionId) = worldOptionValue else Debug.trap("Invalid world option value, expected an id: " # debug_show (worldOptionValue));
                        // Resolve the world choice effect if there is a majority
                        let worldOption = worldChoice.options[worldOptionId];
                        resolveEffectInternal(prng, #world, scenario, worldOption.worldEffect, effectOutcomes);
                        ?worldOptionId;
                    };
                };
                #worldChoice({
                    optionId = worldOptionId;
                });
            };
            case (#threshold(threshold)) {
                let townContributions : [Scenario.ThresholdContribution] = validatedTownChoices.vals()
                |> Iter.map<ValidatedTownChoice, Scenario.ThresholdContribution>(
                    _,
                    func(validatedTownChoice : ValidatedTownChoice) : Scenario.ThresholdContribution {
                        let optionValue = switch (validatedTownChoice.choice) {
                            case (null) threshold.undecidedAmount;
                            case (?townChoice) switch (townChoice.value) {
                                case (#id(optionId)) threshold.options[optionId].value;
                                case (_) Debug.trap("Invalid vote value for threshold. Expected #id, got " # debug_show (townChoice.value));
                            };
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
                            townId = validatedTownChoice.townId;
                            amount = value;
                        };
                    },
                )
                |> Iter.toArray(_);
                let valueSum = Array.foldLeft(
                    townContributions,
                    0,
                    func(total : Int, townData : Scenario.ThresholdContribution) : Int = total + townData.amount,
                );
                let successful = valueSum >= threshold.minAmount;
                let thresholdEffect = if (successful) {
                    threshold.success.effect;
                } else {
                    threshold.failure.effect;
                };

                resolveEffectInternal(prng, #world, scenario, thresholdEffect, effectOutcomes);

                #threshold({
                    contributions = townContributions;
                    successful = successful;
                });
            };
            case (#textInput(_)) {
                #noEffect;
            };
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
            case (#resource(resourceEffect)) {
                let delta = switch (resourceEffect.value) {
                    case (#flat(fixed)) fixed;
                };
                let townIds = getTownIdsFromTarget(prng, scenario.townIds, resourceEffect.town, context);
                for (townId in townIds.vals()) {
                    let outcome = #resource({
                        townId = townId;
                        kind = resourceEffect.kind;
                        delta = delta;
                    });
                    outcomes.add(outcome);
                };
            };
            case (#noEffect) ();
        };
    };

    private func scearioOptionValueEqual(a : Scenario.ScenarioOptionValue, b : Scenario.ScenarioOptionValue) : Bool = a == b;
    private func scearioOptionValueHash(a : Scenario.ScenarioOptionValue) : Hash.Hash = switch (a) {
        case (#id(optionId)) Nat32.fromNat(optionId);
        case (#text(text)) Text.hash(text);
    };

    private func getMajorityOption(
        prng : Prng,
        townChoices : [ValidatedTownChoice],
    ) : ?Scenario.ScenarioOptionValue {
        if (townChoices.size() < 1) {
            return null;
        };
        // Get the top choice(s), if there is a tie, choose randomly
        var choiceCounts = HashMap.HashMap<Scenario.ScenarioOptionValue, Nat>(0, scearioOptionValueEqual, scearioOptionValueHash);
        var maxCount = 0;
        label f for (townChoice in Iter.fromArray(townChoices)) {
            let ?choice = townChoice.choice else continue f;
            let option = choice.value;
            let currentCount = Option.get(choiceCounts.get(option), 0);
            let newCount = currentCount + 1;
            let _ = choiceCounts.put(option, newCount);
            if (newCount > maxCount) {
                maxCount := newCount;
            };
        };
        let topChoices = Buffer.Buffer<Scenario.ScenarioOptionValue>(0);
        for ((option, choiceCount) in choiceCounts.entries()) {
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

    private func getTownIdsFromTarget(
        prng : Prng,
        townIds : [Nat],
        target : Scenario.TargetTown,
        context : EffectContext,
    ) : [Nat] {
        switch (target) {
            case (#contextual) switch (context) {
                case (#world) townIds;
                case (#town(town)) [town];
            };
            case (#chosen(townIds)) townIds;
            case (#random(count)) {
                let townIdBuffer = Buffer.fromArray<Nat>(townIds);
                prng.shuffleBuffer(townIdBuffer);
                townIdBuffer.vals()
                |> IterTools.take(_, count)
                |> Iter.toArray(_);
            };
            case (#all) townIds;
        };
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

        {
            scenario with
            votes = votes;
        };
    };

    private func toStableScenarioData(scenario : MutableScenarioData) : StableScenarioData {
        let votes = scenario.votes.vals()
        |> Iter.toArray(_);

        {
            scenario with
            votes = votes;
        };
    };
};
