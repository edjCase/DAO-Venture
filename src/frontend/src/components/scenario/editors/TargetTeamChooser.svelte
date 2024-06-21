<script lang="ts">
    import { Select } from "flowbite-svelte";
    import { TargetTeam } from "../../../ic-agent/declarations/league";
    import TargetTeamEditor from "./TargetTeamEditor.svelte";

    export let value: TargetTeam;

    let selected = Object.keys(value)[0];

    let items = [
        { value: "contextual", name: "Contextual" },
        { value: "chosen", name: "Chosen Team" },
        { value: "random", name: "Random Team" },
        { value: "all", name: "All Teams" },
    ];

    $: value = { [selected]: null } as TargetTeam;
</script>

<Select {items} bind:value={selected} />
<TargetTeamEditor bind:value />
