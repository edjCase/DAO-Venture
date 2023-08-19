import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';

export interface Player { 'name' : string }
export interface PlayerCreationOptions {
  'name' : string,
  'teamId' : [] | [Principal],
}
export interface PlayerInfo { 'player' : Player, 'teamId' : [] | [Principal] }
export interface PlayerInfoWithId {
  'id' : number,
  'player' : Player,
  'teamId' : [] | [Principal],
}
export interface _SERVICE {
  'create' : ActorMethod<[PlayerCreationOptions], number>,
  'getAllPlayers' : ActorMethod<[], Array<PlayerInfoWithId>>,
  'getPlayer' : ActorMethod<
    [number],
    { 'ok' : PlayerInfo } |
      { 'notFound' : null }
  >,
  'getTeamPlayers' : ActorMethod<[[] | [Principal]], Array<PlayerInfoWithId>>,
  'setPlayerTeam' : ActorMethod<
    [number, [] | [Principal]],
    { 'ok' : null } |
      { 'playerNotFound' : null }
  >,
}
