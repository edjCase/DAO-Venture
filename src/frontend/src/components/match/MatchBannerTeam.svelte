<script lang="ts">
    import { TeamOrUndetermined } from "../../models/Team";
    import TeamLogo from "../team/TeamLogo.svelte";

    export let team: TeamOrUndetermined;
    export let winLossRecord: Record<number, string>;
</script>

<div class="flex justify-around items-center">
    <TeamLogo {team} size="xxs" border={false} padding={false} />
    {#if "id" in team}
        <div>{winLossRecord[Number(team.id)] || "-"}</div>
    {:else if "winnerOfMatch" in team}
        <div>WoM {team.winnerOfMatch}</div>
    {:else}
        <div>
            Standing: {team.seasonStandingIndex + 1}
        </div>
    {/if}
</div>
