<script lang="ts">
    import { onMount } from "svelte";
    import { mainAgentFactory } from "../../ic-agent/Main";
    import { DaySnapshot } from "../../ic-agent/declarations/main";
    import { Line } from "svelte-chartjs";
    import {
        Chart as ChartJS,
        Title,
        Tooltip,
        Legend,
        LineElement,
        LinearScale,
        PointElement,
        CategoryScale,
        ChartData,
    } from "chart.js";
    import LoadingButton from "../common/LoadingButton.svelte";

    ChartJS.register(
        Title,
        Tooltip,
        Legend,
        LineElement,
        LinearScale,
        PointElement,
        CategoryScale,
    );

    export let townId: bigint;

    let history: DaySnapshot[] | undefined;
    let data: ChartData<"line", number[]> | undefined;

    let buildDataFromHistory = (
        history: DaySnapshot[],
    ): ChartData<"line", number[]> => {
        return {
            labels: history.map((snapshot) => Number(snapshot.day)),
            datasets: [
                {
                    label: "Gather Gold Units",
                    data: history.map((snapshot) =>
                        Number(snapshot.work.gatherGold.units),
                    ),
                    borderColor: "rgb(255, 99, 132)",
                    fill: false,
                },
                {
                    label: "Gather Gold Workers",
                    data: history.map((snapshot) =>
                        Number(snapshot.work.gatherGold.workers),
                    ),
                    borderColor: "rgb(255, 159, 64)",
                    fill: false,
                },
                {
                    label: "Gather Food Units",
                    data: history.map((snapshot) =>
                        Number(snapshot.work.gatherFood.units),
                    ),
                    borderColor: "rgb(54, 162, 235)",
                    fill: false,
                },
                {
                    label: "Gather Food Workers",
                    data: history.map((snapshot) =>
                        Number(snapshot.work.gatherFood.workers),
                    ),
                    borderColor: "rgb(75, 192, 192)",
                    fill: false,
                },
                {
                    label: "Gather Wood Units",
                    data: history.map((snapshot) =>
                        Number(snapshot.work.gatherWood.units),
                    ),
                    borderColor: "rgb(75, 192, 192)",
                    fill: false,
                },
                {
                    label: "Gather Wood Workers",
                    data: history.map((snapshot) =>
                        Number(snapshot.work.gatherWood.workers),
                    ),
                    borderColor: "rgb(153, 102, 255)",
                    fill: false,
                },
                {
                    label: "Gather Stone Units",
                    data: history.map((snapshot) =>
                        Number(snapshot.work.gatherStone.units),
                    ),
                    borderColor: "rgb(255, 205, 86)",
                    fill: false,
                },
                {
                    label: "Gather Stone Workers",
                    data: history.map((snapshot) =>
                        Number(snapshot.work.gatherStone.workers),
                    ),
                    borderColor: "rgb(201, 203, 207)",
                    fill: false,
                },
                {
                    label: "Process Stone Units",
                    data: history.map((snapshot) =>
                        Number(snapshot.work.processStone.units),
                    ),
                    borderColor: "rgb(153, 102, 255)",
                    fill: false,
                },
                {
                    label: "Process Stone Workers",
                    data: history.map((snapshot) =>
                        Number(snapshot.work.processStone.workers),
                    ),
                    borderColor: "rgb(255, 205, 86)",
                    fill: false,
                },
                {
                    label: "Process Wood Units",
                    data: history.map((snapshot) =>
                        Number(snapshot.work.processWood.units),
                    ),
                    borderColor: "rgb(201, 203, 207)",
                    fill: false,
                },
                {
                    label: "Process Wood Workers",
                    data: history.map((snapshot) =>
                        Number(snapshot.work.processWood.workers),
                    ),
                    borderColor: "rgb(255, 99, 132)",
                    fill: false,
                },
            ],
        };
    };

    let refreshHistory = async () => {
        let mainAgent = await mainAgentFactory();
        let result = await mainAgent.getTownHistory(
            townId,
            BigInt(7),
            BigInt(0),
        );
        if ("ok" in result) {
            history = result.ok.data;
            data = buildDataFromHistory(history);
        } else {
            console.log("Error getting town history", result);
        }
    };

    onMount(refreshHistory);
</script>

{#if history && data}
    <div class="h-96">
        <LoadingButton onClick={refreshHistory}>Refresh</LoadingButton>
        <Line
            {data}
            options={{
                responsive: true,
                maintainAspectRatio: false,
                scales: {
                    x: {
                        type: "linear",
                        display: true,
                        offset: true,
                    },
                    y: {},
                },
                plugins: {},
            }}
        />
    </div>
{/if}
