import { Team } from "../ic-agent/declarations/main";

export type TeamOrUndetermined =
    | Team
    | { winnerOfMatch: number }
    | { seasonStandingIndex: number };

