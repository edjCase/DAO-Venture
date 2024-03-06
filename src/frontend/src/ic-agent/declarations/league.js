export const idlFactory = ({ IDL }) => {
  const Effect = IDL.Rec();
  const CloseSeasonResult = IDL.Variant({
    'ok' : IDL.Null,
    'notAuthorized' : IDL.Null,
    'seasonNotOpen' : IDL.Null,
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
  const CompletedSeasonTeam = IDL.Record({
    'id' : IDL.Principal,
    'name' : IDL.Text,
    'wins' : IDL.Nat,
    'losses' : IDL.Nat,
    'totalScore' : IDL.Int,
    'logoUrl' : IDL.Text,
  });
  const Time = IDL.Int;
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
  const CompletedMatchTeam = IDL.Record({
    'id' : IDL.Principal,
    'name' : IDL.Text,
    'score' : IDL.Int,
    'logoUrl' : IDL.Text,
    'positions' : TeamPositions,
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
  const TargetTeam = IDL.Variant({ 'choosingTeam' : IDL.Null });
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
  const TargetPlayer = IDL.Variant({ 'position' : FieldPosition });
  const Target = IDL.Variant({
    'teams' : IDL.Vec(TargetTeam),
    'players' : IDL.Vec(TargetPlayer),
    'league' : IDL.Null,
  });
  const Injury = IDL.Variant({
    'twistedAnkle' : IDL.Null,
    'brokenArm' : IDL.Null,
    'brokenLeg' : IDL.Null,
    'concussion' : IDL.Null,
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
  const ScenarioOption = IDL.Record({
    'title' : IDL.Text,
    'description' : IDL.Text,
    'effect' : Effect,
  });
  const TargetInstance = IDL.Variant({
    'teams' : IDL.Vec(IDL.Principal),
    'players' : IDL.Vec(IDL.Nat32),
    'league' : IDL.Null,
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
  const ResolvedScenario = IDL.Record({
    'id' : IDL.Text,
    'title' : IDL.Text,
    'teamChoices' : IDL.Vec(
      IDL.Record({ 'option' : IDL.Nat, 'teamId' : IDL.Principal })
    ),
    'description' : IDL.Text,
    'effect' : IDL.Variant({
      'lottery' : IDL.Record({
        'prize' : Effect,
        'options' : IDL.Vec(IDL.Record({ 'tickets' : IDL.Nat })),
      }),
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
      'simple' : IDL.Null,
      'leagueChoice' : IDL.Record({
        'options' : IDL.Vec(IDL.Record({ 'effect' : Effect })),
      }),
    }),
    'options' : IDL.Vec(ScenarioOption),
    'effectOutcomes' : IDL.Vec(EffectOutcome),
  });
  const CompletedMatchGroup = IDL.Record({
    'time' : Time,
    'matches' : IDL.Vec(CompletedMatch),
    'scenario' : ResolvedScenario,
  });
  const CompletedSeason = IDL.Record({
    'teams' : IDL.Vec(CompletedSeasonTeam),
    'runnerUpTeamId' : IDL.Principal,
    'matchGroups' : IDL.Vec(CompletedMatchGroup),
    'championTeamId' : IDL.Principal,
  });
  const ScheduledTeamInfo = IDL.Record({
    'id' : IDL.Principal,
    'name' : IDL.Text,
    'logoUrl' : IDL.Text,
  });
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
  const Scenario = IDL.Record({
    'id' : IDL.Text,
    'title' : IDL.Text,
    'description' : IDL.Text,
    'effect' : IDL.Variant({
      'lottery' : IDL.Record({
        'prize' : Effect,
        'options' : IDL.Vec(IDL.Record({ 'tickets' : IDL.Nat })),
      }),
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
      'simple' : IDL.Null,
      'leagueChoice' : IDL.Record({
        'options' : IDL.Vec(IDL.Record({ 'effect' : Effect })),
      }),
    }),
    'options' : IDL.Vec(ScenarioOption),
  });
  const ScheduledMatchGroup = IDL.Record({
    'time' : Time,
    'matches' : IDL.Vec(ScheduledMatch),
    'scenario' : Scenario,
    'timerId' : IDL.Nat,
  });
  const InProgressTeam = IDL.Record({
    'id' : IDL.Principal,
    'name' : IDL.Text,
    'logoUrl' : IDL.Text,
    'positions' : TeamPositions,
  });
  const InProgressMatch = IDL.Record({
    'team1' : InProgressTeam,
    'team2' : InProgressTeam,
    'aura' : MatchAura,
  });
  const InProgressMatchGroup = IDL.Record({
    'stadiumId' : IDL.Principal,
    'time' : Time,
    'matches' : IDL.Vec(InProgressMatch),
    'scenario' : ResolvedScenario,
  });
  const TeamInfo = IDL.Record({
    'id' : IDL.Principal,
    'name' : IDL.Text,
    'logoUrl' : IDL.Text,
  });
  const TeamAssignment = IDL.Variant({
    'winnerOfMatch' : IDL.Nat,
    'predetermined' : TeamInfo,
    'seasonStandingIndex' : IDL.Nat,
  });
  const NotScheduledMatch = IDL.Record({
    'team1' : TeamAssignment,
    'team2' : TeamAssignment,
  });
  const NotScheduledMatchGroup = IDL.Record({
    'time' : Time,
    'matches' : IDL.Vec(NotScheduledMatch),
    'scenario' : Scenario,
  });
  const InProgressSeasonMatchGroupVariant = IDL.Variant({
    'scheduled' : ScheduledMatchGroup,
    'completed' : CompletedMatchGroup,
    'inProgress' : InProgressMatchGroup,
    'notScheduled' : NotScheduledMatchGroup,
  });
  const InProgressSeason = IDL.Record({
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
  const TeamId = IDL.Variant({ 'team1' : IDL.Null, 'team2' : IDL.Null });
  const UpcomingMatchPrediction = IDL.Record({
    'team1' : IDL.Nat,
    'team2' : IDL.Nat,
    'yourVote' : IDL.Opt(TeamId),
  });
  const UpcomingMatchPredictionsResult = IDL.Variant({
    'ok' : IDL.Vec(UpcomingMatchPrediction),
    'noUpcomingMatches' : IDL.Null,
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
    'matchId' : IDL.Nat32,
  });
  const PredictMatchOutcomeResult = IDL.Variant({
    'ok' : IDL.Null,
    'predictionsClosed' : IDL.Null,
    'matchNotFound' : IDL.Null,
    'matchGroupNotFound' : IDL.Null,
    'identityRequired' : IDL.Null,
  });
  const ProcessEffectOutcomesResult = IDL.Variant({
    'ok' : IDL.Null,
    'notAuthorized' : IDL.Null,
    'seasonNotInProgress' : IDL.Null,
  });
  const SetUserIsAdminResult = IDL.Variant({
    'ok' : IDL.Null,
    'notAuthorized' : IDL.Null,
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
  const StartSeasonRequest = IDL.Record({
    'startTime' : Time,
    'scenarios' : IDL.Vec(Scenario),
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
    'createTeam' : IDL.Func([CreateTeamRequest], [CreateTeamResult], []),
    'getAdmins' : IDL.Func([], [IDL.Vec(IDL.Principal)], ['query']),
    'getSeasonStatus' : IDL.Func([], [SeasonStatus], ['query']),
    'getTeamStandings' : IDL.Func([], [GetTeamStandingsResult], ['query']),
    'getTeams' : IDL.Func([], [IDL.Vec(TeamWithId)], ['query']),
    'getUpcomingMatchPredictions' : IDL.Func(
        [],
        [UpcomingMatchPredictionsResult],
        ['query'],
      ),
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
    'setUserIsAdmin' : IDL.Func(
        [IDL.Principal, IDL.Bool],
        [SetUserIsAdminResult],
        [],
      ),
    'startMatchGroup' : IDL.Func([IDL.Nat], [StartMatchGroupResult], []),
    'startSeason' : IDL.Func([StartSeasonRequest], [StartSeasonResult], []),
    'updateLeagueCanisters' : IDL.Func([], [UpdateLeagueCanistersResult], []),
  });
};
export const init = ({ IDL }) => { return []; };
