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
import Trie "mo:base/Trie";
import Option "mo:base/Option";
import Nat32 "mo:base/Nat32";
import Timer "mo:base/Timer";
import Time "mo:base/Time";
import Int "mo:base/Int";
import Prelude "mo:base/Prelude";
import Principal "mo:base/Principal";
import Result "mo:base/Result";
import Order "mo:base/Order";
import TextX "mo:xtended-text/TextX";
import IterTools "mo:itertools/Iter";
import Skill "../models/Skill";
import FieldPosition "../models/FieldPosition";
import Trait "../models/Trait";
import Team "../models/Team";

module {
    type Prng = PseudoRandomX.PseudoRandomGenerator;

    type ValidatedTeamChoice = {
        teamId : Nat;
        choice : ?ValidatedChoice;
    };
    type ValidatedChoice = {
        value : Scenario.ScenarioOptionValue;
        teamEffect : Scenario.Effect;
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
        teamId : Nat;
        id : Principal;
        votingPower : Nat;
    };

    public type Vote = VoterInfo and {
        value : ?Scenario.ScenarioOptionValue;
    };

    public type ScenarioMember = {
        id : Principal;
        teamId : Nat;
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
        teamIds : [Nat];
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
        teamIds : [Nat];
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

    type ResolvedTeamChoice = {
        teamId : Nat;
        value : ?Scenario.ScenarioOptionValue;
    };

    public type VotingData = {
        yourData : ?ScenarioVote;
        teamIdsWithConsensus : [Nat];
    };

    public type ScenarioVote = {
        value : ?Scenario.ScenarioOptionValue;
        votingPower : Nat;
        teamId : Nat;
        teamVotingPower : Nat;
        teamOptions : ScenarioTeamOptions;
    };

    public type ScenarioTeamOptions = {
        #discrete : [ScenarioTeamOptionDiscrete];
        #nat : [ScenarioTeamOptionNat];
    };

    public type ScenarioTeamOptionDiscrete = {
        id : Nat;
        title : Text;
        description : Text;
        energyCost : Nat;
        currentVotingPower : Nat;
        traitRequirements : [Scenario.TraitRequirement];
    };

    public type ScenarioTeamOptionNat = {
        value : Nat;
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
        #noLeagueEffect : NoLeagueEffectScenarioRequest;
        #threshold : ThresholdScenarioRequest;
        #leagueChoice : LeagueChoiceScenarioRequest;
        #lottery : Scenario.LotteryScenario;
        #proportionalBid : Scenario.ProportionalBidScenario;
    };

    public type ScenarioOptionDiscrete = {
        title : Text;
        description : Text;
        energyCost : Nat;
        traitRequirements : [Scenario.TraitRequirement];
        teamEffect : Scenario.Effect;
    };

    public type NoLeagueEffectScenarioRequest = {
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

    public type LeagueChoiceScenarioRequest = {
        options : [LeagueChoiceScenarioOptionRequest];
    };

    public type LeagueChoiceScenarioOptionRequest = ScenarioOptionDiscrete and {
        leagueEffect : Scenario.Effect;
    };

    public class Handler<system>(
        data : StableData,
        processEffectOutcome : <system>(
            closeAllScenarios : <system>() -> (),
            outcome : Scenario.EffectOutcome,
        ) -> (),
        chargeTeamEnergy : (teamId : Nat, amount : Nat) -> {
            #ok;
            #notEnoughEnergy;
        },
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

        public func closeAllScenarios<system>() : () {
            Debug.print("Closing all scenarios");
            let allScenarios = scenarios.vals();
            for (scenario in allScenarios) {
                switch (scenario.state) {
                    case (#notStarted({ startTimerId })) {
                        Timer.cancelTimer(startTimerId);
                        end<system>(scenario, []);
                    };
                    case (#inProgress({ endTimerId })) {
                        end<system>(scenario, []);
                    };
                    case (#resolved(_)) ();
                };
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
                case (#noLeagueEffect(noLeagueEffect)) {
                    let #id(optionId) = value else return #err(#invalidValue);
                    let option = noLeagueEffect.options[optionId];
                    if (not IterTools.any(option.allowedTeamIds.vals(), func(teamId : Nat) : Bool = teamId == vote.teamId)) {
                        return #err(#notEligible);
                    };
                };
                case (#leagueChoice(leagueChoice)) {
                    let #id(optionId) = value else return #err(#invalidValue);
                    let option = leagueChoice.options[optionId];
                    if (not IterTools.any(option.allowedTeamIds.vals(), func(teamId : Nat) : Bool = teamId == vote.teamId)) {
                        return #err(#notEligible);
                    };
                };
                case (#threshold(threshold)) {
                    let #id(optionId) = value else return #err(#invalidValue);
                    let option = threshold.options[optionId];
                    if (not IterTools.any(option.allowedTeamIds.vals(), func(teamId : Nat) : Bool = teamId == vote.teamId)) {
                        return #err(#notEligible);
                    };
                };
                case (#lottery(lottery)) {
                    let #nat(natValue) = value else return #err(#invalidValue);
                    if (natValue < lottery.minBid) {
                        return #err(#invalidValue);
                    };
                };
                case (#proportionalBid(proportionalBid)) {
                    let #nat(_) = value else return #err(#invalidValue);
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
            switch (calculateTeamConsensus(scenario, false)) {
                case (#noConsensus) ();
                case (#consensus(teamVotingResult)) {
                    end<system>(scenario, teamVotingResult);
                };
            };
            #ok;
        };

        public func getVote(scenarioId : Nat, voterId : Principal) : Result.Result<VotingData, { #notEligible; #scenarioNotFound }> {
            let ?scenario = scenarios.get(scenarioId) else return #err(#scenarioNotFound);
            let ?vote = scenario.votes.get(voterId) else return #err(#notEligible);

            let teamOptions = buildTeamOptions(scenario, vote.teamId);

            let teamVotingPower = IterTools.fold<Vote, Nat>(
                scenario.votes.vals() |> Iter.filter(_, func(v : Vote) : Bool = v.teamId == vote.teamId),
                0,
                func(total : Nat, option : Vote) : Nat = total + option.votingPower,
            );
            let #consensus(teams) = calculateTeamConsensus(scenario, true) else Prelude.unreachable();
            let teamIdWithConsensus = teams.vals()
            |> Iter.filter(
                _,
                func(teamChoice : ResolvedTeamChoice) : Bool = teamChoice.value != null,
            )
            |> Iter.map(
                _,
                func(teamChoice : ResolvedTeamChoice) : Nat = teamChoice.teamId,
            )
            |> Iter.toArray(_);
            #ok({
                teamIdsWithConsensus = teamIdWithConsensus;
                yourData = ?{
                    value = vote.value;
                    votingPower = vote.votingPower;
                    teamVotingPower = teamVotingPower;
                    teamOptions = teamOptions;
                    teamId = vote.teamId;
                };
            });
        };

        public func add<system>(
            scenario : AddScenarioRequest,
            members : [ScenarioMember],
            allTeams : [Team.Team],
        ) : AddScenarioResult {
            switch (validateScenario(scenario)) {
                case (#ok) {};
                case (#invalid(errors)) return #err(#invalid(errors));
            };
            let startTime = switch (scenario.startTime) {
                case (null) Time.now();
                case (?t) t;
            };

            let teamIds = HashMap.HashMap<Nat, ()>(0, Nat.equal, Nat32.fromNat);

            // TODO refactor the duplicatio
            let kind : Scenario.ScenarioKind = switch (scenario.kind) {
                case (#noLeagueEffect(noLeagueEffect)) #noLeagueEffect({
                    noLeagueEffect with
                    options = noLeagueEffect.options.vals()
                    |> Iter.map<ScenarioOptionDiscrete, Scenario.ScenarioOptionDiscrete>(
                        _,
                        func(option : ScenarioOptionDiscrete) : Scenario.ScenarioOptionDiscrete {
                            let allowedTeamIds = allTeams.vals()
                            |> IterTools.mapFilter(
                                _,
                                func(team : Team.Team) : ?Nat {
                                    if (teamMeetsRequirements(team, option.traitRequirements)) {
                                        ?team.id;
                                    } else {
                                        null;
                                    };
                                },
                            )
                            |> Iter.toArray(_);
                            {
                                option with
                                allowedTeamIds = allowedTeamIds;
                            };
                        },
                    )
                    |> Iter.toArray(_);
                });
                case (#leagueChoice(leagueChoice)) #leagueChoice({
                    leagueChoice with
                    options = leagueChoice.options.vals()
                    |> Iter.map<LeagueChoiceScenarioOptionRequest, Scenario.LeagueChoiceScenarioOption>(
                        _,
                        func(option : LeagueChoiceScenarioOptionRequest) : Scenario.LeagueChoiceScenarioOption {
                            let allowedTeamIds = allTeams.vals()
                            |> IterTools.mapFilter(
                                _,
                                func(team : Team.Team) : ?Nat {
                                    if (teamMeetsRequirements(team, option.traitRequirements)) {
                                        ?team.id;
                                    } else {
                                        null;
                                    };
                                },
                            )
                            |> Iter.toArray(_);
                            {
                                option with
                                allowedTeamIds = allowedTeamIds;
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
                            let allowedTeamIds = allTeams.vals()
                            |> IterTools.mapFilter(
                                _,
                                func(team : Team.Team) : ?Nat {
                                    if (teamMeetsRequirements(team, option.traitRequirements)) {
                                        ?team.id;
                                    } else {
                                        null;
                                    };
                                },
                            )
                            |> Iter.toArray(_);
                            {
                                option with
                                allowedTeamIds = allowedTeamIds;
                            };
                        },
                    )
                    |> Iter.toArray(_);
                });
                case (#lottery(lottery)) #lottery(lottery);
                case (#proportionalBid(proportionalBid)) #proportionalBid(proportionalBid);
            };

            let votes = members.vals()
            |> Iter.map<ScenarioMember, (Principal, Vote)>(
                _,
                func(member : ScenarioMember) : (Principal, Vote) {
                    teamIds.put(member.teamId, ());
                    (
                        member.id,
                        {
                            id = member.id;
                            teamId = member.teamId;
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
                    teamIds = Iter.toArray(teamIds.keys());
                    votes = votes;
                },
            );
            #ok;
        };

        private func buildTeamOptions(scenario : MutableScenarioData, teamId : Nat) : ScenarioTeamOptions {
            // TODO this is a cheat since both are nats, sorry future me
            let valueExtractor : (?Scenario.ScenarioOptionValue) -> ?Nat = switch (scenario.kind) {
                case (#noLeagueEffect(_) or #leagueChoice(_) or #threshold(_)) func(v : ?Scenario.ScenarioOptionValue) : ?Nat {
                    let ? #id(optionId) = v else return null;
                    ?optionId;
                };
                case (#lottery(_) or #proportionalBid(_)) func(v : ?Scenario.ScenarioOptionValue) : ?Nat {
                    let ? #nat(natValue) = v else return null;
                    ?natValue;
                };
            };

            // Create map of option id => team voting power for option
            let teamOptionVotingPower : HashMap.HashMap<Nat, Nat> = scenario.votes.vals()
            |> Iter.filter(
                _,
                func(vote : Vote) : Bool = vote.teamId == teamId,
            )
            |> IterTools.fold(
                _,
                HashMap.HashMap<Nat, Nat>(0, Nat.equal, Nat32.fromNat),
                func(acc : HashMap.HashMap<Nat, Nat>, vote : Vote) : HashMap.HashMap<Nat, Nat> {
                    switch (valueExtractor(vote.value)) {
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
            func mapDiscreteOptions(options : [Scenario.ScenarioOptionDiscrete]) : ScenarioTeamOptions {
                let o = options.vals()
                |> IterTools.mapEntries(
                    _,
                    func(optionId : Nat, option : Scenario.ScenarioOptionDiscrete) : ScenarioTeamOptionDiscrete {
                        {
                            option with
                            id = optionId;
                            currentVotingPower = Option.get(teamOptionVotingPower.get(optionId), 0);
                        };
                    },
                )
                |> Iter.toArray(_);
                #discrete(o);
            };

            // Function to handle common logic for nat options
            func mapNatOptions(options : Iter.Iter<Nat>) : ScenarioTeamOptions {
                let o = options
                |> Iter.map(
                    _,
                    func(value : Nat) : ScenarioTeamOptionNat {
                        {
                            value = value;
                            currentVotingPower = Option.get(teamOptionVotingPower.get(value), 0);
                        };
                    },
                )
                |> Iter.toArray(_);
                #nat(o);
            };

            switch (scenario.kind) {
                case (#noLeagueEffect(noLeagueEffect)) mapDiscreteOptions(noLeagueEffect.options);
                case (#leagueChoice(leagueChoice)) mapDiscreteOptions(leagueChoice.options);
                case (#threshold(threshold)) mapDiscreteOptions(threshold.options);
                case (#lottery(_) or #proportionalBid(_)) mapNatOptions(teamOptionVotingPower.keys());
            };
        };

        private func calculateTeamConsensus(scenario : MutableScenarioData, votingClosed : Bool) : {
            #consensus : [ResolvedTeamChoice];
            #noConsensus;
        } {
            type TeamInfo = {
                var total : Nat;
                teams : HashMap.HashMap<Nat, Nat>;
            };
            let votingPowerInfo : TeamInfo = IterTools.fold(
                scenario.votes.vals(),
                {
                    var total = 0;
                    teams = HashMap.HashMap<Nat, Nat>(0, Nat.equal, Nat32.fromNat);
                },
                func(acc : TeamInfo, vote : Vote) : TeamInfo {
                    let currentVotingPower = Option.get(acc.teams.get(vote.teamId), 0);
                    acc.teams.put(vote.teamId, currentVotingPower + vote.votingPower);
                    acc.total += vote.votingPower;
                    acc;
                },
            );
            let allTeamOptions = scenario.teamIds.vals()
            |> Iter.map<Nat, (Nat, ScenarioTeamOptions)>(
                _,
                func(teamId : Nat) : (Nat, ScenarioTeamOptions) {
                    (teamId, buildTeamOptions(scenario, teamId));
                },
            )
            |> HashMap.fromIter<Nat, ScenarioTeamOptions>(_, scenario.teamIds.size(), Nat.equal, Nat32.fromNat);

            let teamResults = Buffer.Buffer<ResolvedTeamChoice>(scenario.teamIds.size());
            label f for ((teamId, teamOptions) in allTeamOptions.entries()) {
                let hasVotingPower = Option.get(votingPowerInfo.teams.get(teamId), 0) > 0;
                if (not hasVotingPower) {
                    // Only include teams with voters
                    continue f;
                };
                var optionsWithMostVotes = Buffer.Buffer<{ value : Scenario.ScenarioOptionValue; votingPower : Nat }>(0);

                let optionVotingPowers : Iter.Iter<(Scenario.ScenarioOptionValue, Nat)> = switch (teamOptions) {
                    case (#discrete(options)) options.vals()
                    |> Iter.map<ScenarioTeamOptionDiscrete, (Scenario.ScenarioOptionValue, Nat)>(
                        _,
                        func(option : ScenarioTeamOptionDiscrete) : (Scenario.ScenarioOptionValue, Nat) = (#id(option.id), option.currentVotingPower),
                    );
                    case (#nat(options)) options.vals()
                    |> Iter.map<ScenarioTeamOptionNat, (Scenario.ScenarioOptionValue, Nat)>(
                        _,
                        func(option : ScenarioTeamOptionNat) : (Scenario.ScenarioOptionValue, Nat) = (#nat(option.value), option.currentVotingPower),
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
                            let minMajorityVotingPower : Nat = Int.abs(Float.toInt(Float.floor(Float.fromInt(votingPowerInfo.total) / 2.) + 1));
                            if (minMajorityVotingPower > o.votingPower) {
                                return #noConsensus;
                            };
                        };
                    };
                };
                let chosenValueId : ?Scenario.ScenarioOptionValue = switch (optionWithMostVotes) {
                    case (null) null;
                    case (?o) ?o.value;
                };
                teamResults.add({
                    teamId = teamId;
                    value = chosenValueId;
                });
            };

            #consensus(Buffer.toArray(teamResults));
        };

        private func teamMeetsRequirements(team : Team.Team, requirements : [Scenario.TraitRequirement]) : Bool {
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
            teamVotingResult : [ResolvedTeamChoice],
        ) : () {
            // let prng = try {
            //     PseudoRandomX.fromBlob(await Random.blob());
            // } catch (err) {
            //     Debug.trap("Failed to end scenario, unable to get random entropy. Error: " # Error.message(err));
            // };
            // TODO get proper prng, async is complicating things
            let prng = PseudoRandomX.fromSeed(0);

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
                teamVotingResult,
            );

            for (effectOutcome in resolvedScenarioState.effectOutcomes.vals()) {
                processEffectOutcome<system>(closeAllScenarios, effectOutcome);
            };

            scenarios.put(
                scenario.id,
                {
                    scenario with
                    state = #resolved(resolvedScenarioState);
                },
            );
        };

        private func isAllowedAndChargedFunc(teamId : Nat, option : { allowedTeamIds : [Nat]; energyCost : Nat }) : Bool {
            let isAllowed = IterTools.any(
                option.allowedTeamIds.vals(),
                func(teamId : Nat) : Bool = teamId == teamId,
            );
            if (not isAllowed) {
                return false;
            };
            switch (chargeTeamEnergy(teamId, option.energyCost)) {
                case (#ok) true;
                case (#notEnoughEnergy) false;
            };
        };

        private func validateResolvedOption(
            teamChoice : ResolvedTeamChoice,
            scenarioKind : Scenario.ScenarioKind,
        ) : ?ValidatedChoice {
            let ?value = teamChoice.value else return null;
            switch (scenarioKind) {
                case (#noLeagueEffect(noLeagueEffect)) {
                    let #id(optionId) = value else return null;
                    let option = noLeagueEffect.options[optionId];
                    let true = isAllowedAndChargedFunc(teamChoice.teamId, option) else return null;

                    return ?{
                        value = value;
                        teamEffect = option.teamEffect;
                    };
                };
                case (#leagueChoice(leagueChoice)) {
                    let #id(optionId) = value else return null;
                    let option = leagueChoice.options[optionId];
                    let true = isAllowedAndChargedFunc(teamChoice.teamId, option) else return null;

                    return ?{
                        value = value;
                        teamEffect = option.teamEffect;
                    };
                };
                case (#threshold(threshold)) {
                    let #id(optionId) = value else return null;
                    let option = threshold.options[optionId];
                    let true = isAllowedAndChargedFunc(teamChoice.teamId, option) else return null;

                    return ?{
                        value = value;
                        teamEffect = option.teamEffect;
                    };
                };
                case (#lottery(_) or #proportionalBid(_)) {
                    let #nat(natValue) = value else return null;
                    switch (chargeTeamEnergy(teamChoice.teamId, natValue)) {
                        case (#notEnoughEnergy) return null;
                        case (#ok) ?{
                            value = value;
                            teamEffect = #noEffect;
                        };
                    };
                };
            };
        };

        private func resolveScenario(
            prng : Prng,
            scenario : MutableScenarioData,
            unvalidatedTeamChoices : [ResolvedTeamChoice],
        ) : Scenario.ScenarioStateResolved {
            // If missing team votes, add them as undecided
            // If voted for an option that is not allowed, add them as undecided
            let validatedTeamChoices = scenario.teamIds.vals()
            |> Iter.map<Nat, ValidatedTeamChoice>(
                _,
                func(teamId : Nat) : ValidatedTeamChoice {
                    let ?teamChoice = IterTools.find<ResolvedTeamChoice>(
                        unvalidatedTeamChoices.vals(),
                        func(teamChoice : ResolvedTeamChoice) : Bool = teamChoice.teamId == teamId,
                    ) else return {
                        teamId = teamId;
                        choice = null;
                    };
                    let choice = validateResolvedOption(teamChoice, scenario.kind);
                    {
                        teamId = teamId;
                        choice = choice;
                    };
                },
            )
            |> Iter.toArray(_);
            let effectOutcomes = Buffer.Buffer<Scenario.EffectOutcome>(0);
            for (teamChoice in validatedTeamChoices.vals()) {

                let teamEffect = switch (teamChoice.choice) {
                    case (?teamChoice) teamChoice.teamEffect;
                    case (null) scenario.undecidedEffect;
                };

                resolveEffectInternal(
                    prng,
                    #team(teamChoice.teamId),
                    scenario,
                    teamEffect,
                    effectOutcomes,
                );
            };

            let mapDiscrete = func(options : [Scenario.ScenarioOptionDiscrete]) : Scenario.ScenarioResolvedOptionsKind {
                let mappedOptions = options.vals()
                |> IterTools.mapEntries(
                    _,
                    func(optionId : Nat, option : Scenario.ScenarioOptionDiscrete) : Scenario.ScenarioResolvedOptionDiscrete {
                        let chosenByTeamIds = option.allowedTeamIds.vals()
                        |> IterTools.mapFilter(
                            _,
                            func(teamId : Nat) : ?Nat {
                                let ?teamChoice = IterTools.find<ValidatedTeamChoice>(
                                    validatedTeamChoices.vals(),
                                    func(teamChoice : ValidatedTeamChoice) : Bool = teamChoice.teamId == teamId,
                                ) else return null;
                                let isChosen = switch (teamChoice.choice) {
                                    case (?teamChoice) teamChoice.value == #id(optionId);
                                    case (null) false;
                                };
                                if (isChosen) ?teamId else null;
                            },
                        )
                        |> Iter.toArray(_);
                        {
                            option with
                            id = optionId;
                            seenByTeamIds = option.allowedTeamIds;
                            chosenByTeamIds = chosenByTeamIds;
                        };
                    },
                )
                |> Iter.toArray(_);
                #discrete(mappedOptions);
            };

            let options : Scenario.ScenarioResolvedOptionsKind = switch (scenario.kind) {
                case (#noLeagueEffect(noLeagueEffect)) mapDiscrete(noLeagueEffect.options);
                case (#leagueChoice(leagueChoice)) mapDiscrete(leagueChoice.options);
                case (#threshold(threshold)) mapDiscrete(threshold.options);
                case (#lottery(_) or #proportionalBid(_)) {
                    let valueToTeamsMap = HashMap.HashMap<Nat, Buffer.Buffer<Nat>>(0, Nat.equal, Nat32.fromNat);
                    label f for (validateTeamChoice in validatedTeamChoices.vals()) {
                        let natValue = switch (validateTeamChoice.choice) {
                            case (?teamChoice) switch (teamChoice.value) {
                                case (#nat(natValue)) natValue;
                                case (_) Debug.trap("Invalid vote value for lottery or proportional bid. Expected #nat, got " # debug_show (teamChoice.value));
                            };
                            case (null) continue f; // Skip undecided
                        };
                        let teamIds = switch (valueToTeamsMap.get(natValue)) {
                            case (null) {
                                let emptyTeamIds = Buffer.Buffer<Nat>(1);
                                valueToTeamsMap.put(natValue, emptyTeamIds);
                                emptyTeamIds;
                            };
                            case (?teamIds) teamIds;
                        };
                        teamIds.add(validateTeamChoice.teamId);
                    };
                    let natValues : [Scenario.ScenarioResolvedOptionNat] = valueToTeamsMap.entries()
                    // Order by value
                    |> Iter.sort<(Nat, Buffer.Buffer<Nat>)>(
                        _,
                        func((x, _) : (Nat, Buffer.Buffer<Nat>), (y, _) : (Nat, Buffer.Buffer<Nat>)) : Order.Order = Nat.compare(x, y),
                    )
                    |> Iter.map(
                        _,
                        func((value, teamIds) : (Nat, Buffer.Buffer<Nat>)) : Scenario.ScenarioResolvedOptionNat {
                            {
                                value = value;
                                chosenByTeamIds = Buffer.toArray(teamIds);
                            };
                        },
                    )
                    |> Iter.toArray(_);
                    #nat(natValues);
                };
            };
            let scenarioOutcome : Scenario.ScenarioOutcome = buildScenarioOutcome(prng, scenario, validatedTeamChoices, effectOutcomes);

            let undecidedTeams = validatedTeamChoices.vals()
            |> Iter.filter(
                _,
                func(teamChoice : ValidatedTeamChoice) : Bool = teamChoice.choice == null,
            )
            |> Iter.map(
                _,
                func(teamChoice : ValidatedTeamChoice) : Nat = teamChoice.teamId,
            )
            |> Iter.toArray(_);
            {
                scenarioOutcome = scenarioOutcome;
                options = {
                    undecidedOption = {
                        teamEffect = scenario.undecidedEffect;
                        chosenByTeamIds = undecidedTeams;
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
                    let teamVotingResult = switch (calculateTeamConsensus(scenario, true)) {
                        case (#consensus(teamVotingResult)) teamVotingResult;
                        case (#noConsensus) Prelude.unreachable();
                    };
                    end<system>(scenario, teamVotingResult);
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
        #league;
        #team : Nat;
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
            case (#lottery(lottery)) {

            };
            case (#proportionalBid(proportionalBid)) {};
            case (#noLeagueEffect(noLeagueEffect)) {
                if (noLeagueEffect.options.size() < 2) {
                    errors.add("Scenario must have at least 2 options");
                };
                validateDiscreteOptions(noLeagueEffect.options, errors);
            };
            case (#leagueChoice(leagueChoice)) {
                if (leagueChoice.options.size() < 2) {
                    errors.add("Scenario must have at least 2 options");
                };
                validateDiscreteOptions(leagueChoice.options, errors);
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
            case (#entropy(_)) {
                // TODO
            };
            case (#injury(_)) {
                // TODO
            };
            case (#noEffect) {};
        };
        #ok;
    };

    private func buildScenarioOutcome(
        prng : Prng,
        scenario : MutableScenarioData,
        validatedTeamChoices : [ValidatedTeamChoice],
        effectOutcomes : Buffer.Buffer<Scenario.EffectOutcome>,
    ) : Scenario.ScenarioOutcome {
        switch (scenario.kind) {
            case (#noLeagueEffect(noLeagueEffect)) #noLeagueEffect;
            case (#leagueChoice(leagueChoice)) {
                let leagueOptionId = getMajorityOption(prng, validatedTeamChoices);
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
                let weightedTickets : [(Nat, Float)] = validatedTeamChoices.vals()
                |> Iter.filter(
                    _,
                    func(validatedTeamChoice : ValidatedTeamChoice) : Bool {
                        switch (validatedTeamChoice.choice) {
                            case (null) false;
                            case (?teamChoice) switch (teamChoice.value) {
                                case (#nat(natValue)) natValue > 0;
                                case (_) Debug.trap("Invalid vote value for lottery. Expected #nat, got " # debug_show (teamChoice.value));
                            };
                        };
                    },
                )
                |> Iter.map<ValidatedTeamChoice, (Nat, Float)>(
                    _,
                    func(validatedTeamChoice : ValidatedTeamChoice) : (Nat, Float) {
                        let ticketCount = switch (validatedTeamChoice.choice) {
                            case (null) Prelude.unreachable();
                            case (?teamChoice) switch (teamChoice.value) {
                                case (#nat(natValue)) natValue;
                                case (_) Prelude.unreachable();
                            };
                        };
                        (validatedTeamChoice.teamId, Float.fromInt(ticketCount));
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
                        resolveEffectInternal(prng, #team(id), scenario, lottery.prize.effect, effectOutcomes);
                    };
                };
                #lottery({
                    winningTeamId = winningTeamId;
                });
            };
            case (#proportionalBid(proportionalBid)) {
                let totalBid = Array.foldLeft(
                    validatedTeamChoices,
                    0,
                    func(total : Nat, validateTeamChoice : ValidatedTeamChoice) : Nat {
                        let bidValue = switch (validateTeamChoice.choice) {
                            case (null) 0;
                            case (?teamData) {
                                switch (teamData.value) {
                                    case (#nat(natValue)) natValue;
                                    case (_) Debug.trap("Invalid vote value for proportional bid. Expected #nat, got " # debug_show (teamData.value));
                                };
                            };
                        };
                        total + bidValue;
                    },
                );
                let winningBids = Buffer.Buffer<{ teamId : Nat; proportion : Nat }>(0);
                label f for (validateTeamChoice in validatedTeamChoices.vals()) {
                    let teamBidValue = switch (validateTeamChoice.choice) {
                        case (null) continue f;
                        case (?teamData) {
                            switch (teamData.value) {
                                case (#nat(natValue)) natValue;
                                case (_) Debug.trap("Invalid vote value for proportional bid. Expected #nat, got " # debug_show (teamData.value));
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
                        teamId = validateTeamChoice.teamId;
                        proportion = proportionalValueNat;
                    });
                    if (proportionalValue > 0) {

                        let effect : Scenario.Effect = switch (proportionalBid.prize.kind) {
                            case (#skill(s)) {
                                #skill({
                                    delta = proportionalValue;
                                    duration = s.duration;
                                    position = s.position;
                                    skill = s.skill;
                                });
                            };
                        };
                        resolveEffectInternal(
                            prng,
                            #team(validateTeamChoice.teamId),
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
                let teamContributions : [Scenario.ThresholdContribution] = validatedTeamChoices.vals()
                |> Iter.map<ValidatedTeamChoice, Scenario.ThresholdContribution>(
                    _,
                    func(validatedTeamChoice : ValidatedTeamChoice) : Scenario.ThresholdContribution {
                        let optionValue = switch (validatedTeamChoice.choice) {
                            case (null) threshold.undecidedAmount;
                            case (?teamChoice) switch (teamChoice.value) {
                                case (#id(optionId)) threshold.options[optionId].value;
                                case (_) Debug.trap("Invalid vote value for threshold. Expected #id, got " # debug_show (teamChoice.value));
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
                            teamId = validatedTeamChoice.teamId;
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
                let teamIds = getTeamIdsFromTarget(prng, scenario.teamIds, entropyEffect.team, context);
                for (teamId in teamIds.vals()) {
                    let outcome = #entropy({
                        teamId = teamId;
                        delta = entropyEffect.delta;
                    });
                    outcomes.add(outcome);
                };
            };
            case (#injury(injuryEffect)) {
                let positions = getPositionsFromTarget(prng, scenario.teamIds, injuryEffect.position, context);
                for (position in positions.vals()) {
                    let outcome = #injury({
                        position = position;
                    });
                    outcomes.add(outcome);
                };
            };
            case (#skill(s)) {
                let positions = getPositionsFromTarget(prng, scenario.teamIds, s.position, context);
                for (position in positions.vals()) {
                    let skill = switch (s.skill) {
                        case (#random) Skill.getRandom(prng);
                        case (#chosen(skill)) skill;
                    };
                    outcomes.add(
                        #skill({
                            position = position;
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
                let teamIds = getTeamIdsFromTarget(prng, scenario.teamIds, e.team, context);
                for (teamId in teamIds.vals()) {
                    let outcome = #energy({
                        teamId = teamId;
                        delta = delta;
                    });
                    outcomes.add(outcome);
                };
            };
            case (#teamTrait(t)) {
                let teamIds = getTeamIdsFromTarget(prng, scenario.teamIds, t.team, context);
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
        teamChoices : [ValidatedTeamChoice],
    ) : ?Nat {
        if (teamChoices.size() < 1) {
            return null;
        };
        // Get the top choice(s), if there is a tie, choose randomly
        var choiceCounts = Trie.empty<Nat, Nat>();
        var maxCount = 0;
        label f for (teamChoice in Iter.fromArray(teamChoices)) {
            let option = switch (teamChoice.choice) {
                case (null) continue f;
                case (?teamChoice) {
                    switch (teamChoice.value) {
                        case (#id(optionId)) optionId;
                        case (#nat(natValue)) natValue;
                    };
                };
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
