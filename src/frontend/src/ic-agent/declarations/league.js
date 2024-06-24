export const idlFactory = ({ IDL }) => {
  const Effect = IDL.Rec();
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
  const LotteryScenario = IDL.Record({ 'minBid' : IDL.Nat, 'prize' : Effect });
  const TraitRequirementKind = IDL.Variant({
    'prohibited' : IDL.Null,
    'required' : IDL.Null,
  });
  const TraitRequirement = IDL.Record({
    'id' : IDL.Text,
    'kind' : TraitRequirementKind,
  });
  const ScenarioOptionWithEffect = IDL.Record({
    'title' : IDL.Text,
    'teamEffect' : Effect,
    'description' : IDL.Text,
    'traitRequirements' : IDL.Vec(TraitRequirement),
    'energyCost' : IDL.Nat,
  });
  const NoLeagueEffectScenario = IDL.Record({
    'options' : IDL.Vec(ScenarioOptionWithEffect),
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
  });
  const ThresholdScenario = IDL.Record({
    'failure' : IDL.Record({ 'description' : IDL.Text, 'effect' : Effect }),
    'minAmount' : IDL.Nat,
    'success' : IDL.Record({ 'description' : IDL.Text, 'effect' : Effect }),
    'options' : IDL.Vec(ThresholdScenarioOption),
    'undecidedAmount' : ThresholdValue,
  });
  const ProportionalBidPrize = IDL.Record({
    'kind' : IDL.Variant({
      'skill' : IDL.Record({
        'duration' : Duration,
        'skill' : ChosenOrRandomSkill,
        'target' : TargetPosition,
      }),
    }),
    'amount' : IDL.Nat,
  });
  const ProportionalBidScenario = IDL.Record({
    'prize' : ProportionalBidPrize,
  });
  const LeagueChoiceScenarioOption = IDL.Record({
    'title' : IDL.Text,
    'teamEffect' : Effect,
    'description' : IDL.Text,
    'leagueEffect' : Effect,
    'traitRequirements' : IDL.Vec(TraitRequirement),
    'energyCost' : IDL.Nat,
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
  const AddScenarioRequest = IDL.Record({
    'startTime' : IDL.Opt(Time),
    'title' : IDL.Text,
    'endTime' : Time,
    'kind' : ScenarioKind,
    'teamIds' : IDL.Vec(IDL.Nat),
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
  const AddScenarioCustomTeamOptionRequest = IDL.Record({
    'scenarioId' : IDL.Nat,
    'value' : IDL.Variant({ 'nat' : IDL.Nat }),
  });
  const AddScenarioCustomTeamOptionError = IDL.Variant({
    'notAuthorized' : IDL.Null,
    'duplicate' : IDL.Null,
    'customOptionNotAllowed' : IDL.Null,
    'invalidValueType' : IDL.Null,
    'scenarioNotFound' : IDL.Null,
  });
  const Result = IDL.Variant({
    'ok' : IDL.Null,
    'err' : AddScenarioCustomTeamOptionError,
  });
  const ClaimBenevolentDictatorRoleError = IDL.Variant({
    'notOpenToClaim' : IDL.Null,
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
  const ProposalContent = IDL.Variant({
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
  const CreateProposalRequest = IDL.Record({ 'content' : ProposalContent });
  const CreateProposalError = IDL.Variant({ 'notAuthorized' : IDL.Null });
  const CreateProposalResult = IDL.Variant({
    'ok' : IDL.Nat,
    'err' : CreateProposalError,
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
    'teamsCallError' : IDL.Text,
  });
  const CreateTeamResult = IDL.Variant({
    'ok' : IDL.Nat,
    'err' : CreateTeamError,
  });
  const BenevolentDictatorState = IDL.Variant({
    'open' : IDL.Null,
    'claimed' : IDL.Principal,
    'disabled' : IDL.Null,
  });
  const TeamId = IDL.Variant({ 'team1' : IDL.Null, 'team2' : IDL.Null });
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
  const Proposal = IDL.Record({
    'id' : IDL.Nat,
    'content' : ProposalContent,
    'timeStart' : IDL.Int,
    'votes' : IDL.Vec(IDL.Tuple(IDL.Principal, Vote)),
    'statusLog' : IDL.Vec(ProposalStatusLogEntry),
    'endTimerId' : IDL.Opt(IDL.Nat),
    'proposer' : IDL.Principal,
    'timeEnd' : IDL.Int,
  });
  const GetProposalError = IDL.Variant({ 'proposalNotFound' : IDL.Null });
  const GetProposalResult = IDL.Variant({
    'ok' : Proposal,
    'err' : GetProposalError,
  });
  const PagedResult = IDL.Record({
    'data' : IDL.Vec(Proposal),
    'count' : IDL.Nat,
    'offset' : IDL.Nat,
  });
  const GetProposalsResult = IDL.Variant({ 'ok' : PagedResult });
  const ScenarioTeamChoice = IDL.Record({
    'option' : IDL.Opt(IDL.Nat),
    'teamId' : IDL.Nat,
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
  const LotteryMetaEffectOutcome = IDL.Record({
    'winningTeamId' : IDL.Opt(IDL.Nat),
  });
  const ThresholdContribution = IDL.Record({
    'teamId' : IDL.Nat,
    'amount' : IDL.Int,
  });
  const ThresholdMetaEffectOutcome = IDL.Record({
    'contributions' : IDL.Vec(ThresholdContribution),
    'successful' : IDL.Bool,
  });
  const ProportionalWinningBid = IDL.Record({
    'teamId' : IDL.Nat,
    'amount' : IDL.Nat,
  });
  const ProportionalBidMetaEffectOutcome = IDL.Record({
    'winningBids' : IDL.Vec(ProportionalWinningBid),
  });
  const LeagueChoiceMetaEffectOutcome = IDL.Record({
    'optionId' : IDL.Opt(IDL.Nat),
  });
  const MetaEffectOutcome = IDL.Variant({
    'lottery' : LotteryMetaEffectOutcome,
    'noLeagueEffect' : IDL.Null,
    'threshold' : ThresholdMetaEffectOutcome,
    'proportionalBid' : ProportionalBidMetaEffectOutcome,
    'leagueChoice' : LeagueChoiceMetaEffectOutcome,
  });
  const ScenarioStateResolved = IDL.Record({
    'teamChoices' : IDL.Vec(ScenarioTeamChoice),
    'effectOutcomes' : IDL.Vec(EffectOutcome),
    'metaEffectOutcome' : MetaEffectOutcome,
  });
  const ScenarioState = IDL.Variant({
    'notStarted' : IDL.Null,
    'resolved' : ScenarioStateResolved,
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
  const ScenarioVote = IDL.Record({
    'option' : IDL.Opt(IDL.Nat),
    'votingPower' : IDL.Nat,
    'optionVotingPowersForTeam' : IDL.Vec(IDL.Nat),
    'teamId' : IDL.Nat,
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
    'stadiumId' : IDL.Principal,
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
    'stadiumId' : IDL.Principal,
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
  const PlayerId = IDL.Nat32;
  const PlayerMatchStatsWithId = IDL.Record({
    'playerId' : PlayerId,
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
  const OnMatchGroupCompleteRequest = IDL.Record({
    'id' : IDL.Nat,
    'matches' : IDL.Vec(CompletedMatch),
    'playerStats' : IDL.Vec(PlayerMatchStatsWithId),
  });
  const OnMatchGroupCompleteError = IDL.Variant({
    'notAuthorized' : IDL.Null,
    'seedGenerationError' : IDL.Text,
    'matchGroupNotFound' : IDL.Null,
    'seasonNotOpen' : IDL.Null,
    'matchGroupNotInProgress' : IDL.Null,
  });
  const OnMatchGroupCompleteResult = IDL.Variant({
    'ok' : IDL.Null,
    'err' : OnMatchGroupCompleteError,
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
  const VoteOnProposalRequest = IDL.Record({
    'vote' : IDL.Bool,
    'proposalId' : IDL.Nat,
  });
  const VoteOnProposalError = IDL.Variant({
    'proposalNotFound' : IDL.Null,
    'notAuthorized' : IDL.Null,
    'alreadyVoted' : IDL.Null,
    'votingClosed' : IDL.Null,
  });
  const VoteOnProposalResult = IDL.Variant({
    'ok' : IDL.Null,
    'err' : VoteOnProposalError,
  });
  const VoteOnScenarioRequest = IDL.Record({
    'scenarioId' : IDL.Nat,
    'option' : IDL.Nat,
  });
  const VoteOnScenarioError = IDL.Variant({
    'invalidOption' : IDL.Null,
    'alreadyVoted' : IDL.Null,
    'votingNotOpen' : IDL.Null,
    'notEligible' : IDL.Null,
    'scenarioNotFound' : IDL.Null,
  });
  const VoteOnScenarioResult = IDL.Variant({
    'ok' : IDL.Null,
    'err' : VoteOnScenarioError,
  });
  return IDL.Service({
    'addScenario' : IDL.Func([AddScenarioRequest], [AddScenarioResult], []),
    'addScenarioCustomTeamOption' : IDL.Func(
        [AddScenarioCustomTeamOptionRequest],
        [Result],
        [],
      ),
    'claimBenevolentDictatorRole' : IDL.Func(
        [],
        [ClaimBenevolentDictatorRoleResult],
        [],
      ),
    'closeSeason' : IDL.Func([], [CloseSeasonResult], []),
    'createProposal' : IDL.Func(
        [CreateProposalRequest],
        [CreateProposalResult],
        [],
      ),
    'createTeam' : IDL.Func([CreateTeamRequest], [CreateTeamResult], []),
    'getBenevolentDictatorState' : IDL.Func(
        [],
        [BenevolentDictatorState],
        ['query'],
      ),
    'getMatchGroupPredictions' : IDL.Func(
        [IDL.Nat],
        [GetMatchGroupPredictionsResult],
        ['query'],
      ),
    'getProposal' : IDL.Func([IDL.Nat], [GetProposalResult], ['query']),
    'getProposals' : IDL.Func(
        [IDL.Nat, IDL.Nat],
        [GetProposalsResult],
        ['query'],
      ),
    'getScenario' : IDL.Func([IDL.Nat], [GetScenarioResult], ['query']),
    'getScenarioVote' : IDL.Func(
        [GetScenarioVoteRequest],
        [GetScenarioVoteResult],
        ['query'],
      ),
    'getScenarios' : IDL.Func([], [GetScenariosResult], ['query']),
    'getSeasonStatus' : IDL.Func([], [SeasonStatus], ['query']),
    'getTeamStandings' : IDL.Func([], [GetTeamStandingsResult], ['query']),
    'onMatchGroupComplete' : IDL.Func(
        [OnMatchGroupCompleteRequest],
        [OnMatchGroupCompleteResult],
        [],
      ),
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
    'startMatchGroup' : IDL.Func([IDL.Nat], [StartMatchGroupResult], []),
    'startSeason' : IDL.Func([StartSeasonRequest], [StartSeasonResult], []),
    'voteOnProposal' : IDL.Func(
        [VoteOnProposalRequest],
        [VoteOnProposalResult],
        [],
      ),
    'voteOnScenario' : IDL.Func(
        [VoteOnScenarioRequest],
        [VoteOnScenarioResult],
        [],
      ),
  });
};
export const init = ({ IDL }) => { return []; };
