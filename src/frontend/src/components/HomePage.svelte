<script lang="ts">
    import { townStore } from "../stores/TownStore";
    import { userStore } from "../stores/UserStore";
    import { mainAgentFactory } from "../ic-agent/Main";
    import LoadingButton from "./common/LoadingButton.svelte";
    import TownFlag from "./town/TownFlag.svelte";
    import HexGrid from "./common/HexGrid.svelte";

    $: towns = $townStore;

    $: user = $userStore;

    let joinWorld = async () => {
        let mainAgent = await mainAgentFactory();
        let result = await mainAgent.joinWorld();
        if ("ok" in result) {
            console.log("Joined world", result);
            userStore.refetchCurrentUser();
            userStore.refetchStats();
            townStore.refetch();
        } else {
            console.log("Error joining world", result);
        }
    };
</script>

<div class="bg-gray-800 rounded p-2">
    {#if user?.residency[0] === undefined}
        <div class="text-center text-3xl">
            <LoadingButton onClick={joinWorld}>Join World</LoadingButton>
        </div>
    {/if}
    {#if towns}
        {#each towns as town}
            <div class="flex flex-col justify-center gap-2">
                <div class="flex gap-2">
                    <TownFlag {town} size="xxs" />
                    <div class="text-3xl">{town.name}</div>
                </div>
                <div>Size: {town.size}</div>
                <div>Population: {town.population}</div>
            </div>
        {/each}
    {/if}
    <HexGrid
        gridData={[
            { coord: { q: 0, r: 0 }, value: 1 },
            { coord: { q: 0, r: -1 }, value: 2 },
            { coord: { q: 1, r: -1 }, value: 3 },
            { coord: { q: 1, r: 0 }, value: 4 },
            { coord: { q: 0, r: 1 }, value: 5 },
            { coord: { q: -1, r: 1 }, value: 6 },
            { coord: { q: -1, r: 0 }, value: 7 },
        ]}
    />
</div>
