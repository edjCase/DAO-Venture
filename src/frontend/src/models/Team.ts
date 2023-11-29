import { IDL } from "@dfinity/candid";
import { Principal } from "@dfinity/principal";

export type TeamId =
    | { team1: null }
    | { team2: null };
export const TeamIdIdl = IDL.Variant({
    team1: IDL.Null,
    team2: IDL.Null,
});

export type TeamIdOrBoth = TeamId | { bothTeams: null };
export const TeamIdOrBothIdl = IDL.Variant({
    team1: IDL.Null,
    team2: IDL.Null,
    bothTeams: IDL.Null,
});

export type TeamIdOrTie = TeamId | { tie: null };
export const TeamIdOrTieIdl = IDL.Variant({
    team1: IDL.Null,
    team2: IDL.Null,
    tie: IDL.Null,
});

export type Team = {
    name: Text;
    logoUrl: Text;
    ledgerId: Principal;
};
export const TeamIdl = IDL.Record({
    name: IDL.Text,
    logoUrl: IDL.Text,
    ledgerId: IDL.Principal,
});

export type TeamWithId = Team & {
    id: Principal;
};
export const TeamWithIdIdl = IDL.Record({
    name: IDL.Text,
    logoUrl: IDL.Text,
    ledgerId: IDL.Principal,
    id: IDL.Principal,
});