<script lang="ts">
    import { Select } from "flowbite-svelte";
    import { Skill } from "../../../ic-agent/declarations/main";

    export let value: Skill;

    let selected = Object.keys(value)[0];

    let items = [
        { value: "speed", name: "Speed" },
        { value: "catching", name: "Catching" },
        { value: "defense", name: "Defense" },
        { value: "battingAccuracy", name: "Batting Accuracy" },
        { value: "battingPower", name: "Batting Power" },
        { value: "throwingAccuracy", name: "Throwing Accuracy" },
        { value: "throwingPower", name: "Throwing Power" },
    ];

    $: value = { [selected]: null } as Skill;
</script>

<Select {items} bind:value={selected} />
