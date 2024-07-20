<script lang="ts">
    import { LeagueData, Town } from "../../ic-agent/declarations/main";
    import { leagueStore } from "../../stores/LeagueStore";
    import { ChevronDownSolid } from "flowbite-svelte-icons";
    import { townStore } from "../../stores/TownStore";
    let towns: Town[] = [];
    let entropyData: LeagueData | undefined;

    townStore.subscribe((t) => {
        if (!t) {
            return;
        }
        towns = t;
        towns.sort((a, b) => Number(b.entropy) - Number(a.entropy));
    });

    leagueStore.subscribeData((data) => {
        entropyData = data;
    });

    const toRgbString = (color: [number, number, number]) => {
        return `rgb(${color[0]}, ${color[1]}, ${color[2]})`;
    };
    $: leagueEntropyPercentage =
        entropyData === undefined
            ? 0
            : (Number(entropyData.currentEntropy) /
                  Number(entropyData.entropyThreshold)) *
              100;
    const markerOffset = 7;
</script>

{#if !entropyData}
    <div></div>
{:else}
    <div class="flex justify-between mb-2 w-full">
        {#if entropyData.currentEntropy < entropyData.entropyThreshold}
            <div
                class="flex flex-col items-center justify-center"
                style="margin-left: calc({leagueEntropyPercentage}% - {markerOffset}px);"
            >
                {entropyData.currentEntropy}
                <ChevronDownSolid size="xs" />
            </div>
        {:else}
            <div></div>
        {/if}
        <div
            class="flex flex-col items-center justify-center"
            style="margin-right: -{markerOffset}px"
        >
            {entropyData.entropyThreshold}
            <ChevronDownSolid size="xs" />
        </div>
    </div>
    <div class="flex bg-gray-200 bg-opacity-25 mb-5 w-full h-5">
        {#if entropyData.currentEntropy >= entropyData.entropyThreshold}
            <div
                class="h-full bg-red-500 w-full"
                title="Entropy threshold exceeded"
            ></div>
        {:else}
            {#each towns as town}
                {#if Number(town.entropy) > 0}
                    <div
                        class="h-full"
                        style="width: {(Number(town.entropy) /
                            Number(entropyData.currentEntropy)) *
                            leagueEntropyPercentage}%; background-color: {toRgbString(
                            town.color,
                        )};"
                        title="{town.name}: {town.entropy}"
                    ></div>
                {/if}
            {/each}
        {/if}
    </div>
{/if}
