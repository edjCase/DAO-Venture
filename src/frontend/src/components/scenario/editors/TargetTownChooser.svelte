<script lang="ts">
    import { Select } from "flowbite-svelte";
    import { TargetTown } from "../../../ic-agent/declarations/main";
    import TargetTownEditor from "./TargetTownEditor.svelte";

    export let value: TargetTown;

    let selected = Object.keys(value)[0];

    let items = [
        { value: "contextual", name: "Contextual" },
        { value: "chosen", name: "Chosen Town" },
        { value: "random", name: "Random Town" },
        { value: "all", name: "All Towns" },
    ];

    $: value = { [selected]: null } as TargetTown;
</script>

<Select {items} bind:value={selected} />
<TargetTownEditor bind:value />
