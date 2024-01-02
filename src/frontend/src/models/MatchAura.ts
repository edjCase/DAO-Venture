import { IDL } from "@dfinity/candid";

export type Text = string;

export type MatchAura =
    | { lowGravity: null }
    | { explodingBalls: null }
    | { fastBallsHardHits: null }
    | { moreBlessingsAndCurses: null }
    | { moveBasesIn: null }
    | { doubleOrNothing: null }
    | { windy: null }
    | { rainy: null }
    | { foggy: null }
    | { extraStrike: null };
export const MatchAuraIdl = IDL.Variant({
    lowGravity: IDL.Null,
    explodingBalls: IDL.Null,
    fastBallsHardHits: IDL.Null,
    moreBlessingsAndCurses: IDL.Null,
    moveBasesIn: IDL.Null,
    doubleOrNothing: IDL.Null,
    windy: IDL.Null,
    rainy: IDL.Null,
    foggy: IDL.Null,
    extraStrike: IDL.Null,
});

export type MatchAuraMetaData = {
    name: Text;
    description: Text;
};
export const MatchAuraMetaDataIdl = IDL.Record({
    name: IDL.Text,
    description: IDL.Text,
});

export type MatchAuraWithMetaData = {
    aura: MatchAura;
} & MatchAuraMetaData;
export const MatchAuraWithMetaDataIdl = IDL.Record({
    name: IDL.Text,
    description: IDL.Text,
    aura: MatchAuraIdl,
});
