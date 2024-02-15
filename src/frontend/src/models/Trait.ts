import { IDL } from "@dfinity/candid";
import { PlayerSkills, PlayerSkillsIdl } from "../models/Player";

export type Text = string;
export type Int = number;

export type Skill = PlayerSkills;
export const SkillIdl = PlayerSkillsIdl;

export type Effect =
    | {
        skill: Skill;
        delta: Int;
    };
export const EffectIdl = IDL.Variant({
    skill: IDL.Record({
        skill: SkillIdl,
        delta: IDL.Int,
    }),
});

export type Trait = {
    id: Text;
    name: Text;
    description: Text;
    effects: Effect[];
};
export const TraitIdl = IDL.Record({
    id: IDL.Text,
    name: IDL.Text,
    description: IDL.Text,
    effects: IDL.Vec(EffectIdl),
});
