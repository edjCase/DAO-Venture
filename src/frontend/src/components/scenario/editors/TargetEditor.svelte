<script lang="ts">
    import { Button } from "flowbite-svelte";
    import { Target } from "../../../ic-agent/declarations/league";
    import TargetPositionEditor from "./TargetPositionEditor.svelte";
    import TargetTeamChooser from "./TargetTeamChooser.svelte";
    import { TrashBinSolid } from "flowbite-svelte-icons";

    export let value: Target;

    let add = () => {
        if ("teams" in value) {
            value.teams.push({ choosingTeam: null });
            value.teams = value.teams;
        } else if ("positions" in value) {
            value.positions.push({
                team: { choosingTeam: null },
                position: { centerField: null },
            });
            value.positions = value.positions;
        }
    };
    let remove = (i: number) => {
        if ("teams" in value) {
            value.teams.splice(i, 1);
            value.teams = value.teams;
        } else if ("positions" in value) {
            value.positions.splice(i, 1);
            value.positions = value.positions;
        }
    };
</script>

{#if "teams" in value}
    <div class="ml-4">
        {#each value.teams as team, i}
            <div class="flex">
                <TargetTeamChooser bind:value={team} />
                <button on:click={() => remove(i)}>
                    <TrashBinSolid size="sm" />
                </button>
            </div>
        {/each}
    </div>
    <Button on:click={add}>Add</Button>
{:else if "league" in value}
    <div></div>
{:else if "positions" in value}
    <div class="ml-4">
        {#each value.positions as position, i}
            <div class="flex">
                <TargetPositionEditor bind:value={position} />
                <button on:click={() => remove(i)}>
                    <TrashBinSolid size="sm" />
                </button>
            </div>
        {/each}
    </div>
    <Button on:click={add}>Add</Button>
{:else}
    NOT IMPLEMENTED : {JSON.stringify(value)}
{/if}
