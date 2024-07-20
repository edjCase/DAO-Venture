import { Town } from "../ic-agent/declarations/main";

export type TownOrUndetermined =
    | Town
    | { winnerOfMatch: number }
    | { seasonStandingIndex: number };

