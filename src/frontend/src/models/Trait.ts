import { IDL } from "@dfinity/candid";
import { Skill, SkillIdl } from "./Scenario";

export type Text = string;
export type Int = bigint;


export type Effect =
    | {
        skill: {
            skill: [Skill] | [];
            delta: Int;
        }
    };
export const EffectIdl = IDL.Variant({
    skill: IDL.Record({
        skill: IDL.Opt(SkillIdl),
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
