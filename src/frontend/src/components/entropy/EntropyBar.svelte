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

<div class="flex justify-between mb-2 w-full">
    {#if totalEntropy < entropyMaxThreshold}
        <div
            class="flex flex-col items-center justify-center"
            style="margin-left: calc({leagueEntropyPercentage}% - {markerOffset}px);"
        >
            {totalEntropy}
            <ChevronDownSolid size="xs" />
        </div>
    {:else}
        <div></div>
    {/if}
    <div
        class="flex flex-col items-center justify-center"
        style="margin-right: -{markerOffset}px"
    >
        {entropyMaxThreshold}
        <ChevronDownSolid size="xs" />
    </div>
</div>
<div class="flex bg-gray-200 mb-5 w-full h-5">
    {#if totalEntropy >= entropyMaxThreshold}
        <div
            class="h-full"
            style="width: 100%; background-color: red;"
            title="Entropy threshold exceeded"
        ></div>
    {:else}
        {#each teams as team}
            {#if Number(team.entropy) > 0}
                <div
                    class="h-full"
                    style="width: {(Number(team.entropy) / totalEntropy) *
                        leagueEntropyPercentage}%; background-color: {toRgbString(
                        team.color,
                    )};"
                    title="{team.name}: {team.entropy}"
                ></div>
            {/if}
        {/each}
    {/if}
</div>
