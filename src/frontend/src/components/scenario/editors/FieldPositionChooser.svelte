<script lang="ts">
    import { Select } from "flowbite-svelte";
    import { FieldPosition } from "../../../ic-agent/declarations/main";

    export let value: FieldPosition;

    let selected = Object.keys(value)[0];

    let items = [
        { value: "rightField", name: "Right Field" },
        { value: "centerField", name: "Center Field" },
        { value: "leftField", name: "Left Field" },
        { value: "firstBase", name: "First Base" },
        { value: "secondBase", name: "Second Base" },
        { value: "thirdBase", name: "Third Base" },
        { value: "shortStop", name: "Short Stop" },
        { value: "pitcher", name: "Pitcher" },
    ];

    $: value = { [selected]: null } as FieldPosition;
</script>

<Select {items} bind:value={selected} />
