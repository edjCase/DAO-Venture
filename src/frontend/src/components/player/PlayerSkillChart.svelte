<script lang="ts">
    import { Skills } from "../../ic-agent/declarations/players";

    export let skills: Skills;

    let data = [
        {
            skill: "Batting Accuracy",
            value: skills.battingAccuracy,
            fill: "green",
        },
        {
            skill: "Batting Power",
            value: skills.battingPower,
            fill: "blue",
        },
        {
            skill: "Throwing Accuracy",
            value: skills.throwingAccuracy,
            fill: "red",
        },
        {
            skill: "Throwing Power",
            value: skills.throwingPower,
            fill: "orange",
        },
        {
            skill: "Catching",
            value: skills.catching,
            fill: "pink",
        },
        {
            skill: "Defense",
            value: skills.defense,
            fill: "black",
        },
        {
            skill: "Speed",
            value: skills.speed,
            fill: "white",
        },
    ];
    const dotRadius = 4;
    const dotSpacing = 15;
    const lineY = 50; // Vertical position of the line
</script>

<svg class="" width="100px" height="100px">
    <!-- Horizontal line -->
    <line
        x1="0"
        y1={lineY}
        x2={data.length * dotSpacing}
        y2={lineY}
        stroke="black"
    />

    <!-- Dots for each skill -->
    {#each data as { value }, index}
        <g>
            {#if value > 0}
                {#each [...Array(value)] as _, i}
                    <circle
                        cx={index * dotSpacing + dotRadius}
                        cy={lineY - (i + 1) * (dotRadius * 3)}
                        r={dotRadius}
                        fill={data[index].fill}
                    />
                {/each}
            {:else if value < 0}
                {#each [...Array(-value)] as _, i}
                    <circle
                        cx={index * dotSpacing + dotRadius}
                        cy={lineY + (i + 1) * (dotRadius * 3)}
                        r={dotRadius}
                        fill={data[index].fill}
                    />
                {/each}
            {/if}
        </g>
    {/each}
</svg>
