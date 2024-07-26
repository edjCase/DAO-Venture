export const idlFactory = ({ IDL }) => {
  const Effect = IDL.Rec();
  const Time = IDL.Int;
  const ResourceKind = IDL.Variant({
    'food' : IDL.Null,
    'gold' : IDL.Null,
    'wood' : IDL.Null,
    'stone' : IDL.Null,
  });
  const TargetTown = IDL.Variant({
    'all' : IDL.Null,
    'contextual' : IDL.Null,
    'random' : IDL.Nat,
    'chosen' : IDL.Vec(IDL.Nat),
  });
  const ResourceEffect = IDL.Record({
    'value' : IDL.Variant({ 'flat' : IDL.Int }),
    'kind' : ResourceKind,
    'town' : TargetTown,
  });
  const WeightedEffect = IDL.Record({
    'weight' : IDL.Nat,
    'description' : IDL.Text,
    'effect' : Effect,
  });
  const EntropyEffect = IDL.Record({ 'town' : TargetTown, 'delta' : IDL.Int });
  Effect.fill(
    IDL.Variant({
      'resource' : ResourceEffect,
      'allOf' : IDL.Vec(Effect),
      'noEffect' : IDL.Null,
      'oneOf' : IDL.Vec(WeightedEffect),
      'entropy' : EntropyEffect,
    })
  );
  const LotteryPrize = IDL.Record({
    'description' : IDL.Text,
    'effect' : Effect,
  });
  const LotteryScenario = IDL.Record({
    'minBid' : IDL.Nat,
    'prize' : LotteryPrize,
  });
  const ThresholdValue__1 = IDL.Variant({
    'fixed' : IDL.Int,
    'weightedChance' : IDL.Vec(
      IDL.Record({
        'weight' : IDL.Nat,
        'value' : IDL.Int,
        'description' : IDL.Text,
      })
    ),
  });
  const ResourceCost = IDL.Record({
    'kind' : ResourceKind,
    'amount' : IDL.Nat,
  });
  const RangeRequirement = IDL.Variant({
    'above' : IDL.Nat,
    'below' : IDL.Nat,
  });
  const ResourceRequirement = IDL.Record({
    'kind' : ResourceKind,
    'range' : RangeRequirement,
  });
  const Requirement = IDL.Variant({
    'age' : RangeRequirement,
    'resource' : ResourceRequirement,
    'size' : RangeRequirement,
    'entropy' : RangeRequirement,
    'population' : RangeRequirement,
  });
  const ThresholdScenarioOptionRequest = IDL.Record({
    'title' : IDL.Text,
    'value' : ThresholdValue__1,
    'description' : IDL.Text,
    'resourceCosts' : IDL.Vec(ResourceCost),
    'townEffect' : Effect,
    'requirements' : IDL.Vec(Requirement),
  });
  const ThresholdScenarioRequest = IDL.Record({
    'failure' : IDL.Record({ 'description' : IDL.Text, 'effect' : Effect }),
    'minAmount' : IDL.Nat,
    'success' : IDL.Record({ 'description' : IDL.Text, 'effect' : Effect }),
    'options' : IDL.Vec(ThresholdScenarioOptionRequest),
    'undecidedAmount' : ThresholdValue__1,
  });
  const TextInputScenario = IDL.Record({ 'description' : IDL.Text });
  const ScenarioOptionDiscrete__1 = IDL.Record({
    'title' : IDL.Text,
    'description' : IDL.Text,
    'resourceCosts' : IDL.Vec(ResourceCost),
    'townEffect' : Effect,
    'requirements' : IDL.Vec(Requirement),
  });
  const NoWorldEffectScenarioRequest = IDL.Record({
    'options' : IDL.Vec(ScenarioOptionDiscrete__1),
  });
  const WorldChoiceScenarioOptionRequest = IDL.Record({
    'title' : IDL.Text,
    'worldEffect' : Effect,
    'description' : IDL.Text,
    'resourceCosts' : IDL.Vec(ResourceCost),
    'townEffect' : Effect,
    'requirements' : IDL.Vec(Requirement),
  });
  const WorldChoiceScenarioRequest = IDL.Record({
    'options' : IDL.Vec(WorldChoiceScenarioOptionRequest),
  });
  const PropotionalBidPrizeKind = IDL.Record({});
  const ProportionalBidPrize = IDL.Record({
    'kind' : PropotionalBidPrizeKind,
    'description' : IDL.Text,
    'amount' : IDL.Nat,
  });
  const ProportionalBidScenario = IDL.Record({
    'prize' : ProportionalBidPrize,
  });
  const ScenarioKindRequest = IDL.Variant({
    'lottery' : LotteryScenario,
    'threshold' : ThresholdScenarioRequest,
    'textInput' : TextInputScenario,
    'noWorldEffect' : NoWorldEffectScenarioRequest,
    'worldChoice' : WorldChoiceScenarioRequest,
    'proportionalBid' : ProportionalBidScenario,
  });
  const AddScenarioRequest = IDL.Record({
    'startTime' : IDL.Opt(Time),
    'title' : IDL.Text,
    'endTime' : Time,
    'kind' : ScenarioKindRequest,
    'description' : IDL.Text,
    'undecidedEffect' : Effect,
  });
  const AddScenarioError = IDL.Variant({
    'notAuthorized' : IDL.Null,
    'invalid' : IDL.Vec(IDL.Text),
  });
  const AddScenarioResult = IDL.Variant({
    'ok' : IDL.Null,
    'err' : AddScenarioError,
  });
  const AssignUserToTownRequest = IDL.Record({
    'userId' : IDL.Principal,
    'townId' : IDL.Nat,
  });
  const AssignUserToTownError = IDL.Variant({
    'townNotFound' : IDL.Null,
    'notAuthorized' : IDL.Null,
    'notWorldMember' : IDL.Null,
  });
  const Result_1 = IDL.Variant({
    'ok' : IDL.Null,
    'err' : AssignUserToTownError,
  });
  const ClaimBenevolentDictatorRoleError = IDL.Variant({
    'notOpenToClaim' : IDL.Null,
    'notAuthenticated' : IDL.Null,
  });
  const ClaimBenevolentDictatorRoleResult = IDL.Variant({
    'ok' : IDL.Null,
    'err' : ClaimBenevolentDictatorRoleError,
  });
  const Pixel = IDL.Record({
    'red' : IDL.Nat8,
    'blue' : IDL.Nat8,
    'green' : IDL.Nat8,
  });
  const FlagImage = IDL.Record({ 'pixels' : IDL.Vec(IDL.Vec(Pixel)) });
  const ChangeTownFlagContent = IDL.Record({ 'image' : FlagImage });
  const ChangeTownNameContent = IDL.Record({ 'name' : IDL.Text });
  const ChangeTownMottoContent = IDL.Record({ 'motto' : IDL.Text });
  const IncreaseSizeContent = IDL.Record({});
  const Job = IDL.Variant({
    'processResource' : IDL.Record({
      'workerQuota' : IDL.Nat,
      'resource' : ResourceKind,
    }),
    'gatherResource' : IDL.Record({
      'workerQuota' : IDL.Nat,
      'resource' : ResourceKind,
      'locationId' : IDL.Nat,
    }),
  });
  const UpdateJobContent = IDL.Record({ 'job' : Job, 'jobId' : IDL.Nat });
  const AddJobContent = IDL.Record({ 'job' : Job });
  const RemoveJobContent = IDL.Record({ 'jobId' : IDL.Nat });
  const MotionContent__1 = IDL.Record({
    'title' : IDL.Text,
    'description' : IDL.Text,
  });
  const TownProposalContent = IDL.Variant({
    'changeFlag' : ChangeTownFlagContent,
    'changeName' : ChangeTownNameContent,
    'changeMotto' : ChangeTownMottoContent,
    'increaseSize' : IncreaseSizeContent,
    'updateJob' : UpdateJobContent,
    'addJob' : AddJobContent,
    'removeJob' : RemoveJobContent,
    'motion' : MotionContent__1,
  });
  const CreateTownProposalError = IDL.Variant({
    'townNotFound' : IDL.Null,
    'notAuthorized' : IDL.Null,
    'invalid' : IDL.Vec(IDL.Text),
  });
  const CreateTownProposalResult = IDL.Variant({
    'ok' : IDL.Nat,
    'err' : CreateTownProposalError,
  });
  const MotionContent = IDL.Record({
    'title' : IDL.Text,
    'description' : IDL.Text,
  });
  const CreateWorldProposalRequest = IDL.Variant({ 'motion' : MotionContent });
  const CreateWorldProposalError = IDL.Variant({
    'notAuthorized' : IDL.Null,
    'invalid' : IDL.Vec(IDL.Text),
  });
  const CreateWorldProposalResult = IDL.Variant({
    'ok' : IDL.Nat,
    'err' : CreateWorldProposalError,
  });
  const BenevolentDictatorState = IDL.Variant({
    'open' : IDL.Null,
    'claimed' : IDL.Principal,
    'disabled' : IDL.Null,
  });
  const ThresholdValue = IDL.Variant({
    'fixed' : IDL.Int,
    'weightedChance' : IDL.Vec(
      IDL.Record({
        'weight' : IDL.Nat,
        'value' : IDL.Int,
        'description' : IDL.Text,
      })
    ),
  });
  const ThresholdScenarioOption = IDL.Record({
    'title' : IDL.Text,
    'value' : ThresholdValue,
    'description' : IDL.Text,
    'resourceCosts' : IDL.Vec(ResourceCost),
    'allowedTownIds' : IDL.Vec(IDL.Nat),
    'townEffect' : Effect,
    'requirements' : IDL.Vec(Requirement),
  });
  const ThresholdScenario = IDL.Record({
    'failure' : IDL.Record({ 'description' : IDL.Text, 'effect' : Effect }),
    'minAmount' : IDL.Nat,
    'success' : IDL.Record({ 'description' : IDL.Text, 'effect' : Effect }),
    'options' : IDL.Vec(ThresholdScenarioOption),
    'undecidedAmount' : ThresholdValue,
  });
  const ScenarioOptionDiscrete = IDL.Record({
    'title' : IDL.Text,
    'description' : IDL.Text,
    'resourceCosts' : IDL.Vec(ResourceCost),
    'allowedTownIds' : IDL.Vec(IDL.Nat),
    'townEffect' : Effect,
    'requirements' : IDL.Vec(Requirement),
  });
  const NoWorldEffectScenario = IDL.Record({
    'options' : IDL.Vec(ScenarioOptionDiscrete),
  });
  const WorldChoiceScenarioOption = IDL.Record({
    'title' : IDL.Text,
    'worldEffect' : Effect,
    'description' : IDL.Text,
    'resourceCosts' : IDL.Vec(ResourceCost),
    'allowedTownIds' : IDL.Vec(IDL.Nat),
    'townEffect' : Effect,
    'requirements' : IDL.Vec(Requirement),
  });
  const WorldChoiceScenario = IDL.Record({
    'options' : IDL.Vec(WorldChoiceScenarioOption),
  });
  const ScenarioKind = IDL.Variant({
    'lottery' : LotteryScenario,
    'threshold' : ThresholdScenario,
    'textInput' : TextInputScenario,
    'noWorldEffect' : NoWorldEffectScenario,
    'worldChoice' : WorldChoiceScenario,
    'proportionalBid' : ProportionalBidScenario,
  });
  const LotteryScenarioOutcome = IDL.Record({
    'winningTownId' : IDL.Opt(IDL.Nat),
  });
  const ThresholdContribution = IDL.Record({
    'townId' : IDL.Nat,
    'amount' : IDL.Int,
  });
  const ThresholdScenarioOutcome = IDL.Record({
    'contributions' : IDL.Vec(ThresholdContribution),
    'successful' : IDL.Bool,
  });
  const TextInputScenarioOutcome = IDL.Record({ 'text' : IDL.Text });
  const WorldChoiceScenarioOutcome = IDL.Record({
    'optionId' : IDL.Opt(IDL.Nat),
  });
  const ProportionalWinningBid = IDL.Record({
    'proportion' : IDL.Nat,
    'townId' : IDL.Nat,
  });
  const ProportionalBidScenarioOutcome = IDL.Record({
    'bids' : IDL.Vec(ProportionalWinningBid),
  });
  const ScenarioOutcome = IDL.Variant({
    'lottery' : LotteryScenarioOutcome,
    'threshold' : ThresholdScenarioOutcome,
    'textInput' : TextInputScenarioOutcome,
    'noWorldEffect' : IDL.Null,
    'worldChoice' : WorldChoiceScenarioOutcome,
    'proportionalBid' : ProportionalBidScenarioOutcome,
  });
  const ScenarioResolvedOptionRaw = IDL.Record({
    'value' : IDL.Nat,
    'chosenByTownIds' : IDL.Vec(IDL.Nat),
  });
  const ScenarioResolvedOptionRaw_1 = IDL.Record({
    'value' : IDL.Text,
    'chosenByTownIds' : IDL.Vec(IDL.Nat),
  });
  const ScenarioResolvedOptionDiscrete = IDL.Record({
    'id' : IDL.Nat,
    'title' : IDL.Text,
    'chosenByTownIds' : IDL.Vec(IDL.Nat),
    'description' : IDL.Text,
    'resourceCosts' : IDL.Vec(ResourceCost),
    'townEffect' : Effect,
    'requirements' : IDL.Vec(Requirement),
    'seenByTownIds' : IDL.Vec(IDL.Nat),
  });
  const ScenarioResolvedOptionsKind = IDL.Variant({
    'nat' : IDL.Vec(ScenarioResolvedOptionRaw),
    'text' : IDL.Vec(ScenarioResolvedOptionRaw_1),
    'discrete' : IDL.Vec(ScenarioResolvedOptionDiscrete),
  });
  const ScenarioResolvedOptions = IDL.Record({
    'undecidedOption' : IDL.Record({
      'chosenByTownIds' : IDL.Vec(IDL.Nat),
      'townEffect' : Effect,
    }),
    'kind' : ScenarioResolvedOptionsKind,
  });
  const ResourceTownEffectOutcome = IDL.Record({
    'kind' : ResourceKind,
    'townId' : IDL.Nat,
    'delta' : IDL.Int,
  });
  const EntropyTownEffectOutcome = IDL.Record({
    'townId' : IDL.Nat,
    'delta' : IDL.Int,
  });
  const EffectOutcome = IDL.Variant({
    'resource' : ResourceTownEffectOutcome,
    'entropy' : EntropyTownEffectOutcome,
  });
  const ScenarioStateResolved = IDL.Record({
    'scenarioOutcome' : ScenarioOutcome,
    'options' : ScenarioResolvedOptions,
    'effectOutcomes' : IDL.Vec(EffectOutcome),
  });
  const ScenarioState = IDL.Variant({
    'notStarted' : IDL.Null,
    'resolved' : ScenarioStateResolved,
    'resolving' : IDL.Null,
    'inProgress' : IDL.Null,
  });
  const Scenario = IDL.Record({
    'id' : IDL.Nat,
    'startTime' : IDL.Int,
    'title' : IDL.Text,
    'endTime' : IDL.Int,
    'kind' : ScenarioKind,
    'description' : IDL.Text,
    'undecidedEffect' : Effect,
    'state' : ScenarioState,
  });
  const GetScenarioError = IDL.Variant({
    'notStarted' : IDL.Null,
    'notFound' : IDL.Null,
  });
  const GetScenarioResult = IDL.Variant({
    'ok' : Scenario,
    'err' : GetScenarioError,
  });
  const GetScenarioVoteRequest = IDL.Record({ 'scenarioId' : IDL.Nat });
  const ScenarioTownOptionNat = IDL.Record({
    'value' : IDL.Nat,
    'currentVotingPower' : IDL.Nat,
  });
  const ScenarioTownOptionText = IDL.Record({
    'value' : IDL.Text,
    'currentVotingPower' : IDL.Nat,
  });
  const ScenarioTownOptionDiscrete = IDL.Record({
    'id' : IDL.Nat,
    'title' : IDL.Text,
    'description' : IDL.Text,
    'resourceCosts' : IDL.Vec(ResourceCost),
    'currentVotingPower' : IDL.Nat,
    'requirements' : IDL.Vec(Requirement),
  });
  const ScenarioTownOptions = IDL.Variant({
    'nat' : IDL.Vec(ScenarioTownOptionNat),
    'text' : IDL.Vec(ScenarioTownOptionText),
    'discrete' : IDL.Vec(ScenarioTownOptionDiscrete),
  });
  const ScenarioOptionValue = IDL.Variant({
    'id' : IDL.Nat,
    'nat' : IDL.Nat,
    'text' : IDL.Text,
  });
  const TownVotingPower = IDL.Record({ 'total' : IDL.Nat, 'voted' : IDL.Nat });
  const ScenarioVote = IDL.Record({
    'townOptions' : ScenarioTownOptions,
    'value' : IDL.Opt(ScenarioOptionValue),
    'votingPower' : IDL.Nat,
    'townId' : IDL.Nat,
    'townVotingPower' : TownVotingPower,
  });
  const VotingData = IDL.Record({
    'townIdsWithConsensus' : IDL.Vec(IDL.Nat),
    'yourData' : IDL.Opt(ScenarioVote),
  });
  const GetScenarioVoteError = IDL.Variant({
    'notEligible' : IDL.Null,
    'scenarioNotFound' : IDL.Null,
  });
  const GetScenarioVoteResult = IDL.Variant({
    'ok' : VotingData,
    'err' : GetScenarioVoteError,
  });
  const GetScenariosResult = IDL.Variant({ 'ok' : IDL.Vec(Scenario) });
  const GetTopUsersRequest = IDL.Record({
    'count' : IDL.Nat,
    'offset' : IDL.Nat,
  });
  const UserResidency = IDL.Record({
    'votingPower' : IDL.Nat,
    'townId' : IDL.Nat,
  });
  const User = IDL.Record({
    'id' : IDL.Principal,
    'residency' : IDL.Opt(UserResidency),
    'gold' : IDL.Nat,
    'level' : IDL.Nat,
  });
  const PagedResult_2 = IDL.Record({
    'data' : IDL.Vec(User),
    'count' : IDL.Nat,
    'offset' : IDL.Nat,
  });
  const GetTopUsersResult = IDL.Variant({ 'ok' : PagedResult_2 });
  const GetTownOwnersRequest = IDL.Variant({
    'all' : IDL.Null,
    'town' : IDL.Nat,
  });
  const UserVotingInfo = IDL.Record({
    'id' : IDL.Principal,
    'votingPower' : IDL.Nat,
    'townId' : IDL.Nat,
  });
  const GetTownOwnersResult = IDL.Variant({ 'ok' : IDL.Vec(UserVotingInfo) });
  const ProposalContent__1 = IDL.Variant({
    'changeFlag' : ChangeTownFlagContent,
    'changeName' : ChangeTownNameContent,
    'changeMotto' : ChangeTownMottoContent,
    'increaseSize' : IncreaseSizeContent,
    'updateJob' : UpdateJobContent,
    'addJob' : AddJobContent,
    'removeJob' : RemoveJobContent,
    'motion' : MotionContent__1,
  });
  const Vote = IDL.Record({
    'value' : IDL.Opt(IDL.Bool),
    'votingPower' : IDL.Nat,
  });
  const ProposalStatusLogEntry = IDL.Variant({
    'failedToExecute' : IDL.Record({ 'time' : Time, 'error' : IDL.Text }),
    'rejected' : IDL.Record({ 'time' : Time }),
    'executing' : IDL.Record({ 'time' : Time }),
    'executed' : IDL.Record({ 'time' : Time }),
  });
  const TownProposal = IDL.Record({
    'id' : IDL.Nat,
    'content' : ProposalContent__1,
    'timeStart' : IDL.Int,
    'votes' : IDL.Vec(IDL.Tuple(IDL.Principal, Vote)),
    'statusLog' : IDL.Vec(ProposalStatusLogEntry),
    'endTimerId' : IDL.Opt(IDL.Nat),
    'timeEnd' : IDL.Int,
    'proposerId' : IDL.Principal,
  });
  const GetTownProposalError = IDL.Variant({
    'proposalNotFound' : IDL.Null,
    'townNotFound' : IDL.Null,
  });
  const GetTownProposalResult = IDL.Variant({
    'ok' : TownProposal,
    'err' : GetTownProposalError,
  });
  const Proposal = IDL.Record({
    'id' : IDL.Nat,
    'content' : ProposalContent__1,
    'timeStart' : IDL.Int,
    'votes' : IDL.Vec(IDL.Tuple(IDL.Principal, Vote)),
    'statusLog' : IDL.Vec(ProposalStatusLogEntry),
    'endTimerId' : IDL.Opt(IDL.Nat),
    'timeEnd' : IDL.Int,
    'proposerId' : IDL.Principal,
  });
  const PagedResult_1 = IDL.Record({
    'data' : IDL.Vec(Proposal),
    'count' : IDL.Nat,
    'offset' : IDL.Nat,
  });
  const GetTownProposalsError = IDL.Variant({ 'townNotFound' : IDL.Null });
  const GetTownProposalsResult = IDL.Variant({
    'ok' : PagedResult_1,
    'err' : GetTownProposalsError,
  });
  const ResourceList = IDL.Record({
    'food' : IDL.Nat,
    'gold' : IDL.Nat,
    'wood' : IDL.Nat,
    'stone' : IDL.Nat,
  });
  const Skill = IDL.Record({
    'proficiencyLevel' : IDL.Nat,
    'techLevel' : IDL.Nat,
  });
  const SkillList = IDL.Record({
    'farming' : Skill,
    'mining' : Skill,
    'woodCutting' : Skill,
  });
  const Town = IDL.Record({
    'id' : IDL.Nat,
    'genesisTime' : Time,
    'motto' : IDL.Text,
    'resources' : ResourceList,
    'jobs' : IDL.Vec(Job),
    'name' : IDL.Text,
    'size' : IDL.Nat,
    'flagImage' : FlagImage,
    'entropy' : IDL.Nat,
    'skills' : SkillList,
    'upkeepCondition' : IDL.Nat,
    'population' : IDL.Nat,
    'health' : IDL.Nat,
  });
  const GetUserError = IDL.Variant({
    'notAuthorized' : IDL.Null,
    'notFound' : IDL.Null,
  });
  const GetUserResult = IDL.Variant({ 'ok' : User, 'err' : GetUserError });
  const TownStats = IDL.Record({
    'id' : IDL.Nat,
    'totalUserLevel' : IDL.Int,
    'userCount' : IDL.Nat,
  });
  const UserStats = IDL.Record({
    'towns' : IDL.Vec(TownStats),
    'totalUserLevel' : IDL.Int,
    'userCount' : IDL.Nat,
  });
  const GetUserStatsResult = IDL.Variant({
    'ok' : UserStats,
    'err' : IDL.Null,
  });
  const FoodResourceInfo = IDL.Record({ 'amount' : IDL.Nat });
  const GoldResourceInfo = IDL.Record({ 'difficulty' : IDL.Nat });
  const WoodResourceInfo = IDL.Record({ 'amount' : IDL.Nat });
  const StoneResourceInfo = IDL.Record({ 'difficulty' : IDL.Nat });
  const LocationResourceList = IDL.Record({
    'food' : FoodResourceInfo,
    'gold' : GoldResourceInfo,
    'wood' : WoodResourceInfo,
    'stone' : StoneResourceInfo,
  });
  const AxialCoordinate = IDL.Record({ 'q' : IDL.Int, 'r' : IDL.Int });
  const WorldLocation = IDL.Record({
    'id' : IDL.Nat,
    'resources' : LocationResourceList,
    'townId' : IDL.Opt(IDL.Nat),
    'coordinate' : AxialCoordinate,
  });
  const World = IDL.Record({
    'age' : IDL.Nat,
    'nextDayStartTime' : IDL.Nat,
    'locations' : IDL.Vec(WorldLocation),
  });
  const GetWorldError = IDL.Record({});
  const GetWorldResult = IDL.Variant({ 'ok' : World, 'err' : GetWorldError });
  const ProposalContent = IDL.Variant({ 'motion' : MotionContent });
  const WorldProposal = IDL.Record({
    'id' : IDL.Nat,
    'content' : ProposalContent,
    'timeStart' : IDL.Int,
    'votes' : IDL.Vec(IDL.Tuple(IDL.Principal, Vote)),
    'statusLog' : IDL.Vec(ProposalStatusLogEntry),
    'endTimerId' : IDL.Opt(IDL.Nat),
    'timeEnd' : IDL.Int,
    'proposerId' : IDL.Principal,
  });
  const GetWorldProposalError = IDL.Variant({ 'proposalNotFound' : IDL.Null });
  const GetWorldProposalResult = IDL.Variant({
    'ok' : WorldProposal,
    'err' : GetWorldProposalError,
  });
  const PagedResult = IDL.Record({
    'data' : IDL.Vec(WorldProposal),
    'count' : IDL.Nat,
    'offset' : IDL.Nat,
  });
  const GetWorldProposalsResult = IDL.Variant({ 'ok' : PagedResult });
  const JoinWorldError = IDL.Variant({
    'notAuthorized' : IDL.Null,
    'alreadyWorldMember' : IDL.Null,
    'noTowns' : IDL.Null,
  });
  const Result = IDL.Variant({ 'ok' : IDL.Null, 'err' : JoinWorldError });
  const SetBenevolentDictatorStateError = IDL.Variant({
    'notAuthorized' : IDL.Null,
  });
  const SetBenevolentDictatorStateResult = IDL.Variant({
    'ok' : IDL.Null,
    'err' : SetBenevolentDictatorStateError,
  });
  const VoteOnScenarioRequest = IDL.Record({
    'scenarioId' : IDL.Nat,
    'value' : ScenarioOptionValue,
  });
  const VoteOnScenarioError = IDL.Variant({
    'votingNotOpen' : IDL.Null,
    'invalidValue' : IDL.Null,
    'notEligible' : IDL.Null,
    'scenarioNotFound' : IDL.Null,
  });
  const VoteOnScenarioResult = IDL.Variant({
    'ok' : IDL.Null,
    'err' : VoteOnScenarioError,
  });
  const VoteOnTownProposalRequest = IDL.Record({
    'vote' : IDL.Bool,
    'proposalId' : IDL.Nat,
  });
  const VoteOnTownProposalError = IDL.Variant({
    'proposalNotFound' : IDL.Null,
    'townNotFound' : IDL.Null,
    'notAuthorized' : IDL.Null,
    'alreadyVoted' : IDL.Null,
    'votingClosed' : IDL.Null,
  });
  const VoteOnTownProposalResult = IDL.Variant({
    'ok' : IDL.Null,
    'err' : VoteOnTownProposalError,
  });
  const VoteOnWorldProposalRequest = IDL.Record({
    'vote' : IDL.Bool,
    'proposalId' : IDL.Nat,
  });
  const VoteOnWorldProposalError = IDL.Variant({
    'proposalNotFound' : IDL.Null,
    'notAuthorized' : IDL.Null,
    'alreadyVoted' : IDL.Null,
    'votingClosed' : IDL.Null,
  });
  const VoteOnWorldProposalResult = IDL.Variant({
    'ok' : IDL.Null,
    'err' : VoteOnWorldProposalError,
  });
  return IDL.Service({
    'addScenario' : IDL.Func([AddScenarioRequest], [AddScenarioResult], []),
    'assignUserToTown' : IDL.Func([AssignUserToTownRequest], [Result_1], []),
    'claimBenevolentDictatorRole' : IDL.Func(
        [],
        [ClaimBenevolentDictatorRoleResult],
        [],
      ),
    'createTownProposal' : IDL.Func(
        [IDL.Nat, TownProposalContent],
        [CreateTownProposalResult],
        [],
      ),
    'createWorldProposal' : IDL.Func(
        [CreateWorldProposalRequest],
        [CreateWorldProposalResult],
        [],
      ),
    'getBenevolentDictatorState' : IDL.Func(
        [],
        [BenevolentDictatorState],
        ['query'],
      ),
    'getScenario' : IDL.Func([IDL.Nat], [GetScenarioResult], ['query']),
    'getScenarioVote' : IDL.Func(
        [GetScenarioVoteRequest],
        [GetScenarioVoteResult],
        ['query'],
      ),
    'getScenarios' : IDL.Func([], [GetScenariosResult], ['query']),
    'getTopUsers' : IDL.Func(
        [GetTopUsersRequest],
        [GetTopUsersResult],
        ['query'],
      ),
    'getTownOwners' : IDL.Func(
        [GetTownOwnersRequest],
        [GetTownOwnersResult],
        ['query'],
      ),
    'getTownProposal' : IDL.Func(
        [IDL.Nat, IDL.Nat],
        [GetTownProposalResult],
        ['query'],
      ),
    'getTownProposals' : IDL.Func(
        [IDL.Nat, IDL.Nat, IDL.Nat],
        [GetTownProposalsResult],
        ['query'],
      ),
    'getTowns' : IDL.Func([], [IDL.Vec(Town)], ['query']),
    'getUser' : IDL.Func([IDL.Principal], [GetUserResult], ['query']),
    'getUserStats' : IDL.Func([], [GetUserStatsResult], ['query']),
    'getWorld' : IDL.Func([], [GetWorldResult], ['query']),
    'getWorldProposal' : IDL.Func(
        [IDL.Nat],
        [GetWorldProposalResult],
        ['query'],
      ),
    'getWorldProposals' : IDL.Func(
        [IDL.Nat, IDL.Nat],
        [GetWorldProposalsResult],
        ['query'],
      ),
    'joinWorld' : IDL.Func([], [Result], []),
    'setBenevolentDictatorState' : IDL.Func(
        [BenevolentDictatorState],
        [SetBenevolentDictatorStateResult],
        [],
      ),
    'voteOnScenario' : IDL.Func(
        [VoteOnScenarioRequest],
        [VoteOnScenarioResult],
        [],
      ),
    'voteOnTownProposal' : IDL.Func(
        [IDL.Nat, VoteOnTownProposalRequest],
        [VoteOnTownProposalResult],
        [],
      ),
    'voteOnWorldProposal' : IDL.Func(
        [VoteOnWorldProposalRequest],
        [VoteOnWorldProposalResult],
        [],
      ),
  });
};
export const init = ({ IDL }) => { return []; };
