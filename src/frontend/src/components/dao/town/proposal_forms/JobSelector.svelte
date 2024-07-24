<script lang="ts">
    import { Select } from "flowbite-svelte";
    import { townStore } from "../../../../stores/TownStore";
    import { Job } from "../../../../ic-agent/declarations/main";
    import { buildJobDescription } from "../../../../utils/ResourceUtil";

    export let townId: bigint;
    export let value: bigint;
    export let onJobSelect: (jobId: bigint, job: Job) => void;

    let previousJobId: bigint | undefined;

    $: towns = $townStore;

    $: currentJobs = towns
        ?.find((t) => t.id == townId)
        ?.jobs.map((job, i) => ({
            name: buildJobDescription(job),
            value: BigInt(i),
        }));

    $: {
        if (previousJobId !== value) {
            previousJobId = value;
            let job = towns?.find((t) => t.id == townId)?.jobs[Number(value)];
            if (job !== undefined) {
                onJobSelect(value, job);
            }
        }
    }
</script>

{#if currentJobs === undefined || currentJobs.length === 0}
    <div class="text-center text-xl">No town jobs</div>
{:else}
    <Select bind:value items={currentJobs} />
{/if}
