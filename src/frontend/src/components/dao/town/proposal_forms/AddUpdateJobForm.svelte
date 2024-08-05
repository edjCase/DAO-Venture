<script lang="ts">
    import { Label, Select } from "flowbite-svelte";
    import FormTemplate from "./FormTemplate.svelte";
    import {
        Job,
        TownProposalContent,
    } from "../../../../ic-agent/declarations/main";
    import { toJsonString } from "../../../../utils/StringUtil";
    import LocationSelector from "../../../world/LocationSelector.svelte";

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

    $: jobTypes = [{ name: "Explore", value: "explore" }];

    let onTypeChange = (e: Event) => {
        jobType = (e.target as HTMLSelectElement).value;
        if (jobType === "explore") {
            job = {
                explore: {
                    locationId: 0n,
                },
            };
        } else {
            throw new Error("Invalid job type: " + jobType);
        }
    };
</script>

<FormTemplate {generateProposal} {townId}>
    <Select bind:value={jobType} items={jobTypes} on:change={onTypeChange} />
    {#if "explore" in job}
        <Label>Location</Label>
        <LocationSelector
            bind:value={job.explore.locationId}
            kind="unexplored"
        />
    {:else}
        NOT IMPLEMENTED JOB TYPE {toJsonString(job)}
    {/if}
</FormTemplate>
