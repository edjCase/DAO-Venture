<script lang="ts">
    import { Select, SelectOptionType } from "flowbite-svelte";
    import { worldStore } from "../../stores/WorldStore";

    export let value: bigint;
    $: world = $worldStore;

    let locationItems: SelectOptionType<bigint>[] | undefined;
    $: if (world !== undefined) {
        locationItems = world.locations.map((location) => ({
            name: location.id.toString(),
            value: location.id,
        }));
    }
</script>

{#if locationItems !== undefined}
    <Select bind:value items={locationItems} />
{/if}
