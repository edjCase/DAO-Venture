import { IDL } from "@dfinity/candid";
import { Principal } from "@dfinity/principal";
import { Trait, TraitIdl } from "./Trait";
import { MatchAura, MatchAuraIdl } from "./MatchAura";

export type Text = string;


export type Skill =
    | { battingAccuracy: null }
    | { battingPower: null }
    | { throwingAccuracy: null }
    | { throwingPower: null }
    | { catching: null }
    | { defense: null }
    | { piety: null }
    | { speed: null };

export const SkillIdl = IDL.Variant({
    battingAccuracy: IDL.Null,
    battingPower: IDL.Null,
    throwingAccuracy: IDL.Null,
    throwingPower: IDL.Null,
    catching: IDL.Null,
    defense: IDL.Null,
    piety: IDL.Null,
    speed: IDL.Null,
})


export type Effect =
    | {
        'skill': {
            'target': {
                'team': Principal;
                'player': number;
            };
            'skill': Skill;
            'value': number;
            'permanent': boolean;
        }
    }
    | {
        'trait': {
            'target': {
                'team': Principal;
                'player': number;
            };
            'trait': Trait;
            'permanent': boolean;
        }
    }
    | {
        'aura': {
            'matchGroup': number;
            'match': number;
            'aura': MatchAura;
        }
    }
    | {
        'points': number;
    };
export const EffectIdl = IDL.Variant({
    skill: IDL.Record({
        target: IDL.Record({ team: IDL.Principal, player: IDL.Nat32 }),
        skill: SkillIdl,
        value: IDL.Int,
        permanent: IDL.Bool,
    }),
    trait: IDL.Record({
        target: IDL.Record({ team: IDL.Principal, player: IDL.Nat32 }),
        trait: TraitIdl,
        permanent: IDL.Bool,
    }),
    aura: IDL.Record({
        matchGroup: IDL.Nat32,
        match: IDL.Nat32,
        aura: MatchAuraIdl,
    }),
    points: IDL.Int,
});

export type ScenarioOption = {
    name: Text;
    description: Text;
    entropy: number;
    effects: [Effect];
};
export const ScenarioOptionIdl = IDL.Record({
    name: IDL.Text,
    description: IDL.Text,
    entropy: IDL.Int,
    effects: IDL.Vec(EffectIdl),
});

export type Scenario = {
    id: number;
    name: Text;
    description: Text;
    options: [ScenarioOption];
};
export const ScenarioIdl = IDL.Record({
    id: IDL.Nat32,
    name: IDL.Text,
    description: IDL.Text,
    options: IDL.Vec(ScenarioOptionIdl),
});
