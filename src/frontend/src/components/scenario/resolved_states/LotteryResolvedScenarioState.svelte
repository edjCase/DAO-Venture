<script lang="ts">
    import { LotteryScenarioOutcome } from "../../../ic-agent/declarations/main";
    import { Town } from "../../../ic-agent/declarations/main";
    import TownLogo from "../../town/TownLogo.svelte";

    export let outcome: LotteryScenarioOutcome;
    export let towns: Town[];

    $: winningTown =
        outcome.winningTownId[0] !== undefined
            ? towns.find((town) => town.id === outcome.winningTownId[0])
            : undefined;
</script>

<div class="text-xl text-center mb-8">
    Winner
    {#if winningTown === undefined}
        <div>NONE</div>
    {:else}
        <TownLogo town={winningTown} size="md" />
    {/if}
</div>
