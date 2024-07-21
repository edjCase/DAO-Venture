<script lang="ts">
    import { Button, Input, Label } from "flowbite-svelte";
    import { NoWorldEffectScenarioRequest } from "../../../../ic-agent/declarations/main";
    import ScenarioEffectChooser from "../ScenarioEffectChooser.svelte";
    import TeqirementsEditor from "../RequirementsEditor.svelte";
    import { TrashBinSolid } from "flowbite-svelte-icons";
    import BigIntInput from "../BigIntInput.svelte";
    export let value: NoWorldEffectScenarioRequest;

    let addOption = () => {
        value.options.push({
            title: "Option " + (value.options.length + 1),
            description: "Option " + (value.options.length + 1),
            currencyCost: BigInt(0),
            townEffect: { noEffect: null },
            requirements: [],
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
        <Label>Currency Cost</Label>
        <BigIntInput bind:value={option.currencyCost} />
        <Label>Town Effect</Label>
        <ScenarioEffectChooser bind:value={option.townEffect} />
        <Label>Trait Requirements</Label>
        <TeqirementsEditor bind:value={option.requirements} />

        <button on:click={() => remove(i)}>
            <TrashBinSolid size="sm" />
        </button>
    {/each}
    <Button on:click={addOption}>Add Option</Button>
</div>
