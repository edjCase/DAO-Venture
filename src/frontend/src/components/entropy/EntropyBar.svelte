<script lang="ts">
    import { Team } from "../../ic-agent/declarations/teams";
    import { teamStore } from "../../stores/TeamStore";
    import { ChevronDownSolid } from "flowbite-svelte-icons";
    let teams: Team[] = [];
    let totalEntropy = 0;
    const entropyMaxThreshold = 20; // TODO

    teamStore.subscribe((t) => {
        if (!t) {
            return;
        }
        teams = t;
        teams.sort((a, b) => Number(b.entropy) - Number(a.entropy));
        totalEntropy = teams.reduce(
            (sum, team) => sum + Number(team.entropy),
            0,
        );
    });
    const toRgbString = (color: [number, number, number]) => {
        return `rgb(${color[0]}, ${color[1]}, ${color[2]})`;
    };
    $: leagueEntropyPercentage = (totalEntropy / entropyMaxThreshold) * 100;
    const markerOffset = 7;
</script>

<div class="flex justify-between mb-2">
    <div
        class="flex flex-col items-center justify-center"
        style="margin-left: calc({leagueEntropyPercentage}% - {totalEntropy +
            markerOffset}px);"
    >
        {totalEntropy}
        <ChevronDownSolid size="xs" />
    </div>
    <div
        class="flex flex-col items-center justify-center"
        style="margin-right: -{markerOffset}px"
    >
        {entropyMaxThreshold}
        <ChevronDownSolid size="xs" />
    </div>
</div>
<div class="bg-gray-200 rounded-lg mb-5 w-full h-5 relative">
    {#each teams as team}
        {#if Number(team.entropy) > 0}
            <div
                class="h-full rounded-lg"
                style="width: {(Number(team.entropy) / totalEntropy) *
                    leagueEntropyPercentage}%; background-color: {toRgbString(
                    team.color,
                )};"
                title="{team.name}: {team.entropy}"
            ></div>
        {/if}
    {/each}
</div>
