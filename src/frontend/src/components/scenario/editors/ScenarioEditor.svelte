<script lang="ts">
    import { Button, Input, Label } from "flowbite-svelte";
    import BigIntInput from "./BigIntInput.svelte";
    import ScenarioEffectChooser from "./ScenarioEffectChooser.svelte";
    import MetaEffectChooser from "./MetaEffectChooser.svelte";
    import { AddScenarioRequest } from "../../../ic-agent/declarations/league";
    import {
        dateToNanoseconds,
        nanosecondsToDate,
    } from "../../../utils/DateUtils";
    import { TrashBinSolid } from "flowbite-svelte-icons";
    import TraitRequirementEditor from "./TraitRequirementEditor.svelte";

    export let value: AddScenarioRequest;

    let formatDateTimeLocal = (date: Date) => {
        let year = date.getFullYear();
        let month = (date.getMonth() + 1).toString().padStart(2, "0");
        let day = date.getDate().toString().padStart(2, "0");
        let hours = date.getHours().toString().padStart(2, "0");
        let minutes = date.getMinutes().toString().padStart(2, "0");
        return `${year}-${month}-${day}T${hours}:${minutes}`;
    };

    let startTime = value.startTime[0]
        ? formatDateTimeLocal(nanosecondsToDate(value.startTime[0]))
        : undefined;
    let endTime = formatDateTimeLocal(nanosecondsToDate(value.endTime));

    $: value.startTime = startTime
        ? [dateToNanoseconds(new Date(startTime))]
        : [];
    $: value.endTime = dateToNanoseconds(new Date(endTime));

    let addOption = () => {
        console.log("Adding option");
        value.options.push({
            title: "",
            description: "",
            energyCost: BigInt(0),
            traitRequirements: [],
            effect: {
                noEffect: null,
            },
        });
        value.options = value.options;
    };
    let deleteOption = (index: number) => {
        value.options.splice(index, 1);
        value.options = value.options;
    };
</script>

<Label>Title</Label>
<Input type="text" bind:value={value.title} />
<Label>Description</Label>
<Input type="text" bind:value={value.description} />
<hr />
<Label>Meta Effect</Label>
<MetaEffectChooser bind:value={value.metaEffect} />

<hr />
<Label>Options</Label>
<div class="ml-6 mb-4">
    {#each value.options as option, i}
        <div class="border rounded p-1 mb-1">
            <div>
                Option {i + 1}
                <button class="float-right" on:click={() => deleteOption(i)}>
                    <TrashBinSolid size="sm" />
                </button>
            </div>
            <Label>Title</Label>
            <Input type="text" bind:value={option.title} />
            <Label>Description</Label>
            <Input type="text" bind:value={option.description} />
            <Label>Energy Cost</Label>
            <BigIntInput bind:value={option.energyCost} />
            <Label>Trait Requirements</Label>
            <div class="ml-4">
                {#each option.traitRequirements as traitRequirement}
                    <TraitRequirementEditor bind:value={traitRequirement} />
                    <button
                        on:click={() => {
                            option.traitRequirements =
                                option.traitRequirements.slice(i, 1);
                        }}
                    >
                        <TrashBinSolid size="sm" />
                    </button>
                {/each}
                <Button
                    on:click={() => {
                        option.traitRequirements = [
                            ...option.traitRequirements,
                            {
                                id: "",
                                kind: { required: null },
                            },
                        ];
                    }}
                >
                    Add Requirement
                </Button>
            </div>
            <Label>Effect</Label>
            <div class="ml-4">
                <ScenarioEffectChooser bind:value={option.effect} />
            </div>
        </div>
    {/each}
    <Button on:click={addOption}>Add Option</Button>
</div>
<hr />

<Label>Undecided Effect</Label>
<ScenarioEffectChooser bind:value={value.undecidedEffect} />
<hr />

{#if !startTime}
    <Button on:click={() => (startTime = formatDateTimeLocal(new Date()))}>
        Delay Start
    </Button>
{:else}
    <Label>Start Time</Label>
    <Input type="datetime-local" bind:value={startTime} />
{/if}

<Label>End Time</Label>
<Input type="datetime-local" bind:value={endTime} />
