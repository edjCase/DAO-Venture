import { IDL } from "@dfinity/candid";
import { Principal } from "@dfinity/principal";
import { Injury, InjuryIdl } from "./Player";

export type Text = string;
export type ScenarioTeamIndex = bigint;
export type ScenarioPlayerIndex = bigint;


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

export type OtherTeam =
    | { 'opposingTeam': null }
    | { 'otherTeam': ScenarioTeamIndex };
export const OtherTeamIdl = IDL.Variant({
    opposingTeam: IDL.Null,
    otherTeam: IDL.Nat,
})

export type Team = OtherTeam | { 'scenarioTeam': null };
export const TeamIdl = IDL.Variant({
    opposingTeam: IDL.Null,
    otherTeam: IDL.Nat,
    scenarioTeam: IDL.Null,
})

export type Target =
    | { 'league': null }
    | { 'teams': Team[] }
    | { 'players': ScenarioPlayerIndex[] };
export const TargetIdl = IDL.Variant({
    league: IDL.Null,
    teams: IDL.Vec(TeamIdl),
    players: IDL.Vec(IDL.Nat),
})

export type TargetInstance =
    | { 'league': null }
    | { 'teams': Principal[] }
    | { 'players': number[] };
export const TargetInstanceIdl = IDL.Variant({
    league: IDL.Null,
    teams: IDL.Vec(IDL.Principal),
    players: IDL.Vec(IDL.Nat32),
})

export type Duration =
    | { 'indefinite': null }
    | { 'matches': bigint };
export const DurationIdl = IDL.Variant({
    indefinite: IDL.Null,
    matches: IDL.Nat,
})

export type Effect =
    | { 'trait': { target: Target; traitId: string; duration: Duration } }
    | { 'removeTrait': { target: Target; traitId: string } }
    | { 'injury': { target: Target; injury: Injury } }
    | { 'entropy': { team: Team; delta: bigint } }
    | { 'oneOf': [bigint, Effect][] }
    | { 'allOf': Effect[] }
    | { 'noEffect': null };
export const EffectIdl = IDL.Rec();
EffectIdl.fill(IDL.Variant({
    trait: IDL.Record({ target: TargetIdl, traitId: IDL.Text, duration: DurationIdl }),
    removeTrait: IDL.Record({ target: TargetIdl, traitId: IDL.Text }),
    injury: IDL.Record({ target: TargetIdl, injury: InjuryIdl }),
    entropy: IDL.Record({ team: TeamIdl, delta: IDL.Int }),
    oneOf: IDL.Vec(IDL.Tuple(IDL.Nat, EffectIdl)),
    allOf: IDL.Vec(EffectIdl),
    noEffect: IDL.Null,
}))

export type TraitEffectOutcome = {
    target: TargetInstance;
    traitId: string;
    duration: Duration;
};
export const TraitEffectOutcomeIdl = IDL.Record({
    target: TargetInstanceIdl,
    traitId: IDL.Text,
    duration: DurationIdl
});

export type EffectOutcome =
    | { 'trait': TraitEffectOutcome }
    | { 'entropy': { teamId: Principal; delta: bigint } };
export const EffectOutcomeIdl = IDL.Variant({
    trait: TraitEffectOutcomeIdl,
    entropy: IDL.Record({ teamId: IDL.Principal, delta: IDL.Int }),
})

export interface ScenarioTeam {
    // empty to be filled in later for weights/requirements
}
export const ScenarioTeamIdl = IDL.Record({});

export interface ScenarioPlayer {
    team: Team;
}
export const ScenarioPlayerIdl = IDL.Record({
    team: TeamIdl
});

export interface ScenarioOption {
    title: string;
    description: string;
    effect: Effect;
}
export const ScenarioOptionIdl = IDL.Record({
    title: IDL.Text,
    description: IDL.Text,
    effect: EffectIdl
});

export interface ScenarioTemplate {
    id: string;
    title: string;
    description: string;
    options: ScenarioOption[];
    otherTeams: ScenarioTeam[];
    players: ScenarioPlayer[];
    effect: Effect;
}
export const ScenarioTemplateIdl = IDL.Record({
    id: IDL.Text,
    title: IDL.Text,
    description: IDL.Text,
    options: IDL.Vec(ScenarioOptionIdl),
    otherTeams: IDL.Vec(ScenarioTeamIdl),
    players: IDL.Vec(ScenarioPlayerIdl),
    effect: EffectIdl
});

export interface ScenarioInstance {
    template: ScenarioTemplate;
    teamId: Principal;
    opposingTeamId: Principal;
    otherTeamIds: Principal[];
    playerIds: number[];
}
export const ScenarioInstanceIdl = IDL.Record({
    template: ScenarioTemplateIdl,
    teamId: IDL.Principal,
    opposingTeamId: IDL.Principal,
    otherTeamIds: IDL.Vec(IDL.Principal),
    playerIds: IDL.Vec(IDL.Nat32)
});

export interface ScenarioInstanceWithChoice extends ScenarioInstance {
    choice: number;
    effectOutcomes: EffectOutcome[];
}
export const ScenarioInstanceWithChoiceIdl = IDL.Record({
    template: ScenarioTemplateIdl,
    teamId: IDL.Principal,
    opposingTeamId: IDL.Principal,
    otherTeamIds: IDL.Vec(IDL.Principal),
    playerIds: IDL.Vec(IDL.Nat),
    choice: IDL.Nat8,
    effectOutcomes: IDL.Vec(EffectOutcomeIdl)
});
