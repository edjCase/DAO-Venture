<script lang="ts">
    import { LotteryScenarioOutcome } from "../../../ic-agent/declarations/main";
    import { Town } from "../../../ic-agent/declarations/main";
    import TeamFlag from "../../town/TeamFlag.svelte";

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
        <TeamFlag town={winningTown} size="md" />
    {/if}
</div>
