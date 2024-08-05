<script lang="ts">
    import { Pie } from "svelte-chartjs";
    import {
        Chart as ChartJS,
        Title,
        Tooltip,
        Legend,
        ArcElement,
        CategoryScale,
        ChartData,
    } from "chart.js";
    import { TownWorkPlan } from "../../ic-agent/declarations/main";
    import { onMount } from "svelte";
    import { getResourceIcon } from "../../utils/ResourceUtil";
    import ResourceIcon from "../icons/ResourceIcon.svelte";

    export let workPlan: TownWorkPlan;
    export let legend: boolean = false;
    let weights: number[] = [];
    let total: number = 0;
    let chartRef: ChartJS<"pie", number[], string>;

    function updateChartData(
        wp: TownWorkPlan,
        chartRef: ChartJS<"pie", number[], string>,
    ) {
        weights = [
            Number(wp.gatherFood.weight),
            Number(wp.gatherWood.weight),
            Number(wp.gatherStone.weight),
            Number(wp.gatherGold.weight),
            Number(wp.processStone.weight),
            Number(wp.processWood.weight),
        ];
        total = weights.reduce((a, b) => a + b, 0);

        chartRef.data.datasets[0].data = weights;
        chartRef.update();
    }

    $: if (chartRef) {
        updateChartData(workPlan, chartRef);
    }

    const data: ChartData<"pie", number[], string> = {
        labels: [
            "Gather " + getResourceIcon({ food: null }),
            "Gather " + getResourceIcon({ wood: null }),
            "Gather " + getResourceIcon({ stone: null }),
            "Gather " + getResourceIcon({ gold: null }),
            "Process " + getResourceIcon({ stone: null }),
            "Process " + getResourceIcon({ wood: null }),
        ],
        datasets: [
            {
                data: [],
                backgroundColor: [
                    "#F7464A",
                    "#46BFBD",
                    "#FDB45C",
                    "#949FB1",
                    "#4D5360",
                    "#AC64AD",
                ],
                hoverBackgroundColor: [
                    "#FF5A5E",
                    "#5AD3D1",
                    "#FFC870",
                    "#A8B3C5",
                    "#616774",
                    "#A77BBB",
                ],
            },
        ],
    };

    ChartJS.register(Title, Tooltip, Legend, ArcElement, CategoryScale);

    onMount(() => {
        updateChartData(workPlan, chartRef);
    });
</script>

<div class="flex flex-col items-center">
    <div class="w-64 h-64">
        <Pie
            bind:chart={chartRef}
            {data}
            options={{
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        display: false,
                        position: "right",
                    },
                },
            }}
        />
    </div>
    {#if legend}
        <div
            class="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-2 gap-2 text-xl text-center mt-4"
        >
            <div class="border rounded p-2">
                Gather <ResourceIcon kind={{ food: null }} />: {workPlan
                    .gatherFood.weight}
            </div>
            <div class="border rounded p-2">
                Gather <ResourceIcon kind={{ wood: null }} />: {workPlan
                    .gatherWood.weight}
            </div>
            <div class="border rounded p-2">
                Gather <ResourceIcon kind={{ stone: null }} />: {workPlan
                    .gatherStone.weight}
            </div>
            <div class="border rounded p-2">
                Gather <ResourceIcon kind={{ gold: null }} />: {workPlan
                    .gatherGold.weight}
            </div>
            <div class="border rounded p-2">
                Process <ResourceIcon kind={{ stone: null }} />: {workPlan
                    .processStone.weight}
            </div>
            <div class="border rounded p-2">
                Process <ResourceIcon kind={{ wood: null }} />: {workPlan
                    .processWood.weight}
            </div>
        </div>
    {/if}
</div>
