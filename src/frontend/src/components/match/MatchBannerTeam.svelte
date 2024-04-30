<script lang="ts">
    import { TeamDetailsOrUndetermined } from "../../models/Match";
    import TeamLogo from "../team/TeamLogo.svelte";

    export let team: TeamDetailsOrUndetermined;
    export let winLossRecord: Record<number, string>;
</script>

<div class="flex justify-between items-center mt-1">
    <TeamLogo {team} size="xxs" border={false} padding={false} />
    {#if "id" in team}
        <div>{team.name.slice(0, 3)}</div>
        <div>{winLossRecord[Number(team.id)] || "(0-0)"}</div>
        <!-- <div>{team.score}</div> -->
    {:else if "winnerOfMatch" in team}
        <div>WoM {team.winnerOfMatch}</div>
    {:else}
        <div>
            Standing: {team.seasonStandingIndex + 1}
        </div>
    {/if}
</div>
