export const idlFactory = ({ IDL }) => {
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
  const Skill = IDL.Variant({
    'battingAccuracy' : IDL.Null,
    'throwingAccuracy' : IDL.Null,
    'speed' : IDL.Null,
    'catching' : IDL.Null,
    'battingPower' : IDL.Null,
    'defense' : IDL.Null,
    'throwingPower' : IDL.Null,
  });
  const Effect = IDL.Variant({
    'skill' : IDL.Record({ 'skill' : IDL.Opt(Skill), 'delta' : IDL.Int }),
  });
  const AddTraitRequest = IDL.Record({
    'id' : IDL.Text,
    'effects' : IDL.Vec(Effect),
    'name' : IDL.Text,
    'description' : IDL.Text,
  });
  const AddTraitResult = IDL.Variant({ 'ok' : IDL.Null, 'idTaken' : IDL.Null });
  const Duration = IDL.Variant({
    'matches' : IDL.Nat,
    'indefinite' : IDL.Null,
  });
  const TargetInstance = IDL.Variant({
    'teams' : IDL.Vec(IDL.Nat),
    'players' : IDL.Vec(IDL.Nat32),
    'league' : IDL.Null,
  });
  const Injury = IDL.Variant({
    'twistedAnkle' : IDL.Null,
    'brokenArm' : IDL.Null,
    'brokenLeg' : IDL.Null,
    'concussion' : IDL.Null,
  });
  const PlayerEffectOutcome = IDL.Variant({
    'skill' : IDL.Record({
      'duration' : Duration,
      'skill' : Skill,
      'target' : TargetInstance,
      'delta' : IDL.Int,
    }),
    'injury' : IDL.Record({ 'target' : TargetInstance, 'injury' : Injury }),
  });
  const ApplyEffectsRequest = IDL.Vec(PlayerEffectOutcome);
  const ApplyEffectsResult = IDL.Variant({ 'ok' : IDL.Null });
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
  const CreatePlayerFluffResult = IDL.Variant({
    'created' : IDL.Null,
    'invalid' : IDL.Vec(InvalidError),
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
  const PlayerWithId__1 = IDL.Record({
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
    'traitIds' : IDL.Vec(IDL.Text),
  });
  const Player = IDL.Record({
    'title' : IDL.Text,
    'name' : IDL.Text,
    'description' : IDL.Text,
    'likes' : IDL.Vec(IDL.Text),
    'teamId' : IDL.Nat,
    'position' : FieldPosition,
    'quirks' : IDL.Vec(IDL.Text),
    'dislikes' : IDL.Vec(IDL.Text),
    'skills' : Skills,
    'traitIds' : IDL.Vec(IDL.Text),
  });
  const GetPlayerResult = IDL.Variant({ 'ok' : Player, 'notFound' : IDL.Null });
  const PlayerWithId = IDL.Record({
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
    'traitIds' : IDL.Vec(IDL.Text),
  });
  const Trait = IDL.Record({
    'id' : IDL.Text,
    'effects' : IDL.Vec(Effect),
    'name' : IDL.Text,
    'description' : IDL.Text,
  });
  const OnSeasonCompleteResult = IDL.Variant({
    'ok' : IDL.Null,
    'notAuthorized' : IDL.Null,
  });
  const PopulateTeamRosterResult = IDL.Variant({
    'ok' : IDL.Vec(PlayerWithId),
    'notAuthorized' : IDL.Null,
    'noMorePlayers' : IDL.Null,
  });
  return IDL.Service({
    'addMatchStats' : IDL.Func(
        [IDL.Nat, IDL.Vec(PlayerMatchStatsWithId)],
        [],
        [],
      ),
    'addTrait' : IDL.Func([AddTraitRequest], [AddTraitResult], []),
    'applyEffects' : IDL.Func([ApplyEffectsRequest], [ApplyEffectsResult], []),
    'clearPlayers' : IDL.Func([], [], []),
    'clearTraits' : IDL.Func([], [], []),
    'createFluff' : IDL.Func(
        [CreatePlayerFluffRequest],
        [CreatePlayerFluffResult],
        [],
      ),
    'getAllPlayers' : IDL.Func([], [IDL.Vec(PlayerWithId__1)], ['query']),
    'getPlayer' : IDL.Func([IDL.Nat32], [GetPlayerResult], ['query']),
    'getTeamPlayers' : IDL.Func([IDL.Nat], [IDL.Vec(PlayerWithId)], ['query']),
    'getTraits' : IDL.Func([], [IDL.Vec(Trait)], ['query']),
    'onSeasonComplete' : IDL.Func([], [OnSeasonCompleteResult], []),
    'populateTeamRoster' : IDL.Func([IDL.Nat], [PopulateTeamRosterResult], []),
  });
};
export const init = ({ IDL }) => { return []; };
