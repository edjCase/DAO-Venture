import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';
import { createActor } from './Actor';
import type { InterfaceFactory } from '@dfinity/candid/lib/cjs/idl';


export type TeamConfig = {
  'pitcher': number,
  'catcher': number,
  'firstBase': number,
  'secondBase': number,
  'thirdBase': number,
  'shortStop': number,
  'leftField': number,
  'centerField': number,
  'rightField': number,
  'battingOrder': number[],
  'substitutes': number[]
};
export type TeamConfigError = {
  'notOnTeam': number
} | {
  'usedInMultiplePositions': number
};
export type RegistrationResult = {
  'ok': null
} | {
  'invalidTeamConfig': TeamConfigError[]
} | {
  'matchAlreadyStarted': null
} | {
  'matchNotFound': null
} | {
  'teamNotInMatch': null
};
export interface _SERVICE {
  'registerForMatch': ActorMethod<[Principal, number, TeamConfig], RegistrationResult>,
}



export const idlFactory: InterfaceFactory = ({ IDL }) => {
  const TeamConfig = IDL.Record({
    'pitcher': IDL.Nat32,
    'catcher': IDL.Nat32,
    'firstBase': IDL.Nat32,
    'secondBase': IDL.Nat32,
    'thirdBase': IDL.Nat32,
    'shortStop': IDL.Nat32,
    'leftField': IDL.Nat32,
    'centerField': IDL.Nat32,
    'rightField': IDL.Nat32,
    'battingOrder': IDL.Vec(IDL.Nat32),
    'substitutes': IDL.Vec(IDL.Nat32)
  });
  const TeamConfigError = IDL.Variant({
    'notOnTeam': IDL.Nat32,
    'usedInMultiplePositions': IDL.Nat32
  });
  const RegistrationResult = IDL.Variant({
    'ok': IDL.Null,
    'invalidTeamConfig': IDL.Vec(TeamConfigError),
    'matchAlreadyStarted': IDL.Null,
    'matchNotFound': IDL.Null,
    'teamNotInMatch': IDL.Null
  });
  return IDL.Service({
    'registerForMatch': IDL.Func([IDL.Principal, IDL.Nat32, TeamConfig], [RegistrationResult], []),
  });
};
export const teamAgentFactory = (canisterId: string | Principal) => createActor<_SERVICE>(canisterId, idlFactory);