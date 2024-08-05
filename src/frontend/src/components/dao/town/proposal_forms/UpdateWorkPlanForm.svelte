<script lang="ts">
    import { Input } from "flowbite-svelte";
    import WorkPlan from "../../../town/TownWorkPlan.svelte";
    import { townStore } from "../../../../stores/TownStore";

    export let townId: bigint;

    type Job = {
        name: string;
        key: string;
        weight: bigint;
        isLocked: boolean;
    };

    $: towns = $townStore;
    $: workPlan = towns?.find((town) => town.id === townId)?.workPlan;

    let currentMaxWeight: bigint = 100n;

    let jobs: Job[] | undefined;
    // Initialize jobs and weights
    $: if (workPlan !== undefined) {
        jobs = [
            {
                name: "Process Wood",
                key: "processWood",
                weight: workPlan.processWood.weight,
                isLocked: false,
            },
            {
                name: "Process Stone",
                key: "processStone",
                weight: workPlan.processStone.weight,
                isLocked: false,
            },
            {
                name: "Gather Food",
                key: "gatherFood",
                weight: workPlan.gatherFood.weight,
                isLocked: false,
            },
            {
                name: "Gather Wood",
                key: "gatherWood",
                weight: workPlan.gatherWood.weight,
                isLocked: false,
            },
            {
                name: "Gather Stone",
                key: "gatherStone",
                weight: workPlan.gatherStone.weight,
                isLocked: false,
            },
            {
                name: "Gather Gold",
                key: "gatherGold",
                weight: workPlan.gatherGold.weight,
                isLocked: false,
            },
        ];

        normalizeWeights(jobs);
    }

    function normalizeWeights(jobs: Job[]) {
        const lockedTotal = jobs
            .filter((job) => job.isLocked)
            .reduce((sum, job) => sum + job.weight, 0n);

        const total = 100n; // TODO?
        const remainingTotal = total - lockedTotal;
        const unlockedJobs = jobs.filter((job) => !job.isLocked);

        if (unlockedJobs.length === 0) return; // All sliders are locked

        const currentUnlockedTotal = unlockedJobs.reduce(
            (sum, job) => sum + job.weight,
            0n,
        );

        if (currentUnlockedTotal === 0n) {
            const evenWeight = remainingTotal / BigInt(unlockedJobs.length);
            unlockedJobs.forEach((job) => (job.weight = evenWeight));
        } else {
            const factor = remainingTotal / currentUnlockedTotal;
            unlockedJobs.forEach((job) => (job.weight *= factor));
        }

        jobs = [...jobs]; // Trigger reactivity
        currentMaxWeight = jobs
            .map((job) => job.weight)
            .reduce((a, b) => BigInt(Math.max(Number(a), Number(b))));
    }

    function handleSliderChange(job: Job) {
        if (!job.isLocked) {
            normalizeWeights(jobs!);
        }
    }

    function handleManualInput(job: Job) {
        if (!job.isLocked) {
            normalizeWeights(jobs!);
        }
    }

    function toggleLock(job: Job) {
        job.isLocked = !job.isLocked;
        jobs = [...jobs!]; // Trigger reactivity
        normalizeWeights(jobs!);
    }
</script>

{#if workPlan !== undefined && jobs !== undefined}
    <WorkPlan {workPlan} />

    <div class="p-4 rounded-lg">
        <h2 class="text-xl font-bold mb-4">Work Plan Distribution</h2>
        {#each jobs as job}
            <div class="mb-4 flex items-center">
                <label for={job.key} class="block text-sm font-medium w-1/4">
                    {job.name}:
                </label>
                <input
                    type="range"
                    id={job.key}
                    bind:value={job.weight}
                    min="0"
                    max="100"
                    step="0.5"
                    on:input={() => handleSliderChange(job)}
                    class="w-1/2 h-2 rounded-lg appearance-none cursor-pointer"
                    disabled={job.isLocked}
                />
                <Input
                    type="number"
                    bind:value={job.weight}
                    on:input={() => handleManualInput(job)}
                    min="0"
                    max={currentMaxWeight}
                    step="0.5"
                    class="w-16 mx-2 px-2 py-1 border rounded"
                />
                <button
                    on:click={() => toggleLock(job)}
                    class={`px-2 py-1 rounded ${job.isLocked ? "bg-red-500 text-white" : "bg-gray-700"}`}
                >
                    {job.isLocked ? "Unlock" : "Lock"}
                </button>
            </div>
        {/each}
    </div>
{/if}
