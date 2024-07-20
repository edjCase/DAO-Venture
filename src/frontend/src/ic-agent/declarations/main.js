export const idlFactory = ({ IDL }) => {
  const Effect = IDL.Rec();
  const Time = IDL.Int;
  const WeightedEffect = IDL.Record({
    'weight' : IDL.Nat,
    'description' : IDL.Text,
    'effect' : Effect,
  });
  const WorldIncomeEffect = IDL.Record({ 'delta' : IDL.Int });
  const TargetTown = IDL.Variant({
    'all' : IDL.Null,
    'contextual' : IDL.Null,
    'random' : IDL.Nat,
    'chosen' : IDL.Vec(IDL.Nat),
  });
  const EntropyEffect = IDL.Record({ 'town' : TargetTown, 'delta' : IDL.Int });
  const EntropyThresholdEffect = IDL.Record({ 'delta' : IDL.Int });
  const CurrencyEffect = IDL.Record({
    'value' : IDL.Variant({ 'flat' : IDL.Int }),
    'town' : TargetTown,
  });
  Effect.fill(
    IDL.Variant({
      'allOf' : IDL.Vec(Effect),
      'noEffect' : IDL.Null,
      'oneOf' : IDL.Vec(WeightedEffect),
      'worldIncome' : WorldIncomeEffect,
      'entropy' : EntropyEffect,
      'entropyThreshold' : EntropyThresholdEffect,
      'currency' : CurrencyEffect,
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
  const RangeRequirement = IDL.Variant({
    'above' : IDL.Nat,
    'below' : IDL.Nat,
  });
  const Requirement = IDL.Variant({
    'age' : RangeRequirement,
    'size' : RangeRequirement,
    'entropy' : RangeRequirement,
    'currency' : RangeRequirement,
    'population' : RangeRequirement,
  });
  const ThresholdScenarioOptionRequest = IDL.Record({
    'title' : IDL.Text,
    'value' : ThresholdValue__1,
    'description' : IDL.Text,
    'townEffect' : Effect,
    'currencyCost' : IDL.Nat,
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
    'townEffect' : Effect,
    'currencyCost' : IDL.Nat,
    'requirements' : IDL.Vec(Requirement),
  });
  const NoWorldEffectScenarioRequest = IDL.Record({
    'options' : IDL.Vec(ScenarioOptionDiscrete__1),
  });
  const WorldChoiceScenarioOptionRequest = IDL.Record({
    'title' : IDL.Text,
    'worldEffect' : Effect,
    'description' : IDL.Text,
    'townEffect' : Effect,
    'currencyCost' : IDL.Nat,
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
  const ChangeTownFlagContent__1 = IDL.Record({ 'image' : FlagImage });
  const ChangeTownNameContent__1 = IDL.Record({ 'name' : IDL.Text });
  const ChangeTownMottoContent__1 = IDL.Record({ 'motto' : IDL.Text });
  const MotionContent__1 = IDL.Record({
    'title' : IDL.Text,
    'description' : IDL.Text,
  });
  const TownProposalContent = IDL.Variant({
    'changeFlag' : ChangeTownFlagContent__1,
    'changeName' : ChangeTownNameContent__1,
    'changeMotto' : ChangeTownMottoContent__1,
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
    'allowedTownIds' : IDL.Vec(IDL.Nat),
    'townEffect' : Effect,
    'currencyCost' : IDL.Nat,
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
    'allowedTownIds' : IDL.Vec(IDL.Nat),
    'townEffect' : Effect,
    'currencyCost' : IDL.Nat,
    'requirements' : IDL.Vec(Requirement),
  });
  const NoWorldEffectScenario = IDL.Record({
    'options' : IDL.Vec(ScenarioOptionDiscrete),
  });
  const WorldChoiceScenarioOption = IDL.Record({
    'title' : IDL.Text,
    'worldEffect' : Effect,
    'description' : IDL.Text,
    'allowedTownIds' : IDL.Vec(IDL.Nat),
    'townEffect' : Effect,
    'currencyCost' : IDL.Nat,
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
    'townEffect' : Effect,
    'currencyCost' : IDL.Nat,
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
  const WorldIncomeEffectOutcome = IDL.Record({ 'delta' : IDL.Int });
  const EntropyTownEffectOutcome = IDL.Record({
    'townId' : IDL.Nat,
    'delta' : IDL.Int,
  });
  const EntropyThresholdEffectOutcome = IDL.Record({ 'delta' : IDL.Int });
  const CurrencyTownEffectOutcome = IDL.Record({
    'townId' : IDL.Nat,
    'delta' : IDL.Int,
  });
  const EffectOutcome = IDL.Variant({
    'worldIncome' : WorldIncomeEffectOutcome,
    'entropy' : EntropyTownEffectOutcome,
    'entropyThreshold' : EntropyThresholdEffectOutcome,
    'currency' : CurrencyTownEffectOutcome,
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
    'currentVotingPower' : IDL.Nat,
    'currencyCost' : IDL.Nat,
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
    'changeFlag' : ChangeTownFlagContent__1,
    'changeName' : ChangeTownNameContent__1,
    'changeMotto' : ChangeTownMottoContent__1,
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
  const Town = IDL.Record({
    'id' : IDL.Nat,
    'motto' : IDL.Text,
    'name' : IDL.Text,
    'flagImage' : FlagImage,
    'entropy' : IDL.Nat,
    'currency' : IDL.Nat,
  });
  const UserMembership = IDL.Record({
    'votingPower' : IDL.Nat,
    'townId' : IDL.Nat,
  });
  const User = IDL.Record({
    'id' : IDL.Principal,
    'membership' : IDL.Opt(UserMembership),
    'points' : IDL.Int,
  });
  const GetUserError = IDL.Variant({
    'notAuthorized' : IDL.Null,
    'notFound' : IDL.Null,
  });
  const GetUserResult = IDL.Variant({ 'ok' : User, 'err' : GetUserError });
  const TownStats = IDL.Record({
    'id' : IDL.Nat,
    'totalPoints' : IDL.Int,
    'ownerCount' : IDL.Nat,
    'userCount' : IDL.Nat,
  });
  const UserStats = IDL.Record({
    'towns' : IDL.Vec(TownStats),
    'townOwnerCount' : IDL.Nat,
    'totalPoints' : IDL.Int,
    'userCount' : IDL.Nat,
  });
  const GetUserStatsResult = IDL.Variant({
    'ok' : UserStats,
    'err' : IDL.Null,
  });
  const WorldData = IDL.Record({
    'worldIncome' : IDL.Nat,
    'entropyThreshold' : IDL.Nat,
    'currentEntropy' : IDL.Nat,
  });
  const ChangeTownMottoContent = IDL.Record({
    'motto' : IDL.Text,
    'townId' : IDL.Nat,
  });
  const ChangeTownFlagContent = IDL.Record({
    'flagImage' : FlagImage,
    'townId' : IDL.Nat,
  });
  const ChangeTownNameContent = IDL.Record({
    'name' : IDL.Text,
    'townId' : IDL.Nat,
  });
  const ProposalContent = IDL.Variant({
    'changeTownMotto' : ChangeTownMottoContent,
    'changeTownFlag' : ChangeTownFlagContent,
    'changeTownName' : ChangeTownNameContent,
    'motion' : MotionContent,
  });
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
    'getWorldData' : IDL.Func([], [WorldData], ['query']),
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
