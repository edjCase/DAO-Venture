import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';
import { createActor } from './actor';


export type Time = bigint;
export type TeamConfig = { 
  'pitcher' : number,
  'catcher' : number,
  'firstBase' : number,
  'secondBase' : number,
  'thirdBase' : number,
  'shortStop' : number,
  'leftField' : number,
  'centerField' : number,
  'rightField' : number,
  'battingOrder' : [number],
  'substitutes' : [number]
};
export type MatchTeamInfo = { 'id' : Principal, 'config' : [] | [TeamConfig] };
export type MatchInfo = { 'id' : number, teams : [MatchTeamInfo], 'time' : Time };
export interface _SERVICE {
  'getIncompleteMatches' : ActorMethod<[], [MatchInfo]>,
}



export const idlFactory = ({ IDL }) => {
  const TeamConfig = IDL.Record({ 
    'pitcher' : IDL.Nat32,
    'catcher' : IDL.Nat32,
    'firstBase' : IDL.Nat32,
    'secondBase' : IDL.Nat32,
    'thirdBase' : IDL.Nat32,
    'shortStop' : IDL.Nat32,
    'leftField' : IDL.Nat32,
    'centerField' : IDL.Nat32,
    'rightField' : IDL.Nat32,
    'battingOrder' : IDL.Vec(IDL.Nat32),
    'substitutes' : IDL.Vec(IDL.Nat32)
  });
  const MatchTeamInfo = IDL.Record({ 'id' : IDL.Principal, 'config' : IDL.Opt(TeamConfig) });
  const MatchInfo = IDL.Record({ 'id' : IDL.Nat32, teams : IDL.Vec(MatchTeamInfo), 'time' : IDL.Nat });
  return IDL.Service({
    'getIncompleteMatches' : IDL.Func([], [[MatchInfo]], ['query']),
  });
};
export const agentFactory = (canisterId : string | Principal) => createActor<_SERVICE>(canisterId, idlFactory, {});