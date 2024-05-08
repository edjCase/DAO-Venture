import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';
import type { IDL } from '@dfinity/candid';

export type AddMatchStatsError = { 'notAuthorized' : null };
export type AddMatchStatsResult = { 'ok' : null } |
  { 'err' : AddMatchStatsError };
export type ApplyEffectsError = { 'notAuthorized' : null };
export type ApplyEffectsRequest = Array<PlayerEffectOutcome>;
export type ApplyEffectsResult = { 'ok' : null } |
  { 'err' : ApplyEffectsError };
export type CreatePlayerFluffError = { 'notAuthorized' : null } |
  { 'invalid' : Array<InvalidError> };
export interface CreatePlayerFluffRequest {
  'title' : string,
  'name' : string,
  'description' : string,
  'likes' : Array<string>,
  'quirks' : Array<string>,
  'dislikes' : Array<string>,
}
export type CreatePlayerFluffResult = { 'ok' : null } |
  { 'err' : CreatePlayerFluffError };
export type Duration = { 'matches' : bigint } |
  { 'indefinite' : null };
export type FieldPosition = { 'rightField' : null } |
  { 'leftField' : null } |
  { 'thirdBase' : null } |
  { 'pitcher' : null } |
  { 'secondBase' : null } |
  { 'shortStop' : null } |
  { 'centerField' : null } |
  { 'firstBase' : null };
export type GetPlayerError = { 'notFound' : null };
export type GetPlayerResult = { 'ok' : Player } |
  { 'err' : GetPlayerError };
export type InvalidError = { 'nameTaken' : null } |
  { 'nameNotSpecified' : null };
export type OnSeasonEndError = { 'notAuthorized' : null };
export type OnSeasonEndResult = { 'ok' : null } |
  { 'err' : OnSeasonEndError };
export interface Player {
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
}
export type PlayerEffectOutcome = {
    'skill' : {
      'duration' : Duration,
      'skill' : Skill,
      'target' : TargetInstance,
      'delta' : bigint,
    }
  } |
  { 'injury' : { 'target' : TargetInstance } };
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
export type PopulateTeamRosterError = { 'missingFluff' : null } |
  { 'notAuthorized' : null };
export type PopulateTeamRosterResult = { 'ok' : Array<Player> } |
  { 'err' : PopulateTeamRosterError };
export type SetTeamsCanisterIdError = { 'notAuthorized' : null };
export type SetTeamsCanisterIdResult = { 'ok' : null } |
  { 'err' : SetTeamsCanisterIdError };
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
export type SwapPlayerPositionsError = { 'notAuthorized' : null };
export type SwapPlayerPositionsResult = { 'ok' : null } |
  { 'err' : SwapPlayerPositionsError };
export type TargetInstance = { 'teams' : Array<bigint> } |
  { 'league' : null } |
  { 'positions' : Array<TargetPositionInstance> };
export interface TargetPositionInstance {
  'teamId' : bigint,
  'position' : FieldPosition,
}
export interface _SERVICE {
  'addFluff' : ActorMethod<[CreatePlayerFluffRequest], CreatePlayerFluffResult>,
  'addMatchStats' : ActorMethod<
    [bigint, Array<PlayerMatchStatsWithId>],
    AddMatchStatsResult
  >,
  'applyEffects' : ActorMethod<[ApplyEffectsRequest], ApplyEffectsResult>,
  'getAllPlayers' : ActorMethod<[], Array<Player>>,
  'getPlayer' : ActorMethod<[number], GetPlayerResult>,
  'getTeamPlayers' : ActorMethod<[bigint], Array<Player>>,
  'onSeasonEnd' : ActorMethod<[], OnSeasonEndResult>,
  'populateTeamRoster' : ActorMethod<[bigint], PopulateTeamRosterResult>,
  'setTeamsCanisterId' : ActorMethod<[Principal], SetTeamsCanisterIdResult>,
  'swapTeamPositions' : ActorMethod<
    [bigint, FieldPosition, FieldPosition],
    SwapPlayerPositionsResult
  >,
}
export declare const idlFactory: IDL.InterfaceFactory;
export declare const init: (args: { IDL: typeof IDL }) => IDL.Type[];
