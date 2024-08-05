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

    export let workPlan: TownWorkPlan;
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
            "Gather Food",
            "Gather Wood",
            "Gather Stone",
            "Gather Gold",
            "Process Stone",
            "Process Wood",
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

<div class="w-64 h-64">
    <Pie
        bind:chart={chartRef}
        {data}
        options={{
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: {
                    display: true,
                    position: "right",
                },
                tooltip: {
                    callbacks: {
                        label: function (context) {
                            const label = context.label || "";
                            const value = context.parsed || 0;
                            const percentage = ((value / total) * 100).toFixed(
                                1,
                            );
                            return `${label}: ${percentage}% (${value})`;
                        },
                    },
                },
            },
        }}
    />
</div>
