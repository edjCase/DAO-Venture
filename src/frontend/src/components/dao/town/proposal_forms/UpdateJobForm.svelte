<script lang="ts">
    import { Job } from "../../../../ic-agent/declarations/main";
    import AddUpdateJobForm from "./AddUpdateJobForm.svelte";
    import JobSelector from "./JobSelector.svelte";

    export let townId: bigint;
    let job: Job | undefined;
    let jobId: bigint = 0n;

    let onJobSelect = (newJobId: bigint, newJob: Job) => {
        job = newJob;
        jobId = newJobId;
    };
</script>

<JobSelector {townId} bind:value={jobId} {onJobSelect} />
{#if job !== undefined}
    <AddUpdateJobForm {job} {jobId} {townId} />
{/if}
