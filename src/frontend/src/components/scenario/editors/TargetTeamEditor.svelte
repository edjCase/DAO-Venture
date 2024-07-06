<script lang="ts">
    import { Select } from "flowbite-svelte";
    import { TargetTeam } from "../../../ic-agent/declarations/main";
    import { teamStore } from "../../../stores/TeamStore";

    export let value: TargetTeam;
    $: teams = $teamStore;
    $: teamItems =
        teams?.map((team) => ({ value: team.id, name: team.name })) ?? [];
</script>

{#if "random" in value}
    <div></div>
{:else if "chosen" in value}
    <Select items={teamItems} bind:value={value.chosen} />
{:else if "contextual" in value}
    <div></div>
{:else if "all" in value}
    <div></div>
{:else}
    NOT IMPLEMENTED : {JSON.stringify(value)}
{/if}
