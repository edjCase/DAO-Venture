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

    import { Skills } from "../../ic-agent/declarations/players";

    export let skills: Skills;

    const data: ChartData<"pie", number[], unknown> = {
        labels: [
            "Batting Accuracy",
            "Batting Power",
            "Throwing Accuracy",
            "Throwing Power",
            "Catching",
            "Defense",
            "Speed",
        ],
        datasets: [
            {
                data: [
                    Number(skills.battingAccuracy),
                    Number(skills.battingPower),
                    Number(skills.throwingAccuracy),
                    Number(skills.throwingPower),
                    Number(skills.defense),
                    Number(skills.speed),
                ],
                backgroundColor: [
                    "#F7464A",
                    "#46BFBD",
                    "#FDB45C",
                    "#949FB1",
                    "#4D5360",
                    "#AC64AD",
                    "#DA92DB",
                ],
                hoverBackgroundColor: [
                    "#FF5A5E",
                    "#5AD3D1",
                    "#FFC870",
                    "#A8B3C5",
                    "#616774",
                    "#DA92DB",
                    "#A8B3C5",
                ],
            },
        ],
    };

    ChartJS.register(Title, Tooltip, Legend, ArcElement, CategoryScale);
</script>

<div class="w-32">
    <Pie
        {data}
        options={{
            radius: 33,
            plugins: {
                legend: {
                    display: false,
                },
                tooltip: {
                    position: "nearest",
                    xAlign: "left",
                    yAlign: "bottom",
                    displayColors: false,
                    callbacks: {
                        label: function (context) {
                            let label = context.parsed.toString();
                            if (context.label) {
                                label += " " + context.label;
                            }
                            return label;
                        },
                        title: function () {
                            return "";
                        },
                    },
                },
            },
        }}
    />
</div>
