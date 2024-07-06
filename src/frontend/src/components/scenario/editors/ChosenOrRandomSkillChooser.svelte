<script lang="ts">
    import { Select } from "flowbite-svelte";
    import {
        ChosenOrRandomSkill,
        Skill,
    } from "../../../ic-agent/declarations/main";
    import SkillChooser from "./SkillChooser.svelte";

    export let value: ChosenOrRandomSkill;

    let skill: Skill = { speed: null };

    $: selectedType = Object.keys(value)[0];
    let onChange = (e: Event) => {
        selectedType = (e.target as HTMLSelectElement).value;
        if (selectedType === "random") {
            value = {
                random: null,
            };
        } else if (selectedType === "chosen") {
            value = {
                chosen: skill,
            };
        } else {
            throw new Error(`Unknown effect type: ${selectedType}`);
        }
    };

    const types = [
        {
            name: "Random",
            value: "random",
        },
        {
            name: "Chosen",
            value: "chosen",
        },
    ];
</script>

<Select items={types} on:change={onChange} value={selectedType} />
{#if selectedType === "chosen"}
    <SkillChooser bind:value={skill} />
{/if}
