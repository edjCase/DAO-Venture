<script lang="ts">
    import { Button, Input, Label } from "flowbite-svelte";
    import ScenarioEffectChooser from "./ScenarioEffectChooser.svelte";
    import ScenarioKindChooser from "./ScenarioKindChooser.svelte";
    import { AddScenarioRequest } from "../../../ic-agent/declarations/league";
    import {
        dateToNanoseconds,
        nanosecondsToDate,
    } from "../../../utils/DateUtils";

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
</script>

<Label>Title</Label>
<Input type="text" bind:value={value.title} />
<Label>Description</Label>
<Input type="text" bind:value={value.description} />
<hr />
<Label>Type</Label>
<ScenarioKindChooser bind:value={value.kind} />

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
