<script lang="ts">
    import { Select, SelectOptionType } from "flowbite-svelte";
    import { worldStore } from "../../stores/WorldStore";
    import { WorldLocation } from "../../ic-agent/declarations/main";

    export let value: bigint;
    export let kind: "unexplored" | "explored" | "all";
    $: world = $worldStore;

    let locationItems: SelectOptionType<bigint>[] | undefined;
    $: if (world !== undefined) {
        let filter: (location: WorldLocation) => boolean;
        if (kind === "unexplored") {
            filter = (location) => "unexplored" in location.kind;
        } else if (kind === "explored") {
            filter = (location) => !("unexplored" in location.kind);
        } else {
            filter = (_) => true;
        }
        locationItems = world.locations.filter(filter).map((location) => ({
            name: location.id.toString(),
            value: location.id,
        }));
    }
</script>

{#if locationItems !== undefined}
    <Select bind:value items={locationItems} />
{/if}
