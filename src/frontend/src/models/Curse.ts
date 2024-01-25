import { IDL } from "@dfinity/candid";

export type Curse =
    | { skill: null }
    | { injury: null };
export const CurseIdl = IDL.Variant({
    skill: IDL.Null,
    injury: IDL.Null,
});