import { IDL } from "@dfinity/candid";
import { Principal } from "@dfinity/principal";

type Text = string;

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
    id: Principal;
    name: Text;
    logoUrl: Text;
    motto: Text;
    description: Text;
};
export const TeamIdl = IDL.Record({
    id: IDL.Principal,
    name: IDL.Text,
    logoUrl: IDL.Text,
    motto: IDL.Text,
    description: IDL.Text,
});
