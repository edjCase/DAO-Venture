import { Team } from "../ic-agent/declarations/main";
import { TeamDetailsOrUndetermined } from "./Match";

export type TeamOrUndetermined =
    | Team
    | { winnerOfMatch: number }
    | { seasonStandingIndex: number };


export let mapTeamOrUndetermined = function (
    team: TeamDetailsOrUndetermined,
    teams: Team[]
): TeamOrUndetermined {
    if ("id" in team) {
        return teams.find((t) => t.id == team.id)!;
    }
    return team;
};