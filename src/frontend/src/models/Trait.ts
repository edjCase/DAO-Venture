import { IDL } from "@dfinity/candid";

export type Trait =
    | { latePerfomer: null }
    | { unstable: null }
    | { jackOfAllTrades: null }
    | { prepared: null }
    | { pious: null }
    | { juggernaut: null }
    | { sensitive: null }
    | { puddleJumper: null }
    | { powerHitter: null }
    | { inspiring: null }
    | { madeOfGlass: null };
export const TraitIdl = IDL.Variant({
    latePerfomer: IDL.Null,
    unstable: IDL.Null,
    jackOfAllTrades: IDL.Null,
    prepared: IDL.Null,
    pious: IDL.Null,
    juggernaut: IDL.Null,
    sensitive: IDL.Null,
    puddleJumper: IDL.Null,
    powerHitter: IDL.Null,
    inspiring: IDL.Null,
    madeOfGlass: IDL.Null,
});