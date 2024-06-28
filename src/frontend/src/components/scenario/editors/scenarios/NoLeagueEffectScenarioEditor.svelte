<script lang="ts">
    import { Button, Input, Label } from "flowbite-svelte";
    import { NoLeagueEffectScenarioRequest } from "../../../../ic-agent/declarations/league";
    import ScenarioEffectChooser from "../ScenarioEffectChooser.svelte";
    import TraitRequirementsEditor from "../TraitRequirementsEditor.svelte";
    import { TrashBinSolid } from "flowbite-svelte-icons";
    import BigIntInput from "../BigIntInput.svelte";
    export let value: NoLeagueEffectScenarioRequest;

    let addOption = () => {
        value.options.push({
            title: "Option " + (value.options.length + 1),
            description: "Option " + (value.options.length + 1),
            energyCost: BigInt(0),
            teamEffect: { noEffect: null },
            traitRequirements: [],
        });
        value.options = value.options; // Trigger reactivity
    };

    let remove = (i: number) => {
        value.options.splice(i, 1);
        value.options = value.options; // Trigger reactivity
    };
</script>

<div class="ml-4">
    {#each value.options as option, i}
        <Label>Option {i + 1}</Label>
        <Label>Title</Label>
        <Input type="text" bind:value={option.title} />
        <Label>Description</Label>
        <Input type="text" bind:value={option.description} />
        <Label>Energy Cost</Label>
        <BigIntInput bind:value={option.energyCost} />
        <Label>Team Effect</Label>
        <ScenarioEffectChooser bind:value={option.teamEffect} />
        <Label>Trait Requirements</Label>
        <TraitRequirementsEditor bind:value={option.traitRequirements} />

        <button on:click={() => remove(i)}>
            <TrashBinSolid size="sm" />
        </button>
    {/each}
    <Button on:click={addOption}>Add Option</Button>
</div>
