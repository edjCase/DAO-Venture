<script lang="ts">
    import { MatchDetails } from "../../models/Match";
    import { mapTeamOrUndetermined } from "../../models/Team";
    import { teamStore } from "../../stores/TeamStore";
    import MatchBannerTeam from "./MatchBannerTeam.svelte";

    export let match: MatchDetails;
    export let winLossRecords: Record<number, string>;

    $: teams = $teamStore;

    $: team1 = teams ? mapTeamOrUndetermined(match.team1, teams) : undefined;
    $: team2 = teams ? mapTeamOrUndetermined(match.team2, teams) : undefined;
</script>

<div
    class="flex flex-col justify-around text-xs w-24 p-1 mx-2 border rounded gap-1"
>
    <div class="text-center">
        {#if match.state == "Played"}
            Completed
        {:else if match.state == "InProgress"}
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
