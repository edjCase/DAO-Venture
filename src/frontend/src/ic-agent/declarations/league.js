export const idlFactory = ({ IDL }) => {
  const Effect = IDL.Rec();
  const Time = IDL.Int;
  const WeightedEffect = IDL.Record({
    'weight' : IDL.Nat,
    'description' : IDL.Text,
    'effect' : Effect,
  });
  const TargetTeam = IDL.Variant({ 'choosingTeam' : IDL.Null });
  const LeagueOrTeamsTarget = IDL.Variant({
    'teams' : IDL.Vec(TargetTeam),
    'league' : IDL.Null,
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
  const Target = IDL.Variant({
    'teams' : IDL.Vec(TargetTeam),
    'league' : IDL.Null,
    'positions' : IDL.Vec(TargetPosition),
  });
  Effect.fill(
    IDL.Variant({
      'allOf' : IDL.Vec(Effect),
      'noEffect' : IDL.Null,
      'oneOf' : IDL.Vec(WeightedEffect),
      'entropy' : IDL.Record({
        'target' : LeagueOrTeamsTarget,
        'delta' : IDL.Int,
      }),
      'skill' : IDL.Record({
        'duration' : Duration,
        'skill' : ChosenOrRandomSkill,
        'target' : Target,
        'delta' : IDL.Int,
      }),
      'injury' : IDL.Record({ 'target' : Target }),
      'energy' : IDL.Record({
        'value' : IDL.Variant({ 'flat' : IDL.Int }),
        'team' : TargetTeam,
      }),
    })
  );
  const ThresholdOptionValue = IDL.Variant({
    'fixed' : IDL.Int,
    'weightedChance' : IDL.Vec(
      IDL.Record({
        'weight' : IDL.Nat,
        'value' : IDL.Int,
        'description' : IDL.Text,
      })
    ),
  });
  const MetaEffect = IDL.Variant({
    'lottery' : IDL.Record({
      'prize' : Effect,
      'options' : IDL.Vec(IDL.Record({ 'tickets' : IDL.Nat })),
    }),
    'noEffect' : IDL.Null,
    'threshold' : IDL.Record({
      'failure' : IDL.Record({ 'description' : IDL.Text, 'effect' : Effect }),
      'minAmount' : IDL.Nat,
      'success' : IDL.Record({ 'description' : IDL.Text, 'effect' : Effect }),
      'options' : IDL.Vec(IDL.Record({ 'value' : ThresholdOptionValue })),
      'abstainAmount' : ThresholdOptionValue,
    }),
    'proportionalBid' : IDL.Record({
      'prize' : IDL.Record({
        'kind' : IDL.Variant({
          'skill' : IDL.Record({
            'duration' : Duration,
            'skill' : ChosenOrRandomSkill,
            'target' : IDL.Variant({
              'position' : ChosenOrRandomFieldPosition,
            }),
          }),
        }),
        'amount' : IDL.Nat,
      }),
      'options' : IDL.Vec(IDL.Record({ 'bidValue' : IDL.Nat })),
    }),
    'leagueChoice' : IDL.Record({
      'options' : IDL.Vec(IDL.Record({ 'effect' : Effect })),
    }),
  });
  const ScenarioOptionWithEffect = IDL.Record({
    'title' : IDL.Text,
    'description' : IDL.Text,
    'effect' : Effect,
    'energyCost' : IDL.Nat,
  });
  const AddScenarioRequest = IDL.Record({
    'startTime' : IDL.Opt(Time),
    'title' : IDL.Text,
    'endTime' : Time,
    'metaEffect' : MetaEffect,
    'teamIds' : IDL.Vec(IDL.Nat),
    'description' : IDL.Text,
    'abstainEffect' : Effect,
    'options' : IDL.Vec(ScenarioOptionWithEffect),
  });
  const AddScenarioError = IDL.Variant({
    'notAuthorized' : IDL.Null,
    'invalid' : IDL.Vec(IDL.Text),
  });
  const AddScenarioResult = IDL.Variant({
    'ok' : IDL.Null,
    'err' : AddScenarioError,
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
  const TargetPositionInstance = IDL.Record({
    'teamId' : IDL.Nat,
    'position' : FieldPosition,
  });
  const TargetInstance = IDL.Variant({
    'teams' : IDL.Vec(IDL.Nat),
    'league' : IDL.Null,
    'positions' : IDL.Vec(TargetPositionInstance),
  });
  const EffectOutcome = IDL.Variant({
    'entropy' : IDL.Record({ 'teamId' : IDL.Nat, 'delta' : IDL.Int }),
    'skill' : IDL.Record({
      'duration' : Duration,
      'skill' : Skill,
      'target' : TargetInstance,
      'delta' : IDL.Int,
    }),
    'injury' : IDL.Record({ 'target' : TargetInstance }),
    'energy' : IDL.Record({ 'teamId' : IDL.Nat, 'delta' : IDL.Int }),
  });
  const ThresholdContribution = IDL.Record({
    'teamId' : IDL.Nat,
    'amount' : IDL.Int,
  });
  const MetaEffectOutcome = IDL.Variant({
    'lottery' : IDL.Record({ 'winningTeamId' : IDL.Opt(IDL.Nat) }),
    'noEffect' : IDL.Null,
    'threshold' : IDL.Record({
      'contributions' : IDL.Vec(ThresholdContribution),
      'successful' : IDL.Bool,
    }),
    'proportionalBid' : IDL.Record({
      'winningBids' : IDL.Vec(
        IDL.Record({ 'teamId' : IDL.Nat, 'amount' : IDL.Nat })
      ),
    }),
    'leagueChoice' : IDL.Record({ 'optionId' : IDL.Opt(IDL.Nat) }),
  });
  const ScenarioStateResolved = IDL.Record({
    'teamChoices' : IDL.Vec(
      IDL.Record({ 'option' : IDL.Opt(IDL.Nat), 'teamId' : IDL.Nat })
    ),
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
    'metaEffect' : MetaEffect,
    'description' : IDL.Text,
    'abstainEffect' : Effect,
    'state' : ScenarioState,
    'options' : IDL.Vec(ScenarioOptionWithEffect),
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
