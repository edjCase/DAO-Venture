<script lang="ts">
    import { Label, Select } from "flowbite-svelte";
    import FormTemplate from "./FormTemplate.svelte";
    import {
        Job,
        TownProposalContent,
    } from "../../../../ic-agent/declarations/main";
    import ResourceKindChooser from "../../../scenario/editors/ResourceKindChooser.svelte";
    import { worldStore } from "../../../../stores/WorldStore";
    import BigIntInput from "../../../scenario/editors/BigIntInput.svelte";

    export let townId: bigint;
    export let job: Job;
    export let jobId: bigint | undefined;

    let generateProposal = (): TownProposalContent | string => {
        if (jobId === undefined) {
            return {
                addJob: {
                    job: job,
                },
            };
        }
        return {
            updateJob: {
                jobId: jobId,
                job: job,
            },
        };
    };

    let jobType: string = "gatherResource";

    $: jobTypes = [
        { name: "Gather Resource", value: "gatherResource" },
        { name: "Process Resource", value: "processResource" },
    ];

    $: world = $worldStore;

    $: locationItems = world?.locations.map((location) => ({
        name: location.id.toString(),
        value: location.id,
    }));

    let onTypeChange = (e: Event) => {
        jobType = (e.target as HTMLSelectElement).value;
        if (jobType === "gatherResource") {
            job = {
                gatherResource: {
                    locationId: 0n,
                    resource: { wood: null },
                    workerQuota: BigInt(100),
                },
            };
        } else if (jobType === "processResource") {
            job = {
                processResource: {
                    resource: { wood: null },
                    workerQuota: BigInt(100),
                },
            };
        }
    };
</script>

<FormTemplate {generateProposal} {townId}>
    <Select bind:value={jobType} items={jobTypes} on:change={onTypeChange} />
    {#if "gatherResource" in job}
        <Label>Location</Label>
        <Select
            bind:value={job.gatherResource.locationId}
            items={locationItems}
        />
        <Label>Resource</Label>
        <ResourceKindChooser bind:value={job.gatherResource.resource} />
        <Label>Worker Quota</Label>
        <BigIntInput bind:value={job.gatherResource.workerQuota} />
    {:else if jobType === "processResource"}
        <Label>Resource</Label>
        <ResourceKindChooser bind:value={job.processResource.resource} />
        <Label>Worker Quota</Label>
        <BigIntInput bind:value={job.processResource.workerQuota} />
    {/if}
</FormTemplate>
