<script lang="ts">
    import { Select } from "flowbite-svelte";
    import type { ResourceKind } from "../../../ic-agent/declarations/main";
    import { getResourceIcon } from "../../../utils/ResourceUtil";

    export let value: ResourceKind;

    const kinds: ResourceKind[] = [
        { gold: null },
        { wood: null },
        { stone: null },
        { food: null },
    ];

    function selectKind(event: Event) {
        const target = event.target as HTMLSelectElement;
        const selectedIndex = target.selectedIndex - 1; // -1 because of the default option
        value = kinds[selectedIndex];
    }

    $: items = kinds.map((kind) => {
        return {
            value: Object.keys(kind)[0],
            name: getResourceIcon(kind),
        };
    });
</script>

<Select on:change={selectKind} {items} value={Object.keys(value)[0]} />
