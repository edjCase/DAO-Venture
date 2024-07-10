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
    export let winLossRecords: Record<number, string>;

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
</script>

<div
    class="flex flex-col justify-around text-xs w-24 p-1 mx-2 border rounded gap-1"
>
    <div class="text-center">
        {#if "completed" in match}
            Completed
        {:else if "inProgress" in match}
            In Progress
        {:else}
            Upcoming
        {/if}
    </div>
    {#if team1 && team2}
        <MatchBannerTeam team={team1} winLossRecord={winLossRecords} />
        <MatchBannerTeam team={team2} winLossRecord={winLossRecords} />
    {/if}
</div>
