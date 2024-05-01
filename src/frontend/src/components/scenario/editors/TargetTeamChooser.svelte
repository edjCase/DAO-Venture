<script lang="ts">
    import { Select } from "flowbite-svelte";
    import { TargetTeam } from "../../../ic-agent/declarations/league";

    export let value: TargetTeam;

    let selected = Object.keys(value)[0];

    let items = [{ value: "choosingTeam", name: "Choosing Team" }];

    $: value = { [selected]: null } as TargetTeam;
</script>

<Select {items} bind:value={selected} />
