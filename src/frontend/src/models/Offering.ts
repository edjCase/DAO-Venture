import { IDL } from "@dfinity/candid";

export type Text = string;

export type Offering =
    | { shuffleAndBoost: null }
    | { offensive: null }
    | { defensive: null }
    | { hittersDebt: null }
    | { bubble: null }
    | { underdog: null }
    | { ragePitch: null }
    | { pious: null }
    | { confident: null }
    | { moraleFlywheel: null };
export const OfferingIdl = IDL.Variant({
    shuffleAndBoost: IDL.Null,
    offensive: IDL.Null,
    defensive: IDL.Null,
    hittersDebt: IDL.Null,
    bubble: IDL.Null,
    underdog: IDL.Null,
    ragePitch: IDL.Null,
    pious: IDL.Null,
    confident: IDL.Null,
    moraleFlywheel: IDL.Null
});

export type OfferingMetaData = {
    name: Text;
    description: Text;
};
export const OfferingMetaDataIdl = IDL.Record({
    name: IDL.Text,
    description: IDL.Text,
});

export type OfferingWithMetaData = {
    offering: Offering;
} & OfferingMetaData;
export const OfferingWithMetaDataIdl = IDL.Record({
    name: IDL.Text,
    description: IDL.Text,
    offering: OfferingIdl,
});
