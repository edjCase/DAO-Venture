import { IDL } from "@dfinity/candid";

export type Base =
    | { firstBase: null }
    | { secondBase: null }
    | { thirdBase: null }
    | { homeBase: null };
export const BaseIdl = IDL.Variant({
    firstBase: IDL.Null,
    secondBase: IDL.Null,
    thirdBase: IDL.Null,
    homeBase: IDL.Null,
});

export enum BaseEnum {
    FirstBase = "First Base",
    SecondBase = "Second Base",
    ThirdBase = "Third Base",
    HomeBase = "Home Base",
}