<script lang="ts">
    import { teamStore } from "../../stores/TeamStore";
    import TeamLogo from "./TeamLogo.svelte";

    export let positionIndex: number;
    export let teamId: bigint;
    export let wins: bigint;
    export let losses: bigint;

    $: teams = $teamStore;
    $: team = teams?.find((team) => team.id == teamId);
</script>

{#if team !== undefined}
    <div class="flex flex-row items-center m-1">
        <span class="w-8 mr-2 flex justify-center">{positionIndex + 1}</span>
        <TeamLogo {team} size="sm" />
        <span class="mr-2 w-32">{team.name}</span>
        <span class="font-bold">{wins} - {losses}</span>
    </div>
{/if}
