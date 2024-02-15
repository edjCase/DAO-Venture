import { IDL } from "@dfinity/candid";
import { Principal } from "@dfinity/principal";

export type Text = string;


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
})


export type ScenarioTeamIndex = number;
export type ScenarioPlayerIndex = number;

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
    players: IDL.Vec(IDL.Nat),
})

export type Duration =
    | { 'indefinite': null }
    | { 'matches': number };
export const DurationIdl = IDL.Variant({
    indefinite: IDL.Null,
    matches: IDL.Nat,
})

export type Effect =
    | { 'trait': { target: Target; traitId: string; duration: Duration } }
    | { 'entropy': { team: Team; delta: number } }
    | { 'oneOf': [number, Effect][] }
    | { 'allOf': Effect[] }
    | { 'noEffect': null };
export const EffectIdl = IDL.Rec();
EffectIdl.fill(IDL.Variant({
    trait: IDL.Record({ target: TargetIdl, traitId: IDL.Text, duration: DurationIdl }),
    entropy: IDL.Record({ team: TeamIdl, delta: IDL.Nat }),
    oneOf: IDL.Tuple(IDL.Nat, IDL.Vec(EffectIdl)),
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
    | { 'entropy': { teamId: Principal; delta: number } };
export const EffectOutcomeIdl = IDL.Variant({
    trait: TraitEffectOutcomeIdl,
    entropy: IDL.Record({ teamId: IDL.Principal, delta: IDL.Nat }),
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
}
export const ScenarioTemplateIdl = IDL.Record({
    id: IDL.Text,
    title: IDL.Text,
    description: IDL.Text,
    options: IDL.Vec(ScenarioOptionIdl),
    otherTeams: IDL.Vec(ScenarioTeamIdl),
    players: IDL.Vec(ScenarioPlayerIdl)
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
    playerIds: IDL.Vec(IDL.Nat)
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
    choice: IDL.Nat,
    effectOutcomes: IDL.Vec(EffectOutcomeIdl)
});
