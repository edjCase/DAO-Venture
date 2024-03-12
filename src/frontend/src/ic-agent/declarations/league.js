export const idlFactory = ({ IDL }) => {
  const Effect = IDL.Rec();
  const CloseSeasonResult = IDL.Variant({
    'ok' : IDL.Null,
    'notAuthorized' : IDL.Null,
    'seasonNotOpen' : IDL.Null,
  });
  const ProposalContent = IDL.Variant({
    'changeTeamName' : IDL.Record({
      'name' : IDL.Text,
      'teamId' : IDL.Principal,
    }),
  });
  const CreateProposalRequest = IDL.Record({ 'content' : ProposalContent });
  const CreateProposalResult = IDL.Variant({
    'ok' : IDL.Nat,
    'notAuthorized' : IDL.Null,
  });
  const CreateTeamRequest = IDL.Record({
    'motto' : IDL.Text,
    'name' : IDL.Text,
    'color' : IDL.Tuple(IDL.Nat8, IDL.Nat8, IDL.Nat8),
    'description' : IDL.Text,
    'logoUrl' : IDL.Text,
  });
  const CreateTeamResult = IDL.Variant({
    'ok' : IDL.Principal,
    'nameTaken' : IDL.Null,
    'noStadiumsExist' : IDL.Null,
    'notAuthorized' : IDL.Null,
    'teamFactoryCallError' : IDL.Text,
    'populateTeamRosterCallError' : IDL.Text,
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
  const GetMatchGroupPredictionsResult = IDL.Variant({
    'ok' : MatchGroupPredictionSummary,
    'notFound' : IDL.Null,
  });
  const ScenarioOption__1 = IDL.Record({
    'id' : IDL.Nat,
    'description' : IDL.Text,
  });
  const Scenario = IDL.Record({
    'id' : IDL.Text,
    'title' : IDL.Text,
    'description' : IDL.Text,
    'state' : IDL.Variant({
      'notStarted' : IDL.Null,
      'resolved' : IDL.Record({
        'teamChoices' : IDL.Vec(
          IDL.Record({ 'option' : IDL.Nat, 'teamId' : IDL.Principal })
        ),
      }),
      'started' : IDL.Null,
    }),
    'options' : IDL.Vec(ScenarioOption__1),
  });
  const GetScenarioResult = IDL.Variant({
    'ok' : Scenario,
    'notFound' : IDL.Null,
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
  const CompletedSeasonTeam = IDL.Record({
    'id' : IDL.Principal,
    'name' : IDL.Text,
    'wins' : IDL.Nat,
    'losses' : IDL.Nat,
    'totalScore' : IDL.Int,
    'logoUrl' : IDL.Text,
    'positions' : TeamPositions,
  });
  const Time = IDL.Int;
  const CompletedMatchTeam = IDL.Record({
    'id' : IDL.Principal,
    'score' : IDL.Int,
  });
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
    'scenarioId' : IDL.Text,
    'time' : Time,
    'matches' : IDL.Vec(CompletedMatch),
  });
  const CompletedSeason = IDL.Record({
    'teams' : IDL.Vec(CompletedSeasonTeam),
    'runnerUpTeamId' : IDL.Principal,
    'matchGroups' : IDL.Vec(CompletedMatchGroup),
    'championTeamId' : IDL.Principal,
  });
  const TeamInfo = IDL.Record({
    'id' : IDL.Principal,
    'name' : IDL.Text,
    'logoUrl' : IDL.Text,
    'positions' : TeamPositions,
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
  const Skills = IDL.Record({
    'battingAccuracy' : IDL.Int,
    'throwingAccuracy' : IDL.Int,
    'speed' : IDL.Int,
    'catching' : IDL.Int,
    'battingPower' : IDL.Int,
    'defense' : IDL.Int,
    'throwingPower' : IDL.Int,
  });
  const PlayerWithId = IDL.Record({
    'id' : IDL.Nat32,
    'title' : IDL.Text,
    'name' : IDL.Text,
    'description' : IDL.Text,
    'likes' : IDL.Vec(IDL.Text),
    'teamId' : IDL.Principal,
    'position' : FieldPosition,
    'quirks' : IDL.Vec(IDL.Text),
    'dislikes' : IDL.Vec(IDL.Text),
    'skills' : Skills,
    'traitIds' : IDL.Vec(IDL.Text),
  });
  const ScheduledTeamInfo = IDL.Record({ 'id' : IDL.Principal });
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
    'scenarioId' : IDL.Text,
    'stadiumId' : IDL.Principal,
    'time' : Time,
    'matches' : IDL.Vec(ScheduledMatch),
    'timerId' : IDL.Nat,
  });
  const InProgressTeam = IDL.Record({ 'id' : IDL.Principal });
  const InProgressMatch = IDL.Record({
    'team1' : InProgressTeam,
    'team2' : InProgressTeam,
    'aura' : MatchAura,
  });
  const InProgressMatchGroup = IDL.Record({
    'scenarioId' : IDL.Text,
    'stadiumId' : IDL.Principal,
    'time' : Time,
    'matches' : IDL.Vec(InProgressMatch),
  });
  const TeamAssignment = IDL.Variant({
    'winnerOfMatch' : IDL.Nat,
    'predetermined' : IDL.Principal,
    'seasonStandingIndex' : IDL.Nat,
  });
  const NotScheduledMatch = IDL.Record({
    'team1' : TeamAssignment,
    'team2' : TeamAssignment,
  });
  const NotScheduledMatchGroup = IDL.Record({
    'scenarioId' : IDL.Text,
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
    'players' : IDL.Vec(PlayerWithId),
    'matchGroups' : IDL.Vec(InProgressSeasonMatchGroupVariant),
  });
  const SeasonStatus = IDL.Variant({
    'notStarted' : IDL.Null,
    'starting' : IDL.Null,
    'completed' : CompletedSeason,
    'inProgress' : InProgressSeason,
  });
  const TeamStandingInfo = IDL.Record({
    'id' : IDL.Principal,
    'wins' : IDL.Nat,
    'losses' : IDL.Nat,
    'totalScore' : IDL.Int,
  });
  const GetTeamStandingsResult = IDL.Variant({
    'ok' : IDL.Vec(TeamStandingInfo),
    'notFound' : IDL.Null,
  });
  const TeamWithId = IDL.Record({
    'id' : IDL.Principal,
    'motto' : IDL.Text,
    'name' : IDL.Text,
    'color' : IDL.Tuple(IDL.Nat8, IDL.Nat8, IDL.Nat8),
    'description' : IDL.Text,
    'entropy' : IDL.Nat,
    'logoUrl' : IDL.Text,
    'energy' : IDL.Int,
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
  const OnMatchGroupCompleteResult = IDL.Variant({
    'ok' : IDL.Null,
    'notAuthorized' : IDL.Null,
    'seedGenerationError' : IDL.Text,
    'matchGroupNotFound' : IDL.Null,
    'seasonNotOpen' : IDL.Null,
    'matchGroupNotInProgress' : IDL.Null,
  });
  const PredictMatchOutcomeRequest = IDL.Record({
    'winner' : IDL.Opt(TeamId),
    'matchId' : IDL.Nat,
  });
  const PredictMatchOutcomeResult = IDL.Variant({
    'ok' : IDL.Null,
    'predictionsClosed' : IDL.Null,
    'matchNotFound' : IDL.Null,
    'matchGroupNotFound' : IDL.Null,
    'identityRequired' : IDL.Null,
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
  const TargetInstance = IDL.Variant({
    'teams' : IDL.Vec(IDL.Principal),
    'players' : IDL.Vec(IDL.Nat32),
    'league' : IDL.Null,
  });
  const Injury = IDL.Variant({
    'twistedAnkle' : IDL.Null,
    'brokenArm' : IDL.Null,
    'brokenLeg' : IDL.Null,
    'concussion' : IDL.Null,
  });
  const EffectOutcome = IDL.Variant({
    'entropy' : IDL.Record({ 'teamId' : IDL.Principal, 'delta' : IDL.Int }),
    'skill' : IDL.Record({
      'duration' : Duration,
      'skill' : Skill,
      'target' : TargetInstance,
      'delta' : IDL.Int,
    }),
    'injury' : IDL.Record({ 'target' : TargetInstance, 'injury' : Injury }),
    'energy' : IDL.Record({ 'teamId' : IDL.Principal, 'delta' : IDL.Int }),
  });
  const ProcessEffectOutcomesResult = IDL.Variant({
    'ok' : IDL.Null,
    'notAuthorized' : IDL.Null,
    'seasonNotInProgress' : IDL.Null,
  });
  const TeamIdOrBoth = IDL.Variant({
    'team1' : IDL.Null,
    'team2' : IDL.Null,
    'bothTeams' : IDL.Null,
  });
  const StartMatchError = IDL.Variant({ 'notEnoughPlayers' : TeamIdOrBoth });
  const StartMatchGroupResult = IDL.Variant({
    'ok' : IDL.Null,
    'notAuthorized' : IDL.Null,
    'notScheduledYet' : IDL.Null,
    'matchGroupNotFound' : IDL.Null,
    'alreadyStarted' : IDL.Null,
    'matchErrors' : IDL.Vec(
      IDL.Record({ 'error' : StartMatchError, 'matchId' : IDL.Nat })
    ),
  });
  const TargetTeam = IDL.Variant({ 'choosingTeam' : IDL.Null });
  const TargetPlayer = IDL.Variant({ 'position' : FieldPosition });
  const Target = IDL.Variant({
    'teams' : IDL.Vec(TargetTeam),
    'players' : IDL.Vec(TargetPlayer),
    'league' : IDL.Null,
  });
  Effect.fill(
    IDL.Variant({
      'allOf' : IDL.Vec(Effect),
      'noEffect' : IDL.Null,
      'oneOf' : IDL.Vec(IDL.Tuple(IDL.Nat, Effect)),
      'entropy' : IDL.Record({ 'team' : TargetTeam, 'delta' : IDL.Int }),
      'skill' : IDL.Record({
        'duration' : Duration,
        'skill' : Skill,
        'target' : Target,
        'delta' : IDL.Int,
      }),
      'injury' : IDL.Record({ 'target' : Target, 'injury' : Injury }),
      'energy' : IDL.Record({
        'value' : IDL.Variant({ 'flat' : IDL.Int }),
        'team' : TargetTeam,
      }),
    })
  );
  const MetaEffect = IDL.Variant({
    'lottery' : IDL.Record({
      'prize' : Effect,
      'options' : IDL.Vec(IDL.Record({ 'tickets' : IDL.Nat })),
    }),
    'noEffect' : IDL.Null,
    'threshold' : IDL.Record({
      'threshold' : IDL.Nat,
      'over' : Effect,
      'under' : Effect,
      'options' : IDL.Vec(
        IDL.Record({
          'value' : IDL.Variant({
            'fixed' : IDL.Int,
            'weightedChance' : IDL.Vec(IDL.Tuple(IDL.Nat, IDL.Int)),
          }),
        })
      ),
    }),
    'pickASide' : IDL.Record({
      'options' : IDL.Vec(IDL.Record({ 'sideId' : IDL.Text })),
    }),
    'proportionalBid' : IDL.Record({
      'prize' : IDL.Variant({
        'skill' : IDL.Record({
          'total' : IDL.Nat,
          'duration' : Duration,
          'skill' : Skill,
          'target' : IDL.Variant({ 'position' : FieldPosition }),
        }),
      }),
      'options' : IDL.Vec(IDL.Record({ 'bidValue' : IDL.Nat })),
    }),
    'leagueChoice' : IDL.Record({
      'options' : IDL.Vec(IDL.Record({ 'effect' : Effect })),
    }),
  });
  const ScenarioOption = IDL.Record({
    'title' : IDL.Text,
    'description' : IDL.Text,
    'effect' : Effect,
  });
  const AddScenarioRequest = IDL.Record({
    'id' : IDL.Text,
    'title' : IDL.Text,
    'metaEffect' : MetaEffect,
    'description' : IDL.Text,
    'options' : IDL.Vec(ScenarioOption),
  });
  const StartSeasonRequest = IDL.Record({
    'startTime' : Time,
    'scenarios' : IDL.Vec(AddScenarioRequest),
  });
  const StartSeasonResult = IDL.Variant({
    'ok' : IDL.Null,
    'invalidScenario' : IDL.Record({
      'id' : IDL.Text,
      'errors' : IDL.Vec(IDL.Text),
    }),
    'noStadiumsExist' : IDL.Null,
    'notAuthorized' : IDL.Null,
    'oddNumberOfTeams' : IDL.Null,
    'seedGenerationError' : IDL.Text,
    'alreadyStarted' : IDL.Null,
    'idTaken' : IDL.Null,
    'scenarioCountMismatch' : IDL.Record({
      'actual' : IDL.Nat,
      'expected' : IDL.Nat,
    }),
    'noTeams' : IDL.Null,
  });
  const UpdateLeagueCanistersResult = IDL.Variant({
    'ok' : IDL.Null,
    'notAuthorized' : IDL.Null,
  });
  return IDL.Service({
    'clearTeams' : IDL.Func([], [], []),
    'closeSeason' : IDL.Func([], [CloseSeasonResult], []),
    'createProposal' : IDL.Func(
        [CreateProposalRequest],
        [CreateProposalResult],
        [],
      ),
    'createTeam' : IDL.Func([CreateTeamRequest], [CreateTeamResult], []),
    'getMatchGroupPredictions' : IDL.Func(
        [IDL.Nat],
        [GetMatchGroupPredictionsResult],
        ['query'],
      ),
    'getScenario' : IDL.Func([IDL.Text], [GetScenarioResult], ['query']),
    'getSeasonStatus' : IDL.Func([], [SeasonStatus], ['query']),
    'getTeamStandings' : IDL.Func([], [GetTeamStandingsResult], ['query']),
    'getTeams' : IDL.Func([], [IDL.Vec(TeamWithId)], ['query']),
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
    'processEffectOutcomes' : IDL.Func(
        [IDL.Vec(EffectOutcome)],
        [ProcessEffectOutcomesResult],
        [],
      ),
    'startMatchGroup' : IDL.Func([IDL.Nat], [StartMatchGroupResult], []),
    'startSeason' : IDL.Func([StartSeasonRequest], [StartSeasonResult], []),
    'updateLeagueCanisters' : IDL.Func([], [UpdateLeagueCanistersResult], []),
  });
};
export const init = ({ IDL }) => { return []; };
