import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';
import { createActor } from './Actor';
import { identityStore } from '../stores/IdentityStore';
import { get } from 'svelte/store';

export type CreateStadiumResult = { 'ok': Principal };
export type CreateTeamResult = { 'ok': Principal } |
{ 'nameTaken': null };
export type ScheduleMatchResult = { 'ok': number } |
{ 'stadiumNotFound': null } |
{ 'timeNotAvailable': null };
export interface Stadium { 'id': Principal, 'name': string }
export interface Team { 'id': Principal, 'name': string, 'logoUrl': string }
export type Time = bigint;
export interface _SERVICE {
  'createStadium': ActorMethod<[string], CreateStadiumResult>,
  'createTeam': ActorMethod<[string, string], CreateTeamResult>,
  'getStadiums': ActorMethod<[], Array<Stadium>>,
  'getTeams': ActorMethod<[], Array<Team>>,
  'scheduleMatch': ActorMethod<
    [Principal, [Principal, Principal], Time],
    ScheduleMatchResult
  >,
  'updateLeagueCanisters': ActorMethod<[], undefined>,
}



export const idlFactory = ({ IDL }) => {
  const CreateStadiumResult = IDL.Variant({ 'ok': IDL.Principal });
  const CreateTeamResult = IDL.Variant({
    'ok': IDL.Principal,
    'nameTaken': IDL.Null,
  });
  const Stadium = IDL.Record({ 'id': IDL.Principal, 'name': IDL.Text });
  const Team = IDL.Record({ 'id': IDL.Principal, 'name': IDL.Text, 'logoUrl': IDL.Text });
  const Time = IDL.Int;
  const ScheduleMatchResult = IDL.Variant({
    'ok': IDL.Nat32,
    'duplicateTeams': IDL.Null,
    'timeNotAvailable': IDL.Null,
  });
  return IDL.Service({
    'createStadium': IDL.Func([IDL.Text], [CreateStadiumResult], []),
    'createTeam': IDL.Func([IDL.Text, IDL.Text], [CreateTeamResult], []),
    'getStadiums': IDL.Func([], [IDL.Vec(Stadium)], ['query']),
    'getTeams': IDL.Func([], [IDL.Vec(Team)], ['query']),
    'scheduleMatch': IDL.Func(
      [IDL.Principal, IDL.Tuple(IDL.Principal, IDL.Principal), Time],
      [ScheduleMatchResult],
      [],
    ),
    'updateLeagueCanisters': IDL.Func([], [], []),
  });
};


const canisterId = process.env.CANISTER_ID_LEAGUE;
// Keep factory due to changing identity
export let leagueAgentFactory = () => createActor<_SERVICE>(canisterId, idlFactory);

