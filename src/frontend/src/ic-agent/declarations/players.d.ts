import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';
import type { IDL } from '@dfinity/candid';

export interface AddTraitRequest {
  'id' : string,
  'effects' : Array<Effect>,
  'name' : string,
  'description' : string,
}
export type AddTraitResult = { 'ok' : null } |
  { 'idTaken' : null };
export type ApplyEffectsRequest = Array<PlayerEffectOutcome>;
export type ApplyEffectsResult = { 'ok' : null };
export interface CreatePlayerFluffRequest {
  'title' : string,
  'name' : string,
  'description' : string,
  'likes' : Array<string>,
  'quirks' : Array<string>,
  'dislikes' : Array<string>,
}
export type CreatePlayerFluffResult = { 'created' : null } |
  { 'invalid' : Array<InvalidError> };
export type Duration = { 'matches' : bigint } |
  { 'indefinite' : null };
export type Effect = { 'skill' : { 'skill' : [] | [Skill], 'delta' : bigint } };
export type FieldPosition = { 'rightField' : null } |
  { 'leftField' : null } |
  { 'thirdBase' : null } |
  { 'pitcher' : null } |
  { 'secondBase' : null } |
  { 'shortStop' : null } |
  { 'centerField' : null } |
  { 'firstBase' : null };
export type GetPlayerResult = { 'ok' : Player } |
  { 'notFound' : null };
export type Injury = { 'twistedAnkle' : null } |
  { 'brokenArm' : null } |
  { 'brokenLeg' : null } |
  { 'concussion' : null };
export type InvalidError = { 'nameTaken' : null } |
  { 'nameNotSpecified' : null };
export type OnSeasonEndResult = { 'ok' : null } |
  { 'notAuthorized' : null };
export interface Player {
  'title' : string,
  'name' : string,
  'description' : string,
  'likes' : Array<string>,
  'teamId' : bigint,
  'position' : FieldPosition,
  'quirks' : Array<string>,
  'dislikes' : Array<string>,
  'skills' : Skills,
  'traitIds' : Array<string>,
}
export type PlayerEffectOutcome = {
    'skill' : {
      'duration' : Duration,
      'skill' : Skill,
      'target' : TargetInstance,
      'delta' : bigint,
    }
  } |
  { 'injury' : { 'target' : TargetInstance, 'injury' : Injury } };
export type PlayerId = number;
export interface PlayerMatchStatsWithId {
  'playerId' : PlayerId,
  'battingStats' : {
    'homeRuns' : bigint,
    'hits' : bigint,
    'runs' : bigint,
    'strikeouts' : bigint,
    'atBats' : bigint,
  },
  'injuries' : bigint,
  'pitchingStats' : {
    'homeRuns' : bigint,
    'pitches' : bigint,
    'hits' : bigint,
    'runs' : bigint,
    'strikeouts' : bigint,
    'strikes' : bigint,
  },
  'catchingStats' : {
    'missedCatches' : bigint,
    'throwOuts' : bigint,
    'throws' : bigint,
    'successfulCatches' : bigint,
  },
}
export interface PlayerWithId {
  'id' : number,
  'title' : string,
  'name' : string,
  'description' : string,
  'likes' : Array<string>,
  'teamId' : bigint,
  'position' : FieldPosition,
  'quirks' : Array<string>,
  'dislikes' : Array<string>,
  'skills' : Skills,
  'traitIds' : Array<string>,
}
export interface PlayerWithId__1 {
  'id' : number,
  'title' : string,
  'name' : string,
  'description' : string,
  'likes' : Array<string>,
  'teamId' : bigint,
  'position' : FieldPosition,
  'quirks' : Array<string>,
  'dislikes' : Array<string>,
  'skills' : Skills,
  'traitIds' : Array<string>,
}
export type PopulateTeamRosterResult = { 'ok' : Array<PlayerWithId> } |
  { 'notAuthorized' : null } |
  { 'noMorePlayers' : null };
export type Skill = { 'battingAccuracy' : null } |
  { 'throwingAccuracy' : null } |
  { 'speed' : null } |
  { 'catching' : null } |
  { 'battingPower' : null } |
  { 'defense' : null } |
  { 'throwingPower' : null };
export interface Skills {
  'battingAccuracy' : bigint,
  'throwingAccuracy' : bigint,
  'speed' : bigint,
  'catching' : bigint,
  'battingPower' : bigint,
  'defense' : bigint,
  'throwingPower' : bigint,
}
export type TargetInstance = { 'teams' : Array<bigint> } |
  { 'league' : null } |
  { 'positions' : Array<TargetPositionInstance> };
export interface TargetPositionInstance {
  'teamId' : bigint,
  'position' : FieldPosition,
}
export interface Trait {
  'id' : string,
  'effects' : Array<Effect>,
  'name' : string,
  'description' : string,
}
export interface _SERVICE {
  'addMatchStats' : ActorMethod<
    [bigint, Array<PlayerMatchStatsWithId>],
    undefined
  >,
  'addTrait' : ActorMethod<[AddTraitRequest], AddTraitResult>,
  'applyEffects' : ActorMethod<[ApplyEffectsRequest], ApplyEffectsResult>,
  'clearPlayers' : ActorMethod<[], undefined>,
  'clearTraits' : ActorMethod<[], undefined>,
  'createFluff' : ActorMethod<
    [CreatePlayerFluffRequest],
    CreatePlayerFluffResult
  >,
  'getAllPlayers' : ActorMethod<[], Array<PlayerWithId__1>>,
  'getPlayer' : ActorMethod<[number], GetPlayerResult>,
  'getTeamPlayers' : ActorMethod<[bigint], Array<PlayerWithId>>,
  'getTraits' : ActorMethod<[], Array<Trait>>,
  'onSeasonEnd' : ActorMethod<[], OnSeasonEndResult>,
  'populateTeamRoster' : ActorMethod<[bigint], PopulateTeamRosterResult>,
}
export declare const idlFactory: IDL.InterfaceFactory;
export declare const init: (args: { IDL: typeof IDL }) => IDL.Type[];
