<script lang="ts">
    import WorkPlan from "../../../town/TownWorkPlan.svelte";
    import { townStore } from "../../../../stores/TownStore";
    import FormTemplate from "./FormTemplate.svelte";
    import {
        TownProposalContent,
        TownWorkPlan,
    } from "../../../../ic-agent/declarations/main";
    import WorkPlanJobSlider from "./WorkPlanJobSlider.svelte";
    import { Input, Label } from "flowbite-svelte";
    import { getResourceIcon } from "../../../../utils/ResourceUtil";

    export let townId: bigint;

    type Job = {
        name: string;
        key: string;
        weight: number;
        isLocked: boolean;
    };

    $: towns = $townStore;
    let workPlan: TownWorkPlan | undefined;
    let jobsOrUndefined: Job[] | undefined;
    let currentMaxWeight: number = 100;
    let processWoodMaxStorage: number = 0;
    let processStoneMaxStorage: number = 0;

    $: {
        if (workPlan === undefined) {
            workPlan = towns?.find((town) => town.id === townId)?.workPlan;
            if (workPlan !== undefined) {
                processStoneMaxStorage = Number(
                    workPlan.processStone.maxStorage,
                );
                processWoodMaxStorage = Number(workPlan.processWood.maxStorage);
                normalizeWeightsAndSet([
                    {
                        name: "Process" + getResourceIcon({ wood: null }),
                        key: "processWood",
                        weight: workPlan.processWood.weight,
                        isLocked: false,
                    },
                    {
                        name: "Process" + getResourceIcon({ stone: null }),
                        key: "processStone",
                        weight: workPlan.processStone.weight,
                        isLocked: false,
                    },
                    {
                        name: "Gather" + getResourceIcon({ food: null }),
                        key: "gatherFood",
                        weight: workPlan.gatherFood.weight,
                        isLocked: false,
                    },
                    {
                        name: "Gather" + getResourceIcon({ wood: null }),
                        key: "gatherWood",
                        weight: workPlan.gatherWood.weight,
                        isLocked: false,
                    },
                    {
                        name: "Gather" + getResourceIcon({ stone: null }),
                        key: "gatherStone",
                        weight: workPlan.gatherStone.weight,
                        isLocked: false,
                    },
                    {
                        name: "Gather" + getResourceIcon({ gold: null }),
                        key: "gatherGold",
                        weight: workPlan.gatherGold.weight,
                        isLocked: false,
                    },
                ]);
            }
        } else if (jobsOrUndefined !== undefined) {
            workPlan = {
                processWood: {
                    weight: jobsOrUndefined[0].weight,
                    maxStorage: BigInt(processWoodMaxStorage),
                },
                processStone: {
                    weight: jobsOrUndefined[1].weight,
                    maxStorage: BigInt(processStoneMaxStorage),
                },
                gatherFood: { weight: jobsOrUndefined[2].weight },
                gatherWood: { weight: jobsOrUndefined[3].weight },
                gatherStone: { weight: jobsOrUndefined[4].weight },
                gatherGold: { weight: jobsOrUndefined[5].weight },
            };
        }
    }

    function normalizeWeightsAndSet(jobs: Job[]) {
        const lockedTotal = jobs
            .filter((job) => job.isLocked)
            .reduce((sum, job) => sum + job.weight, 0);

        const remainingTotal = 100 - lockedTotal;
        const unlockedJobs = jobs.filter((job) => !job.isLocked);

        if (unlockedJobs.length === 0) return; // All sliders are locked

        const currentUnlockedTotal = unlockedJobs.reduce(
            (sum, job) => sum + job.weight,
            0,
        );

        if (currentUnlockedTotal <= 0) {
            const evenWeight = remainingTotal / unlockedJobs.length;
            unlockedJobs.forEach((job) => (job.weight = evenWeight));
        } else {
            const factor = remainingTotal / currentUnlockedTotal;
            unlockedJobs.forEach((job) => (job.weight *= factor));
        }
        currentMaxWeight = jobs
            .map((job) => job.weight)
            .reduce((max, weight) => Math.max(max, weight), 0);
        // currentMaxWeight = Math.min(currentMaxWeight + 15, 100);
        currentMaxWeight = remainingTotal;

        unlockedJobs.forEach(
            (job) => (job.weight = Math.ceil(job.weight * 10) / 10), // Round for display // TODO better way?
        );

        jobsOrUndefined = [...jobs]; // Trigger reactivity
    }

    function onChange(job: Job) {
        if (!job.isLocked) {
            normalizeWeightsAndSet(jobsOrUndefined!);
        }
    }

    function toggleLock(job: Job) {
        job.isLocked = !job.isLocked;
        jobsOrUndefined = [...jobsOrUndefined!]; // Trigger reactivity
    }

    function generateProposal(): TownProposalContent | string {
        if (workPlan === undefined) {
            return "Work plan not loaded yet";
        }
        return {
            updateWorkPlan: {
                workPlan: workPlan,
            },
        };
    }
</script>

{#if workPlan !== undefined && jobsOrUndefined !== undefined}
    <FormTemplate {generateProposal} {townId}>
        <WorkPlan {workPlan} />

        <div class="p-4 rounded-lg">
            <h2 class="text-xl font-bold mb-4">Work Plan Distribution</h2>
            {#each jobsOrUndefined as job}
                <WorkPlanJobSlider
                    name={job.name}
                    bind:weight={job.weight}
                    bind:isLocked={job.isLocked}
                    onChange={() => onChange(job)}
                    toggleLock={() => toggleLock(job)}
                    {currentMaxWeight}
                    maxWeight={100}
                />
            {/each}
            <Label>Process Stone Max Storage</Label>
            <Input
                type="number"
                bind:value={processStoneMaxStorage}
                class="w-16 mx-2 px-2 py-1 border rounded"
            />
            <Label>Process Wood Max Storage</Label>
            <Input
                type="number"
                bind:value={processWoodMaxStorage}
                class="w-16 mx-2 px-2 py-1 border rounded"
            />
        </div>
    </FormTemplate>
{/if}
