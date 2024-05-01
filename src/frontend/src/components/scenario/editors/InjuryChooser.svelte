<script lang="ts">
    import { Select } from "flowbite-svelte";
    import { Injury } from "../../../ic-agent/declarations/league";

    export let value: Injury;

    let selected = Object.keys(value)[0];

    let items = [
        { value: "twistedAnkle", name: "Twisted Ankle" },
        { value: "brokenLeg", name: "Broken Leg" },
        { value: "brokenArm", name: "Broken Arm" },
        { value: "concussion", name: "Concussion" },
    ];

    $: value = { [selected]: null } as Injury;
</script>

<Select {items} bind:value={selected} />
