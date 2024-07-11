<script lang="ts">
    import {
        CompletedMatch,
        InProgressMatch,
        NotScheduledMatch,
        ScheduledMatch,
        TeamAssignment,
    } from "../../ic-agent/declarations/main";
    import { TeamOrUndetermined } from "../../models/Team";
    import { teamStore } from "../../stores/TeamStore";
    import MatchBannerTeam from "./MatchBannerTeam.svelte";

    export let match:
        | { notScheduled: NotScheduledMatch }
        | { scheduled: ScheduledMatch }
        | { inProgress: InProgressMatch }
        | { completed: CompletedMatch };

    $: teams = $teamStore;

    let map = (team: TeamAssignment): TeamOrUndetermined | undefined => {
        if ("predetermined" in team) {
            let teamId = team.predetermined;
            return teams?.find((t) => t.id == teamId);
        }
        if ("winnerOfMatch" in team) {
            return { winnerOfMatch: Number(team.winnerOfMatch) };
        }
        return { seasonStandingIndex: Number(team.seasonStandingIndex) };
    };

    let team1: TeamOrUndetermined | undefined;
    let team2: TeamOrUndetermined | undefined;
    $: {
        if ("completed" in match) {
            team1 = teams?.find((t) => t.id == match.completed.team1.id);
            team2 = teams?.find((t) => t.id == match.completed.team2.id);
        } else if ("inProgress" in match) {
            team1 = teams?.find((t) => t.id == match.inProgress.team1.id);
            team2 = teams?.find((t) => t.id == match.inProgress.team2.id);
        } else if ("scheduled" in match) {
            team1 = teams?.find((t) => t.id == match.scheduled.team1.id);
            team2 = teams?.find((t) => t.id == match.scheduled.team2.id);
        } else {
            team1 = map(match.notScheduled.team1);
            team2 = map(match.notScheduled.team2);
        }
    }

    let team1Score: bigint | undefined;
    let team2Score: bigint | undefined;
    $: {
        if ("completed" in match) {
            team1Score = match.completed.team1.score;
            team2Score = match.completed.team2.score;
        } else {
            team1Score = undefined;
            team2Score = undefined;
        }
    }
</script>

{#if team1 && team2}
    <div class="flex flex-col items-center w-16 mr-2 bg-gray-700 rounded py-1">
        <MatchBannerTeam team={team1} score={team1Score} />
        <div class="mb-2"></div>
        <MatchBannerTeam team={team2} score={team2Score} />
    </div>
{/if}
