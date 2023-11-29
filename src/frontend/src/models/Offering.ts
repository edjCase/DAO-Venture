import { IDL } from "@dfinity/candid";

export type Text = string;

export type Offering =
    | { shuffleAndBoost: null };
export const OfferingIdl = IDL.Variant({
    shuffleAndBoost: IDL.Null,
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
