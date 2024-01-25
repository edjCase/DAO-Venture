import { IDL } from "@dfinity/candid";

export type Blessing =
    | { skill: null };
export const BlessingIdl = IDL.Variant({
    skill: IDL.Null
});