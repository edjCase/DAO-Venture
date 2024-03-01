import { IDL } from "@dfinity/candid";

export type Skill =
    | { battingAccuracy: null }
    | { battingPower: null }
    | { throwingAccuracy: null }
    | { throwingPower: null }
    | { catching: null }
    | { defense: null }
    | { speed: null };
export const SkillIdl = IDL.Variant({
    battingAccuracy: IDL.Null,
    battingPower: IDL.Null,
    throwingAccuracy: IDL.Null,
    throwingPower: IDL.Null,
    catching: IDL.Null,
    defense: IDL.Null,
    speed: IDL.Null,
});
