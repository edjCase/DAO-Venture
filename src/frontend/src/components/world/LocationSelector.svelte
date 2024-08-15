<script lang="ts">
    import { Select, SelectOptionType } from "flowbite-svelte";
    import { gameStateStore } from "../../stores/GameStateStore";

    export let value: bigint;
    $: gameState = $gameStateStore;

    let locationItems: SelectOptionType<bigint>[] | undefined;
    $: if (gameState !== undefined) {
        locationItems = gameState.locations.map((location) => ({
            name: location.id.toString(),
            value: location.id,
        }));
    }
</script>

{#if locationItems !== undefined}
    <Select bind:value items={locationItems} />
{/if}
