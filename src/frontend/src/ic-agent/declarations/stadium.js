export const idlFactory = ({ IDL }) => {
  const CancelMatchGroupRequest = IDL.Record({ 'id' : IDL.Nat });
  const CancelMatchGroupResult = IDL.Variant({
    'ok' : IDL.Null,
    'matchGroupNotFound' : IDL.Null,
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
  const CompletedTickResult = IDL.Record({
    'match' : CompletedMatch,
    'matchStats' : IDL.Vec(PlayerMatchStatsWithId),
  });
  const OutReason = IDL.Variant({
    'strikeout' : IDL.Null,
    'ballCaught' : IDL.Null,
    'hitByBall' : IDL.Null,
  });
  const TeamId = IDL.Variant({ 'team1' : IDL.Null, 'team2' : IDL.Null });
  const Skill = IDL.Variant({
    'battingAccuracy' : IDL.Null,
    'throwingAccuracy' : IDL.Null,
    'speed' : IDL.Null,
    'catching' : IDL.Null,
    'battingPower' : IDL.Null,
    'defense' : IDL.Null,
    'throwingPower' : IDL.Null,
  });
  const Injury = IDL.Variant({
    'twistedAnkle' : IDL.Null,
    'brokenArm' : IDL.Null,
    'brokenLeg' : IDL.Null,
    'concussion' : IDL.Null,
  });
  const Curse = IDL.Variant({ 'skill' : Skill, 'injury' : Injury });
  const Blessing = IDL.Variant({ 'skill' : Skill });
  const Effect = IDL.Variant({
    'skill' : IDL.Record({ 'skill' : IDL.Opt(Skill), 'delta' : IDL.Int }),
  });
  const Trait = IDL.Record({
    'id' : IDL.Text,
    'effects' : IDL.Vec(Effect),
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
  const Event = IDL.Variant({
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
    'curse' : IDL.Record({ 'playerId' : IDL.Nat32, 'curse' : Curse }),
    'blessing' : IDL.Record({ 'playerId' : IDL.Nat32, 'blessing' : Blessing }),
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
    'injury' : IDL.Record({ 'playerId' : IDL.Nat32, 'injury' : Injury }),
    'pitch' : IDL.Record({
      'roll' : IDL.Record({ 'value' : IDL.Int, 'crit' : IDL.Bool }),
      'pitcherId' : PlayerId,
    }),
    'matchEnd' : IDL.Record({ 'reason' : MatchEndReason }),
    'death' : IDL.Record({ 'playerId' : IDL.Nat32 }),
  });
  const TurnLog = IDL.Record({ 'events' : IDL.Vec(Event) });
  const RoundLog = IDL.Record({ 'turns' : IDL.Vec(TurnLog) });
  const MatchLog = IDL.Record({ 'rounds' : IDL.Vec(RoundLog) });
  const TeamState = IDL.Record({
    'id' : IDL.Principal,
    'name' : IDL.Text,
    'score' : IDL.Int,
    'logoUrl' : IDL.Text,
    'positions' : TeamPositions,
  });
  const PlayerId__1 = IDL.Nat32;
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
  const Skills = IDL.Record({
    'battingAccuracy' : IDL.Int,
    'throwingAccuracy' : IDL.Int,
    'speed' : IDL.Int,
    'catching' : IDL.Int,
    'battingPower' : IDL.Int,
    'defense' : IDL.Int,
    'throwingPower' : IDL.Int,
  });
  const PlayerCondition = IDL.Variant({
    'ok' : IDL.Null,
    'dead' : IDL.Null,
    'injured' : Injury,
  });
  const PlayerStateWithId = IDL.Record({
    'id' : PlayerId__1,
    'name' : IDL.Text,
    'matchStats' : PlayerMatchStats,
    'teamId' : TeamId,
    'skills' : Skills,
    'condition' : PlayerCondition,
  });
  const BaseState = IDL.Record({
    'atBat' : PlayerId__1,
    'thirdBase' : IDL.Opt(PlayerId__1),
    'secondBase' : IDL.Opt(PlayerId__1),
    'firstBase' : IDL.Opt(PlayerId__1),
  });
  const InProgressMatch = IDL.Record({
    'log' : MatchLog,
    'team1' : TeamState,
    'team2' : TeamState,
    'aura' : MatchAura,
    'outs' : IDL.Nat,
    'offenseTeamId' : TeamId,
    'players' : IDL.Vec(PlayerStateWithId),
    'bases' : BaseState,
    'strikes' : IDL.Nat,
  });
  const TickResult = IDL.Variant({
    'completed' : CompletedTickResult,
    'inProgress' : InProgressMatch,
  });
  const MatchGroupWithId = IDL.Record({
    'id' : IDL.Nat,
    'tickTimerId' : IDL.Nat,
    'currentSeed' : IDL.Nat32,
    'matches' : IDL.Vec(TickResult),
  });
  const ResetTickTimerResult = IDL.Variant({
    'ok' : IDL.Null,
    'matchGroupNotFound' : IDL.Null,
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
  const StartMatchTeam = IDL.Record({
    'id' : IDL.Principal,
    'name' : IDL.Text,
    'logoUrl' : IDL.Text,
    'positions' : IDL.Record({
      'rightField' : PlayerWithId,
      'leftField' : PlayerWithId,
      'thirdBase' : PlayerWithId,
      'pitcher' : PlayerWithId,
      'secondBase' : PlayerWithId,
      'shortStop' : PlayerWithId,
      'centerField' : PlayerWithId,
      'firstBase' : PlayerWithId,
    }),
  });
  const StartMatchRequest = IDL.Record({
    'team1' : StartMatchTeam,
    'team2' : StartMatchTeam,
    'aura' : MatchAura,
  });
  const StartMatchGroupRequest = IDL.Record({
    'id' : IDL.Nat,
    'matches' : IDL.Vec(StartMatchRequest),
  });
  const StartMatchGroupResult = IDL.Variant({
    'ok' : IDL.Null,
    'noMatchesSpecified' : IDL.Null,
  });
  const TickMatchGroupResult = IDL.Variant({
    'completed' : IDL.Null,
    'matchGroupNotFound' : IDL.Null,
    'onStartCallbackError' : IDL.Variant({
      'notAuthorized' : IDL.Null,
      'notScheduledYet' : IDL.Null,
      'matchGroupNotFound' : IDL.Null,
      'alreadyStarted' : IDL.Null,
      'unknown' : IDL.Text,
    }),
    'inProgress' : IDL.Null,
  });
  const StadiumActor = IDL.Service({
    'cancelMatchGroup' : IDL.Func(
        [CancelMatchGroupRequest],
        [CancelMatchGroupResult],
        [],
      ),
    'getMatchGroup' : IDL.Func(
        [IDL.Nat],
        [IDL.Opt(MatchGroupWithId)],
        ['query'],
      ),
    'getMatchGroups' : IDL.Func([], [IDL.Vec(MatchGroupWithId)], ['query']),
    'resetTickTimer' : IDL.Func([IDL.Nat], [ResetTickTimerResult], []),
    'startMatchGroup' : IDL.Func(
        [StartMatchGroupRequest],
        [StartMatchGroupResult],
        [],
      ),
    'tickMatchGroup' : IDL.Func([IDL.Nat], [TickMatchGroupResult], []),
  });
  return StadiumActor;
};
export const init = ({ IDL }) => { return [IDL.Principal]; };