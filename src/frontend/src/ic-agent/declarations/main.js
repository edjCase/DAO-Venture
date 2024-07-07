export const idlFactory = ({ IDL }) => {
  const Effect = IDL.Rec();
  const CreatePlayerFluffRequest = IDL.Record({
    'title' : IDL.Text,
    'name' : IDL.Text,
    'description' : IDL.Text,
    'likes' : IDL.Vec(IDL.Text),
    'quirks' : IDL.Vec(IDL.Text),
    'dislikes' : IDL.Vec(IDL.Text),
  });
  const InvalidError = IDL.Variant({
    'nameTaken' : IDL.Null,
    'nameNotSpecified' : IDL.Null,
  });
  const CreatePlayerFluffError = IDL.Variant({
    'notAuthorized' : IDL.Null,
    'invalid' : IDL.Vec(InvalidError),
  });
  const CreatePlayerFluffResult = IDL.Variant({
    'ok' : IDL.Null,
    'err' : CreatePlayerFluffError,
  });
  const Time = IDL.Int;
  const TeamTraitEffectKind = IDL.Variant({
    'add' : IDL.Null,
    'remove' : IDL.Null,
  });
  const TargetTeam = IDL.Variant({
    'all' : IDL.Null,
    'contextual' : IDL.Null,
    'random' : IDL.Nat,
    'chosen' : IDL.Vec(IDL.Nat),
  });
  const TeamTraitEffect = IDL.Record({
    'kind' : TeamTraitEffectKind,
    'target' : TargetTeam,
    'traitId' : IDL.Text,
  });
  const WeightedEffect = IDL.Record({
    'weight' : IDL.Nat,
    'description' : IDL.Text,
    'effect' : Effect,
  });
  const EntropyEffect = IDL.Record({
    'target' : TargetTeam,
    'delta' : IDL.Int,
  });
  const Duration = IDL.Variant({
    'matches' : IDL.Nat,
    'indefinite' : IDL.Null,
  });
  const Skill = IDL.Variant({
    'battingAccuracy' : IDL.Null,
    'throwingAccuracy' : IDL.Null,
    'speed' : IDL.Null,
    'catching' : IDL.Null,
    'battingPower' : IDL.Null,
    'defense' : IDL.Null,
    'throwingPower' : IDL.Null,
  });
  const ChosenOrRandomSkill = IDL.Variant({
    'random' : IDL.Null,
    'chosen' : Skill,
  });
  const FieldPosition = IDL.Variant({
    'rightField' : IDL.Null,
    'leftField' : IDL.Null,
    'thirdBase' : IDL.Null,
    'pitcher' : IDL.Null,
    'secondBase' : IDL.Null,
    'shortStop' : IDL.Null,
    'centerField' : IDL.Null,
    'firstBase' : IDL.Null,
  });
  const ChosenOrRandomFieldPosition = IDL.Variant({
    'random' : IDL.Null,
    'chosen' : FieldPosition,
  });
  const TargetPosition = IDL.Record({
    'team' : TargetTeam,
    'position' : ChosenOrRandomFieldPosition,
  });
  const SkillEffect = IDL.Record({
    'duration' : Duration,
    'skill' : ChosenOrRandomSkill,
    'target' : TargetPosition,
    'delta' : IDL.Int,
  });
  const InjuryEffect = IDL.Record({ 'target' : TargetPosition });
  const EnergyEffect = IDL.Record({
    'value' : IDL.Variant({ 'flat' : IDL.Int }),
    'target' : TargetTeam,
  });
  Effect.fill(
    IDL.Variant({
      'allOf' : IDL.Vec(Effect),
      'teamTrait' : TeamTraitEffect,
      'noEffect' : IDL.Null,
      'oneOf' : IDL.Vec(WeightedEffect),
      'entropy' : EntropyEffect,
      'skill' : SkillEffect,
      'injury' : InjuryEffect,
      'energy' : EnergyEffect,
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
  const TraitRequirementKind = IDL.Variant({
    'prohibited' : IDL.Null,
    'required' : IDL.Null,
  });
  const TraitRequirement = IDL.Record({
    'id' : IDL.Text,
    'kind' : TraitRequirementKind,
  });
  const ScenarioOptionDiscrete__1 = IDL.Record({
    'title' : IDL.Text,
    'teamEffect' : Effect,
    'description' : IDL.Text,
    'traitRequirements' : IDL.Vec(TraitRequirement),
    'energyCost' : IDL.Nat,
  });
  const NoLeagueEffectScenarioRequest = IDL.Record({
    'options' : IDL.Vec(ScenarioOptionDiscrete__1),
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
  const ThresholdScenarioOptionRequest = IDL.Record({
    'title' : IDL.Text,
    'value' : ThresholdValue__1,
    'teamEffect' : Effect,
    'description' : IDL.Text,
    'traitRequirements' : IDL.Vec(TraitRequirement),
    'energyCost' : IDL.Nat,
  });
  const ThresholdScenarioRequest = IDL.Record({
    'failure' : IDL.Record({ 'description' : IDL.Text, 'effect' : Effect }),
    'minAmount' : IDL.Nat,
    'success' : IDL.Record({ 'description' : IDL.Text, 'effect' : Effect }),
    'options' : IDL.Vec(ThresholdScenarioOptionRequest),
    'undecidedAmount' : ThresholdValue__1,
  });
  const PropotionalBidPrizeSkill = IDL.Record({
    'duration' : Duration,
    'skill' : ChosenOrRandomSkill,
    'target' : TargetPosition,
  });
  const PropotionalBidPrizeKind = IDL.Variant({
    'skill' : PropotionalBidPrizeSkill,
  });
  const ProportionalBidPrize = IDL.Record({
    'kind' : PropotionalBidPrizeKind,
    'description' : IDL.Text,
    'amount' : IDL.Nat,
  });
  const ProportionalBidScenario = IDL.Record({
    'prize' : ProportionalBidPrize,
  });
  const LeagueChoiceScenarioOptionRequest = IDL.Record({
    'title' : IDL.Text,
    'teamEffect' : Effect,
    'description' : IDL.Text,
    'leagueEffect' : Effect,
    'traitRequirements' : IDL.Vec(TraitRequirement),
    'energyCost' : IDL.Nat,
  });
  const LeagueChoiceScenarioRequest = IDL.Record({
    'options' : IDL.Vec(LeagueChoiceScenarioOptionRequest),
  });
  const ScenarioKindRequest = IDL.Variant({
    'lottery' : LotteryScenario,
    'noLeagueEffect' : NoLeagueEffectScenarioRequest,
    'threshold' : ThresholdScenarioRequest,
    'proportionalBid' : ProportionalBidScenario,
    'leagueChoice' : LeagueChoiceScenarioRequest,
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
  const AddTeamOwnerRequest = IDL.Record({
    'votingPower' : IDL.Nat,
    'userId' : IDL.Principal,
    'teamId' : IDL.Nat,
  });
  const AddTeamOwnerError = IDL.Variant({
    'notAuthorized' : IDL.Null,
    'alreadyOwner' : IDL.Null,
    'onOtherTeam' : IDL.Nat,
    'teamNotFound' : IDL.Null,
  });
  const AddTeamOwnerResult = IDL.Variant({
    'ok' : IDL.Null,
    'err' : AddTeamOwnerError,
  });
  const ClaimBenevolentDictatorRoleError = IDL.Variant({
    'notOpenToClaim' : IDL.Null,
    'notAuthenticated' : IDL.Null,
  });
  const ClaimBenevolentDictatorRoleResult = IDL.Variant({
    'ok' : IDL.Null,
    'err' : ClaimBenevolentDictatorRoleError,
  });
  const CloseSeasonError = IDL.Variant({
    'notAuthorized' : IDL.Null,
    'seasonNotOpen' : IDL.Null,
  });
  const CloseSeasonResult = IDL.Variant({
    'ok' : IDL.Null,
    'err' : CloseSeasonError,
  });
  const CreateTeamRequest = IDL.Record({
    'motto' : IDL.Text,
    'name' : IDL.Text,
    'color' : IDL.Tuple(IDL.Nat8, IDL.Nat8, IDL.Nat8),
    'description' : IDL.Text,
    'logoUrl' : IDL.Text,
  });
  const CreateTeamError = IDL.Variant({
    'nameTaken' : IDL.Null,
    'notAuthorized' : IDL.Null,
  });
  const CreateTeamResult = IDL.Variant({
    'ok' : IDL.Nat,
    'err' : CreateTeamError,
  });
  const TrainContent = IDL.Record({
    'skill' : Skill,
    'position' : FieldPosition,
  });
  const ChangeTeamLogoContent = IDL.Record({ 'logoUrl' : IDL.Text });
  const ChangeTeamNameContent = IDL.Record({ 'name' : IDL.Text });
  const ChangeTeamMottoContent = IDL.Record({ 'motto' : IDL.Text });
  const ModifyTeamLinkContent = IDL.Record({
    'url' : IDL.Opt(IDL.Text),
    'name' : IDL.Text,
  });
  const ChangeTeamColorContent = IDL.Record({
    'color' : IDL.Tuple(IDL.Nat8, IDL.Nat8, IDL.Nat8),
  });
  const SwapPlayerPositionsContent = IDL.Record({
    'position1' : FieldPosition,
    'position2' : FieldPosition,
  });
  const ChangeTeamDescriptionContent = IDL.Record({ 'description' : IDL.Text });
  const TeamProposalContent = IDL.Variant({
    'train' : TrainContent,
    'changeLogo' : ChangeTeamLogoContent,
    'changeName' : ChangeTeamNameContent,
    'changeMotto' : ChangeTeamMottoContent,
    'modifyLink' : ModifyTeamLinkContent,
    'changeColor' : ChangeTeamColorContent,
    'swapPlayerPositions' : SwapPlayerPositionsContent,
    'changeDescription' : ChangeTeamDescriptionContent,
  });
  const CreateTeamProposalError = IDL.Variant({
    'notAuthorized' : IDL.Null,
    'invalid' : IDL.Vec(IDL.Text),
    'teamNotFound' : IDL.Null,
  });
  const CreateTeamProposalResult = IDL.Variant({
    'ok' : IDL.Nat,
    'err' : CreateTeamProposalError,
  });
  const CreateTeamTraitRequest = IDL.Record({
    'id' : IDL.Text,
    'name' : IDL.Text,
    'description' : IDL.Text,
  });
  const CreateTeamTraitError = IDL.Variant({
    'notAuthorized' : IDL.Null,
    'invalid' : IDL.Vec(IDL.Text),
    'idTaken' : IDL.Null,
  });
  const CreateTeamTraitResult = IDL.Variant({
    'ok' : IDL.Null,
    'err' : CreateTeamTraitError,
  });
  const FinishMatchGroupError = IDL.Variant({
    'notAuthorized' : IDL.Null,
    'noLiveMatchGroup' : IDL.Null,
  });
  const FinishMatchGroupResult = IDL.Variant({
    'ok' : IDL.Null,
    'err' : FinishMatchGroupError,
  });
  const Skills = IDL.Record({
    'battingAccuracy' : IDL.Int,
    'throwingAccuracy' : IDL.Int,
    'speed' : IDL.Int,
    'catching' : IDL.Int,
    'battingPower' : IDL.Int,
    'defense' : IDL.Int,
    'throwingPower' : IDL.Int,
  });
  const Player = IDL.Record({
    'id' : IDL.Nat32,
    'title' : IDL.Text,
    'name' : IDL.Text,
    'description' : IDL.Text,
    'likes' : IDL.Vec(IDL.Text),
    'teamId' : IDL.Nat,
    'position' : FieldPosition,
    'quirks' : IDL.Vec(IDL.Text),
    'dislikes' : IDL.Vec(IDL.Text),
    'skills' : Skills,
  });
  const BenevolentDictatorState = IDL.Variant({
    'open' : IDL.Null,
    'claimed' : IDL.Principal,
    'disabled' : IDL.Null,
  });
  const EntropyData = IDL.Record({
    'currentDividend' : IDL.Nat,
    'entropyThreshold' : IDL.Nat,
    'currentEntropy' : IDL.Nat,
    'maxDividend' : IDL.Nat,
  });
  const ProposalContent__1 = IDL.Variant({
    'changeTeamColor' : IDL.Record({
      'color' : IDL.Tuple(IDL.Nat8, IDL.Nat8, IDL.Nat8),
      'teamId' : IDL.Nat,
    }),
    'changeTeamDescription' : IDL.Record({
      'description' : IDL.Text,
      'teamId' : IDL.Nat,
    }),
    'changeTeamLogo' : IDL.Record({ 'logoUrl' : IDL.Text, 'teamId' : IDL.Nat }),
    'changeTeamName' : IDL.Record({ 'name' : IDL.Text, 'teamId' : IDL.Nat }),
    'changeTeamMotto' : IDL.Record({ 'motto' : IDL.Text, 'teamId' : IDL.Nat }),
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
  const LeagueProposal = IDL.Record({
    'id' : IDL.Nat,
    'content' : ProposalContent__1,
    'timeStart' : IDL.Int,
    'votes' : IDL.Vec(IDL.Tuple(IDL.Principal, Vote)),
    'statusLog' : IDL.Vec(ProposalStatusLogEntry),
    'endTimerId' : IDL.Opt(IDL.Nat),
    'timeEnd' : IDL.Int,
    'proposerId' : IDL.Principal,
  });
  const GetLeagueProposalError = IDL.Variant({ 'proposalNotFound' : IDL.Null });
  const GetLeagueProposalResult = IDL.Variant({
    'ok' : LeagueProposal,
    'err' : GetLeagueProposalError,
  });
  const PagedResult_2 = IDL.Record({
    'data' : IDL.Vec(LeagueProposal),
    'count' : IDL.Nat,
    'offset' : IDL.Nat,
  });
  const GetLeagueProposalsResult = IDL.Variant({ 'ok' : PagedResult_2 });
  const PlayerId = IDL.Nat32;
  const OutReason = IDL.Variant({
    'strikeout' : IDL.Null,
    'ballCaught' : IDL.Null,
    'hitByBall' : IDL.Null,
  });
  const TeamId = IDL.Variant({ 'team1' : IDL.Null, 'team2' : IDL.Null });
  const MatchAura = IDL.Variant({
    'foggy' : IDL.Null,
    'moveBasesIn' : IDL.Null,
    'extraStrike' : IDL.Null,
    'moreBlessingsAndCurses' : IDL.Null,
    'fastBallsHardHits' : IDL.Null,
    'explodingBalls' : IDL.Null,
    'lowGravity' : IDL.Null,
    'doubleOrNothing' : IDL.Null,
    'windy' : IDL.Null,
    'rainy' : IDL.Null,
  });
  const Trait = IDL.Record({
    'id' : IDL.Text,
    'name' : IDL.Text,
    'description' : IDL.Text,
  });
  const Base = IDL.Variant({
    'homeBase' : IDL.Null,
    'thirdBase' : IDL.Null,
    'secondBase' : IDL.Null,
    'firstBase' : IDL.Null,
  });
  const HitLocation = IDL.Variant({
    'rightField' : IDL.Null,
    'stands' : IDL.Null,
    'leftField' : IDL.Null,
    'thirdBase' : IDL.Null,
    'pitcher' : IDL.Null,
    'secondBase' : IDL.Null,
    'shortStop' : IDL.Null,
    'centerField' : IDL.Null,
    'firstBase' : IDL.Null,
  });
  const MatchEndReason = IDL.Variant({
    'noMoreRounds' : IDL.Null,
    'error' : IDL.Text,
  });
  const MatchEvent = IDL.Variant({
    'out' : IDL.Record({ 'playerId' : PlayerId, 'reason' : OutReason }),
    'throw' : IDL.Record({ 'to' : PlayerId, 'from' : PlayerId }),
    'newBatter' : IDL.Record({ 'playerId' : PlayerId }),
    'teamSwap' : IDL.Record({
      'atBatPlayerId' : PlayerId,
      'offenseTeamId' : TeamId,
    }),
    'hitByBall' : IDL.Record({ 'playerId' : PlayerId }),
    'catch' : IDL.Record({
      'difficulty' : IDL.Record({ 'value' : IDL.Int, 'crit' : IDL.Bool }),
      'playerId' : PlayerId,
      'roll' : IDL.Record({ 'value' : IDL.Int, 'crit' : IDL.Bool }),
    }),
    'auraTrigger' : IDL.Record({ 'id' : MatchAura, 'description' : IDL.Text }),
    'traitTrigger' : IDL.Record({
      'id' : Trait,
      'playerId' : PlayerId,
      'description' : IDL.Text,
    }),
    'safeAtBase' : IDL.Record({ 'base' : Base, 'playerId' : PlayerId }),
    'score' : IDL.Record({ 'teamId' : TeamId, 'amount' : IDL.Int }),
    'swing' : IDL.Record({
      'pitchRoll' : IDL.Record({ 'value' : IDL.Int, 'crit' : IDL.Bool }),
      'playerId' : PlayerId,
      'roll' : IDL.Record({ 'value' : IDL.Int, 'crit' : IDL.Bool }),
      'outcome' : IDL.Variant({
        'hit' : HitLocation,
        'strike' : IDL.Null,
        'foul' : IDL.Null,
      }),
    }),
    'injury' : IDL.Record({ 'playerId' : IDL.Nat32 }),
    'pitch' : IDL.Record({
      'roll' : IDL.Record({ 'value' : IDL.Int, 'crit' : IDL.Bool }),
      'pitcherId' : PlayerId,
    }),
    'matchEnd' : IDL.Record({ 'reason' : MatchEndReason }),
    'death' : IDL.Record({ 'playerId' : IDL.Nat32 }),
  });
  const TurnLog = IDL.Record({ 'events' : IDL.Vec(MatchEvent) });
  const RoundLog = IDL.Record({ 'turns' : IDL.Vec(TurnLog) });
  const MatchLog = IDL.Record({ 'rounds' : IDL.Vec(RoundLog) });
  const LiveMatchStatusCompleted = IDL.Record({ 'reason' : MatchEndReason });
  const LiveMatchStatus = IDL.Variant({
    'completed' : LiveMatchStatusCompleted,
    'inProgress' : IDL.Null,
  });
  const TeamPositions = IDL.Record({
    'rightField' : IDL.Nat32,
    'leftField' : IDL.Nat32,
    'thirdBase' : IDL.Nat32,
    'pitcher' : IDL.Nat32,
    'secondBase' : IDL.Nat32,
    'shortStop' : IDL.Nat32,
    'centerField' : IDL.Nat32,
    'firstBase' : IDL.Nat32,
  });
  const LiveMatchTeam = IDL.Record({
    'id' : IDL.Nat,
    'name' : IDL.Text,
    'color' : IDL.Tuple(IDL.Nat8, IDL.Nat8, IDL.Nat8),
    'score' : IDL.Int,
    'logoUrl' : IDL.Text,
    'positions' : TeamPositions,
  });
  const PlayerMatchStats = IDL.Record({
    'battingStats' : IDL.Record({
      'homeRuns' : IDL.Nat,
      'hits' : IDL.Nat,
      'runs' : IDL.Nat,
      'strikeouts' : IDL.Nat,
      'atBats' : IDL.Nat,
    }),
    'injuries' : IDL.Nat,
    'pitchingStats' : IDL.Record({
      'homeRuns' : IDL.Nat,
      'pitches' : IDL.Nat,
      'hits' : IDL.Nat,
      'runs' : IDL.Nat,
      'strikeouts' : IDL.Nat,
      'strikes' : IDL.Nat,
    }),
    'catchingStats' : IDL.Record({
      'missedCatches' : IDL.Nat,
      'throwOuts' : IDL.Nat,
      'throws' : IDL.Nat,
      'successfulCatches' : IDL.Nat,
    }),
  });
  const PlayerCondition = IDL.Variant({
    'ok' : IDL.Null,
    'dead' : IDL.Null,
    'injured' : IDL.Null,
  });
  const LivePlayerState = IDL.Record({
    'id' : PlayerId,
    'name' : IDL.Text,
    'matchStats' : PlayerMatchStats,
    'teamId' : TeamId,
    'skills' : Skills,
    'condition' : PlayerCondition,
  });
  const LiveBaseState = IDL.Record({
    'atBat' : PlayerId,
    'thirdBase' : IDL.Opt(PlayerId),
    'secondBase' : IDL.Opt(PlayerId),
    'firstBase' : IDL.Opt(PlayerId),
  });
  const LiveMatchStateWithStatus = IDL.Record({
    'log' : MatchLog,
    'status' : LiveMatchStatus,
    'team1' : LiveMatchTeam,
    'team2' : LiveMatchTeam,
    'aura' : MatchAura,
    'outs' : IDL.Nat,
    'offenseTeamId' : TeamId,
    'players' : IDL.Vec(LivePlayerState),
    'bases' : LiveBaseState,
    'strikes' : IDL.Nat,
  });
  const LiveMatchGroupState = IDL.Record({
    'id' : IDL.Nat,
    'tickTimerId' : IDL.Nat,
    'currentSeed' : IDL.Nat32,
    'matches' : IDL.Vec(LiveMatchStateWithStatus),
  });
  const MatchPredictionSummary = IDL.Record({
    'team1' : IDL.Nat,
    'team2' : IDL.Nat,
    'yourVote' : IDL.Opt(TeamId),
  });
  const MatchGroupPredictionSummary = IDL.Record({
    'matches' : IDL.Vec(MatchPredictionSummary),
  });
  const GetMatchGroupPredictionsError = IDL.Variant({ 'notFound' : IDL.Null });
  const GetMatchGroupPredictionsResult = IDL.Variant({
    'ok' : MatchGroupPredictionSummary,
    'err' : GetMatchGroupPredictionsError,
  });
  const GetPlayerError = IDL.Variant({ 'notFound' : IDL.Null });
  const GetPlayerResult = IDL.Variant({
    'ok' : Player,
    'err' : GetPlayerError,
  });
  const GetPositionError = IDL.Variant({ 'teamNotFound' : IDL.Null });
  const Result = IDL.Variant({ 'ok' : Player, 'err' : GetPositionError });
  const ScenarioOptionDiscrete = IDL.Record({
    'title' : IDL.Text,
    'teamEffect' : Effect,
    'description' : IDL.Text,
    'traitRequirements' : IDL.Vec(TraitRequirement),
    'energyCost' : IDL.Nat,
    'allowedTeamIds' : IDL.Vec(IDL.Nat),
  });
  const NoLeagueEffectScenario = IDL.Record({
    'options' : IDL.Vec(ScenarioOptionDiscrete),
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
    'teamEffect' : Effect,
    'description' : IDL.Text,
    'traitRequirements' : IDL.Vec(TraitRequirement),
    'energyCost' : IDL.Nat,
    'allowedTeamIds' : IDL.Vec(IDL.Nat),
  });
  const ThresholdScenario = IDL.Record({
    'failure' : IDL.Record({ 'description' : IDL.Text, 'effect' : Effect }),
    'minAmount' : IDL.Nat,
    'success' : IDL.Record({ 'description' : IDL.Text, 'effect' : Effect }),
    'options' : IDL.Vec(ThresholdScenarioOption),
    'undecidedAmount' : ThresholdValue,
  });
  const LeagueChoiceScenarioOption = IDL.Record({
    'title' : IDL.Text,
    'teamEffect' : Effect,
    'description' : IDL.Text,
    'leagueEffect' : Effect,
    'traitRequirements' : IDL.Vec(TraitRequirement),
    'energyCost' : IDL.Nat,
    'allowedTeamIds' : IDL.Vec(IDL.Nat),
  });
  const LeagueChoiceScenario = IDL.Record({
    'options' : IDL.Vec(LeagueChoiceScenarioOption),
  });
  const ScenarioKind = IDL.Variant({
    'lottery' : LotteryScenario,
    'noLeagueEffect' : NoLeagueEffectScenario,
    'threshold' : ThresholdScenario,
    'proportionalBid' : ProportionalBidScenario,
    'leagueChoice' : LeagueChoiceScenario,
  });
  const LotteryScenarioOutcome = IDL.Record({
    'winningTeamId' : IDL.Opt(IDL.Nat),
  });
  const ThresholdContribution = IDL.Record({
    'teamId' : IDL.Nat,
    'amount' : IDL.Int,
  });
  const ThresholdScenarioOutcome = IDL.Record({
    'contributions' : IDL.Vec(ThresholdContribution),
    'successful' : IDL.Bool,
  });
  const ProportionalWinningBid = IDL.Record({
    'proportion' : IDL.Nat,
    'teamId' : IDL.Nat,
  });
  const ProportionalBidScenarioOutcome = IDL.Record({
    'bids' : IDL.Vec(ProportionalWinningBid),
  });
  const LeagueChoiceScenarioOutcome = IDL.Record({
    'optionId' : IDL.Opt(IDL.Nat),
  });
  const ScenarioOutcome = IDL.Variant({
    'lottery' : LotteryScenarioOutcome,
    'noLeagueEffect' : IDL.Null,
    'threshold' : ThresholdScenarioOutcome,
    'proportionalBid' : ProportionalBidScenarioOutcome,
    'leagueChoice' : LeagueChoiceScenarioOutcome,
  });
  const ScenarioResolvedOptionNat = IDL.Record({
    'value' : IDL.Nat,
    'chosenByTeamIds' : IDL.Vec(IDL.Nat),
  });
  const ScenarioResolvedOptionDiscrete = IDL.Record({
    'id' : IDL.Nat,
    'title' : IDL.Text,
    'teamEffect' : Effect,
    'seenByTeamIds' : IDL.Vec(IDL.Nat),
    'description' : IDL.Text,
    'traitRequirements' : IDL.Vec(TraitRequirement),
    'chosenByTeamIds' : IDL.Vec(IDL.Nat),
    'energyCost' : IDL.Nat,
  });
  const ScenarioResolvedOptionsKind = IDL.Variant({
    'nat' : IDL.Vec(ScenarioResolvedOptionNat),
    'discrete' : IDL.Vec(ScenarioResolvedOptionDiscrete),
  });
  const ScenarioResolvedOptions = IDL.Record({
    'undecidedOption' : IDL.Record({
      'teamEffect' : Effect,
      'chosenByTeamIds' : IDL.Vec(IDL.Nat),
    }),
    'kind' : ScenarioResolvedOptionsKind,
  });
  const TeamTraitTeamEffectOutcome = IDL.Record({
    'kind' : TeamTraitEffectKind,
    'traitId' : IDL.Text,
    'teamId' : IDL.Nat,
  });
  const EntropyTeamEffectOutcome = IDL.Record({
    'teamId' : IDL.Nat,
    'delta' : IDL.Int,
  });
  const TargetPositionInstance = IDL.Record({
    'teamId' : IDL.Nat,
    'position' : FieldPosition,
  });
  const SkillPlayerEffectOutcome = IDL.Record({
    'duration' : Duration,
    'skill' : Skill,
    'target' : TargetPositionInstance,
    'delta' : IDL.Int,
  });
  const InjuryPlayerEffectOutcome = IDL.Record({
    'target' : TargetPositionInstance,
  });
  const EnergyTeamEffectOutcome = IDL.Record({
    'teamId' : IDL.Nat,
    'delta' : IDL.Int,
  });
  const EffectOutcome = IDL.Variant({
    'teamTrait' : TeamTraitTeamEffectOutcome,
    'entropy' : EntropyTeamEffectOutcome,
    'skill' : SkillPlayerEffectOutcome,
    'injury' : InjuryPlayerEffectOutcome,
    'energy' : EnergyTeamEffectOutcome,
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
  const ScenarioOptionValue = IDL.Variant({ 'id' : IDL.Nat, 'nat' : IDL.Nat });
  const ScenarioTeamOptionNat = IDL.Record({
    'value' : IDL.Nat,
    'currentVotingPower' : IDL.Nat,
  });
  const ScenarioTeamOptionDiscrete = IDL.Record({
    'id' : IDL.Nat,
    'title' : IDL.Text,
    'description' : IDL.Text,
    'traitRequirements' : IDL.Vec(TraitRequirement),
    'energyCost' : IDL.Nat,
    'currentVotingPower' : IDL.Nat,
  });
  const ScenarioTeamOptions = IDL.Variant({
    'nat' : IDL.Vec(ScenarioTeamOptionNat),
    'discrete' : IDL.Vec(ScenarioTeamOptionDiscrete),
  });
  const ScenarioVote = IDL.Record({
    'value' : IDL.Opt(ScenarioOptionValue),
    'teamOptions' : ScenarioTeamOptions,
    'votingPower' : IDL.Nat,
    'teamId' : IDL.Nat,
    'teamVotingPower' : IDL.Nat,
  });
  const GetScenarioVoteError = IDL.Variant({
    'notEligible' : IDL.Null,
    'scenarioNotFound' : IDL.Null,
  });
  const GetScenarioVoteResult = IDL.Variant({
    'ok' : ScenarioVote,
    'err' : GetScenarioVoteError,
  });
  const GetScenariosResult = IDL.Variant({ 'ok' : IDL.Vec(Scenario) });
  const CompletedSeasonTeam = IDL.Record({
    'id' : IDL.Nat,
    'name' : IDL.Text,
    'color' : IDL.Tuple(IDL.Nat8, IDL.Nat8, IDL.Nat8),
    'wins' : IDL.Nat,
    'losses' : IDL.Nat,
    'totalScore' : IDL.Int,
    'logoUrl' : IDL.Text,
    'positions' : TeamPositions,
  });
  const CompletedMatchTeam = IDL.Record({ 'id' : IDL.Nat, 'score' : IDL.Int });
  const TeamIdOrTie = IDL.Variant({
    'tie' : IDL.Null,
    'team1' : IDL.Null,
    'team2' : IDL.Null,
  });
  const CompletedMatch = IDL.Record({
    'team1' : CompletedMatchTeam,
    'team2' : CompletedMatchTeam,
    'aura' : MatchAura,
    'winner' : TeamIdOrTie,
  });
  const CompletedMatchGroup = IDL.Record({
    'time' : Time,
    'matches' : IDL.Vec(CompletedMatch),
  });
  const CompletedSeason = IDL.Record({
    'teams' : IDL.Vec(CompletedSeasonTeam),
    'runnerUpTeamId' : IDL.Nat,
    'matchGroups' : IDL.Vec(CompletedMatchGroup),
    'championTeamId' : IDL.Nat,
  });
  const TeamInfo = IDL.Record({
    'id' : IDL.Nat,
    'name' : IDL.Text,
    'color' : IDL.Tuple(IDL.Nat8, IDL.Nat8, IDL.Nat8),
    'logoUrl' : IDL.Text,
    'positions' : TeamPositions,
  });
  const ScheduledTeamInfo = IDL.Record({ 'id' : IDL.Nat });
  const MatchAuraWithMetaData = IDL.Record({
    'aura' : MatchAura,
    'name' : IDL.Text,
    'description' : IDL.Text,
  });
  const ScheduledMatch = IDL.Record({
    'team1' : ScheduledTeamInfo,
    'team2' : ScheduledTeamInfo,
    'aura' : MatchAuraWithMetaData,
  });
  const ScheduledMatchGroup = IDL.Record({
    'time' : Time,
    'matches' : IDL.Vec(ScheduledMatch),
    'timerId' : IDL.Nat,
  });
  const InProgressTeam = IDL.Record({ 'id' : IDL.Nat });
  const InProgressMatch = IDL.Record({
    'team1' : InProgressTeam,
    'team2' : InProgressTeam,
    'aura' : MatchAura,
  });
  const InProgressMatchGroup = IDL.Record({
    'time' : Time,
    'matches' : IDL.Vec(InProgressMatch),
  });
  const TeamAssignment = IDL.Variant({
    'winnerOfMatch' : IDL.Nat,
    'predetermined' : IDL.Nat,
    'seasonStandingIndex' : IDL.Nat,
  });
  const NotScheduledMatch = IDL.Record({
    'team1' : TeamAssignment,
    'team2' : TeamAssignment,
  });
  const NotScheduledMatchGroup = IDL.Record({
    'time' : Time,
    'matches' : IDL.Vec(NotScheduledMatch),
  });
  const InProgressSeasonMatchGroupVariant = IDL.Variant({
    'scheduled' : ScheduledMatchGroup,
    'completed' : CompletedMatchGroup,
    'inProgress' : InProgressMatchGroup,
    'notScheduled' : NotScheduledMatchGroup,
  });
  const InProgressSeason = IDL.Record({
    'teams' : IDL.Vec(TeamInfo),
    'players' : IDL.Vec(Player),
    'matchGroups' : IDL.Vec(InProgressSeasonMatchGroupVariant),
  });
  const SeasonStatus = IDL.Variant({
    'notStarted' : IDL.Null,
    'starting' : IDL.Null,
    'completed' : CompletedSeason,
    'inProgress' : InProgressSeason,
  });
  const GetTeamOwnersRequest = IDL.Variant({
    'all' : IDL.Null,
    'team' : IDL.Nat,
  });
  const UserVotingInfo = IDL.Record({
    'id' : IDL.Principal,
    'votingPower' : IDL.Nat,
    'teamId' : IDL.Nat,
  });
  const GetTeamOwnersResult = IDL.Variant({ 'ok' : IDL.Vec(UserVotingInfo) });
  const ProposalContent = IDL.Variant({
    'train' : TrainContent,
    'changeLogo' : ChangeTeamLogoContent,
    'changeName' : ChangeTeamNameContent,
    'changeMotto' : ChangeTeamMottoContent,
    'modifyLink' : ModifyTeamLinkContent,
    'changeColor' : ChangeTeamColorContent,
    'swapPlayerPositions' : SwapPlayerPositionsContent,
    'changeDescription' : ChangeTeamDescriptionContent,
  });
  const TeamProposal = IDL.Record({
    'id' : IDL.Nat,
    'content' : ProposalContent,
    'timeStart' : IDL.Int,
    'votes' : IDL.Vec(IDL.Tuple(IDL.Principal, Vote)),
    'statusLog' : IDL.Vec(ProposalStatusLogEntry),
    'endTimerId' : IDL.Opt(IDL.Nat),
    'timeEnd' : IDL.Int,
    'proposerId' : IDL.Principal,
  });
  const GetTeamProposalError = IDL.Variant({
    'proposalNotFound' : IDL.Null,
    'teamNotFound' : IDL.Null,
  });
  const GetTeamProposalResult = IDL.Variant({
    'ok' : TeamProposal,
    'err' : GetTeamProposalError,
  });
  const Proposal = IDL.Record({
    'id' : IDL.Nat,
    'content' : ProposalContent,
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
  const GetTeamProposalsError = IDL.Variant({ 'teamNotFound' : IDL.Null });
  const GetTeamProposalsResult = IDL.Variant({
    'ok' : PagedResult_1,
    'err' : GetTeamProposalsError,
  });
  const TeamStandingInfo = IDL.Record({
    'id' : IDL.Nat,
    'wins' : IDL.Nat,
    'losses' : IDL.Nat,
    'totalScore' : IDL.Int,
  });
  const GetTeamStandingsError = IDL.Variant({ 'notFound' : IDL.Null });
  const GetTeamStandingsResult = IDL.Variant({
    'ok' : IDL.Vec(TeamStandingInfo),
    'err' : GetTeamStandingsError,
  });
  const Link = IDL.Record({ 'url' : IDL.Text, 'name' : IDL.Text });
  const Team = IDL.Record({
    'id' : IDL.Nat,
    'motto' : IDL.Text,
    'traits' : IDL.Vec(Trait),
    'name' : IDL.Text,
    'color' : IDL.Tuple(IDL.Nat8, IDL.Nat8, IDL.Nat8),
    'description' : IDL.Text,
    'links' : IDL.Vec(Link),
    'entropy' : IDL.Nat,
    'logoUrl' : IDL.Text,
    'energy' : IDL.Int,
  });
  const TeamAssociationKind = IDL.Variant({
    'fan' : IDL.Null,
    'owner' : IDL.Record({ 'votingPower' : IDL.Nat }),
  });
  const TeamAssociation = IDL.Record({
    'id' : IDL.Nat,
    'kind' : TeamAssociationKind,
  });
  const User = IDL.Record({
    'id' : IDL.Principal,
    'team' : IDL.Opt(TeamAssociation),
    'points' : IDL.Int,
  });
  const GetUserError = IDL.Variant({
    'notAuthorized' : IDL.Null,
    'notFound' : IDL.Null,
  });
  const GetUserResult = IDL.Variant({ 'ok' : User, 'err' : GetUserError });
  const GetUserLeaderboardRequest = IDL.Record({
    'count' : IDL.Nat,
    'offset' : IDL.Nat,
  });
  const PagedResult = IDL.Record({
    'data' : IDL.Vec(User),
    'count' : IDL.Nat,
    'offset' : IDL.Nat,
  });
  const GetUserLeaderboardResult = IDL.Variant({ 'ok' : PagedResult });
  const TeamStats = IDL.Record({
    'id' : IDL.Nat,
    'totalPoints' : IDL.Int,
    'ownerCount' : IDL.Nat,
    'userCount' : IDL.Nat,
  });
  const UserStats = IDL.Record({
    'teams' : IDL.Vec(TeamStats),
    'teamOwnerCount' : IDL.Nat,
    'totalPoints' : IDL.Int,
    'userCount' : IDL.Nat,
  });
  const GetUserStatsResult = IDL.Variant({
    'ok' : UserStats,
    'err' : IDL.Null,
  });
  const PredictMatchOutcomeRequest = IDL.Record({
    'winner' : IDL.Opt(TeamId),
    'matchId' : IDL.Nat,
  });
  const PredictMatchOutcomeError = IDL.Variant({
    'predictionsClosed' : IDL.Null,
    'matchNotFound' : IDL.Null,
    'matchGroupNotFound' : IDL.Null,
    'identityRequired' : IDL.Null,
  });
  const PredictMatchOutcomeResult = IDL.Variant({
    'ok' : IDL.Null,
    'err' : PredictMatchOutcomeError,
  });
  const SetBenevolentDictatorStateError = IDL.Variant({
    'notAuthorized' : IDL.Null,
  });
  const SetBenevolentDictatorStateResult = IDL.Variant({
    'ok' : IDL.Null,
    'err' : SetBenevolentDictatorStateError,
  });
  const SetUserFavoriteTeamError = IDL.Variant({
    'notAuthorized' : IDL.Null,
    'alreadySet' : IDL.Null,
    'identityRequired' : IDL.Null,
    'teamNotFound' : IDL.Null,
  });
  const SetUserFavoriteTeamResult = IDL.Variant({
    'ok' : IDL.Null,
    'err' : SetUserFavoriteTeamError,
  });
  const TeamIdOrBoth = IDL.Variant({
    'team1' : IDL.Null,
    'team2' : IDL.Null,
    'bothTeams' : IDL.Null,
  });
  const StartMatchError = IDL.Variant({ 'notEnoughPlayers' : TeamIdOrBoth });
  const StartMatchGroupError = IDL.Variant({
    'notAuthorized' : IDL.Null,
    'notScheduledYet' : IDL.Null,
    'matchGroupNotFound' : IDL.Null,
    'alreadyStarted' : IDL.Null,
    'matchErrors' : IDL.Vec(
      IDL.Record({ 'error' : StartMatchError, 'matchId' : IDL.Nat })
    ),
  });
  const StartMatchGroupResult = IDL.Variant({
    'ok' : IDL.Null,
    'err' : StartMatchGroupError,
  });
  const DayOfWeek = IDL.Variant({
    'tuesday' : IDL.Null,
    'wednesday' : IDL.Null,
    'saturday' : IDL.Null,
    'thursday' : IDL.Null,
    'sunday' : IDL.Null,
    'friday' : IDL.Null,
    'monday' : IDL.Null,
  });
  const StartSeasonRequest = IDL.Record({
    'startTime' : Time,
    'weekDays' : IDL.Vec(DayOfWeek),
  });
  const StartSeasonError = IDL.Variant({
    'notAuthorized' : IDL.Null,
    'seedGenerationError' : IDL.Text,
    'alreadyStarted' : IDL.Null,
    'idTaken' : IDL.Null,
    'invalidArgs' : IDL.Text,
  });
  const StartSeasonResult = IDL.Variant({
    'ok' : IDL.Null,
    'err' : StartSeasonError,
  });
  const VoteOnLeagueProposalRequest = IDL.Record({
    'vote' : IDL.Bool,
    'proposalId' : IDL.Nat,
  });
  const VoteOnLeagueProposalError = IDL.Variant({
    'proposalNotFound' : IDL.Null,
    'notAuthorized' : IDL.Null,
    'alreadyVoted' : IDL.Null,
    'votingClosed' : IDL.Null,
  });
  const VoteOnLeagueProposalResult = IDL.Variant({
    'ok' : IDL.Null,
    'err' : VoteOnLeagueProposalError,
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
  const VoteOnTeamProposalRequest = IDL.Record({
    'vote' : IDL.Bool,
    'proposalId' : IDL.Nat,
  });
  const VoteOnTeamProposalError = IDL.Variant({
    'proposalNotFound' : IDL.Null,
    'notAuthorized' : IDL.Null,
    'alreadyVoted' : IDL.Null,
    'votingClosed' : IDL.Null,
    'teamNotFound' : IDL.Null,
  });
  const VoteOnTeamProposalResult = IDL.Variant({
    'ok' : IDL.Null,
    'err' : VoteOnTeamProposalError,
  });
  return IDL.Service({
    'addFluff' : IDL.Func(
        [CreatePlayerFluffRequest],
        [CreatePlayerFluffResult],
        [],
      ),
    'addScenario' : IDL.Func([AddScenarioRequest], [AddScenarioResult], []),
    'addTeamOwner' : IDL.Func([AddTeamOwnerRequest], [AddTeamOwnerResult], []),
    'claimBenevolentDictatorRole' : IDL.Func(
        [],
        [ClaimBenevolentDictatorRoleResult],
        [],
      ),
    'closeSeason' : IDL.Func([], [CloseSeasonResult], []),
    'createTeam' : IDL.Func([CreateTeamRequest], [CreateTeamResult], []),
    'createTeamProposal' : IDL.Func(
        [IDL.Nat, TeamProposalContent],
        [CreateTeamProposalResult],
        [],
      ),
    'createTeamTrait' : IDL.Func(
        [CreateTeamTraitRequest],
        [CreateTeamTraitResult],
        [],
      ),
    'finishLiveMatchGroup' : IDL.Func([], [FinishMatchGroupResult], []),
    'getAllPlayers' : IDL.Func([], [IDL.Vec(Player)], ['query']),
    'getBenevolentDictatorState' : IDL.Func(
        [],
        [BenevolentDictatorState],
        ['query'],
      ),
    'getEntropyData' : IDL.Func([], [EntropyData], ['query']),
    'getLeagueProposal' : IDL.Func(
        [IDL.Nat],
        [GetLeagueProposalResult],
        ['query'],
      ),
    'getLeagueProposals' : IDL.Func(
        [IDL.Nat, IDL.Nat],
        [GetLeagueProposalsResult],
        ['query'],
      ),
    'getLiveMatchGroupState' : IDL.Func(
        [],
        [IDL.Opt(LiveMatchGroupState)],
        ['query'],
      ),
    'getMatchGroupPredictions' : IDL.Func(
        [IDL.Nat],
        [GetMatchGroupPredictionsResult],
        ['query'],
      ),
    'getPlayer' : IDL.Func([IDL.Nat32], [GetPlayerResult], ['query']),
    'getPosition' : IDL.Func([IDL.Nat, FieldPosition], [Result], ['query']),
    'getScenario' : IDL.Func([IDL.Nat], [GetScenarioResult], ['query']),
    'getScenarioVote' : IDL.Func(
        [GetScenarioVoteRequest],
        [GetScenarioVoteResult],
        ['query'],
      ),
    'getScenarios' : IDL.Func([], [GetScenariosResult], ['query']),
    'getSeasonStatus' : IDL.Func([], [SeasonStatus], ['query']),
    'getTeamOwners' : IDL.Func(
        [GetTeamOwnersRequest],
        [GetTeamOwnersResult],
        ['query'],
      ),
    'getTeamPlayers' : IDL.Func([IDL.Nat], [IDL.Vec(Player)], ['query']),
    'getTeamProposal' : IDL.Func(
        [IDL.Nat, IDL.Nat],
        [GetTeamProposalResult],
        ['query'],
      ),
    'getTeamProposals' : IDL.Func(
        [IDL.Nat, IDL.Nat, IDL.Nat],
        [GetTeamProposalsResult],
        ['query'],
      ),
    'getTeamStandings' : IDL.Func([], [GetTeamStandingsResult], ['query']),
    'getTeams' : IDL.Func([], [IDL.Vec(Team)], ['query']),
    'getTraits' : IDL.Func([], [IDL.Vec(Trait)], ['query']),
    'getUser' : IDL.Func([IDL.Principal], [GetUserResult], ['query']),
    'getUserLeaderboard' : IDL.Func(
        [GetUserLeaderboardRequest],
        [GetUserLeaderboardResult],
        ['query'],
      ),
    'getUserStats' : IDL.Func([], [GetUserStatsResult], ['query']),
    'predictMatchOutcome' : IDL.Func(
        [PredictMatchOutcomeRequest],
        [PredictMatchOutcomeResult],
        [],
      ),
    'setBenevolentDictatorState' : IDL.Func(
        [BenevolentDictatorState],
        [SetBenevolentDictatorStateResult],
        [],
      ),
    'setFavoriteTeam' : IDL.Func(
        [IDL.Principal, IDL.Nat],
        [SetUserFavoriteTeamResult],
        [],
      ),
    'startNextMatchGroup' : IDL.Func([], [StartMatchGroupResult], []),
    'startSeason' : IDL.Func([StartSeasonRequest], [StartSeasonResult], []),
    'voteOnLeagueProposal' : IDL.Func(
        [VoteOnLeagueProposalRequest],
        [VoteOnLeagueProposalResult],
        [],
      ),
    'voteOnScenario' : IDL.Func(
        [VoteOnScenarioRequest],
        [VoteOnScenarioResult],
        [],
      ),
    'voteOnTeamProposal' : IDL.Func(
        [IDL.Nat, VoteOnTeamProposalRequest],
        [VoteOnTeamProposalResult],
        [],
      ),
  });
};
export const init = ({ IDL }) => { return []; };
