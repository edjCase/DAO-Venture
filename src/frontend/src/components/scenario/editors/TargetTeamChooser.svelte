<script lang="ts">
    import { Select } from "flowbite-svelte";
    import { TargetTeam } from "../../../ic-agent/declarations/league";
    import TargetTeamEditor from "./TargetTeamEditor.svelte";

    export let value: TargetTeam;

    let selected = Object.keys(value)[0];

    let items = [
        { value: "choosingTeam", name: "Choosing Team" },
        { value: "chosen", name: "Chosen Team" },
        { value: "random", name: "Random Team" },
    ];

    $: value = { [selected]: null } as TargetTeam;
</script>

<Select {items} bind:value={selected} />
<TargetTeamEditor bind:value />
