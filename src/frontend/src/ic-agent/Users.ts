import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';
import { createActor } from './Actor';
import { InterfaceFactory } from '@dfinity/candid/lib/cjs/idl';
import { IDL } from "@dfinity/candid";

export type FieldPosition = { 'firstBase': null }
    | { 'secondBase': null }
    | { 'thirdBase': null }
    | { 'pitcher': null }
    | { 'shortStop': null }
    | { 'leftField': null }
    | { 'centerField': null }
    | { 'rightField': null };
export const FieldPositionIdl = IDL.Variant({
    'firstBase': IDL.Null,
    'secondBase': IDL.Null,
    'thirdBase': IDL.Null,
    'pitcher': IDL.Null,
    'shortStop': IDL.Null,
    'leftField': IDL.Null,
    'centerField': IDL.Null,
    'rightField': IDL.Null,
});


export type PlayerSkills = {
    'battingAccuracy': number,
    'battingPower': number,
    'catching': number,
    'defense': number,
    'piety': number,
    'speed': number,
    'throwingAccuracy': number,
    'throwingPower': number
};
export const PlayerSkillsIdl = IDL.Record({
    'battingAccuracy': IDL.Int,
    'battingPower': IDL.Int,
    'catching': IDL.Int,
    'defense': IDL.Int,
    'piety': IDL.Int,
    'speed': IDL.Int,
    'throwingAccuracy': IDL.Int,
    'throwingPower': IDL.Int
});


export interface CreatePlayerFluffRequest {
    'name': string,
    'title': string,
    'description': string;
    'quirks': string[];
    'likes': string[];
    'dislikes': string[];
};
export const CreatePlayerFluffRequestIdl = IDL.Record({
    'name': IDL.Text,
    'title': IDL.Text,
    'description': IDL.Text,
    'quirks': IDL.Vec(IDL.Text),
    'likes': IDL.Vec(IDL.Text),
    'dislikes': IDL.Vec(IDL.Text),
});


export type Player = {
    id: number;
    name: string;
    title: string;
    description: string;
    quirks: string[];
    likes: string[];
    dislikes: string[];
    teamId: [Principal] | [];
    skills: PlayerSkills;
    position: FieldPosition;
};
export const PlayerIdl = IDL.Record({
    id: IDL.Nat32,
    name: IDL.Text,
    title: IDL.Text,
    description: IDL.Text,
    quirks: IDL.Vec(IDL.Text),
    likes: IDL.Vec(IDL.Text),
    dislikes: IDL.Vec(IDL.Text),
    teamId: IDL.Opt(IDL.Principal),
    skills: PlayerSkillsIdl,
    position: FieldPositionIdl
});


export type GetPlayerResult =
    { 'ok': Player }
    | { 'notFound': null };
export const GetPlayerResultIdl = IDL.Variant({
    'ok': PlayerIdl,
    'notFound': IDL.Null
});

export type SetPlayerTeamResult = {
    'ok': null
} | {
    'playerNotFound': null
};
export const SetPlayerTeamResultIdl = IDL.Variant({
    'ok': IDL.Null,
    'playerNotFound': IDL.Null
});

export type InvalidError = { 'nameTaken': null }
    | { 'nameNotSpecified': null };
const InvalidErrorIdl = IDL.Variant({
    'nameTaken': IDL.Null,
    'nameNotSpecified': IDL.Null,
});


export type CreatePlayerFluffResult =
    { 'created': null }
    | { 'invalid': InvalidError[] };
export const CreatePlayerFluffResultIdl = IDL.Variant({
    'created': IDL.Null,
    'invalid': IDL.Vec(InvalidErrorIdl)
});



export type User = {
    favoriteTeamId: [Principal] | [];
    points: number;
};
export const UserIdl = IDL.Record({
    favoriteTeamId: IDL.Opt(IDL.Principal),
    points: IDL.Int
});

export type GetUserResult =
    | { 'ok': User }
    | { 'notFound': null }
    | { 'notAuthorized': null };
export const GetUserResultIdl = IDL.Variant({
    'ok': UserIdl,
    'notFound': IDL.Null,
    'notAuthorized': IDL.Null
});

export type SetFavoriteTeamResult =
    | { ok: null }
    | { notAuthorized: null }
    | { identityRequired: null }
    | { teamNotFound: null }
    | { favoriteTeamAlreadySet: null };
export const SetFavoriteTeamResultIdl = IDL.Variant({
    ok: IDL.Null,
    notAuthorized: IDL.Null,
    identityRequired: IDL.Null,
    teamNotFound: IDL.Null,
    favoriteTeamAlreadySet: IDL.Null,
});






export interface _SERVICE {
    'get': ActorMethod<[Principal], GetUserResult>,
    'setFavoriteTeam': ActorMethod<[Principal], SetFavoriteTeamResult>;
}


export const idlFactory: InterfaceFactory = ({ IDL }) => {
    return IDL.Service({
        'get': IDL.Func([IDL.Principal], [GetUserResultIdl], ['query']),
        'setFavoriteTeam': IDL.Func([IDL.Principal], [SetFavoriteTeamResultIdl], []),
    });
};
const canisterId = process.env.CANISTER_ID_USERS || "";
// Keep factory due to changing identity
export const usersAgentFactory = () => createActor<_SERVICE>(canisterId, idlFactory);
