<script lang="ts">
    import {
        Scenario,
        ScenarioStateResolved,
        ScenarioVote,
    } from "../../ic-agent/declarations/league";
    import { Accordion, AccordionItem } from "flowbite-svelte";
    import {
        ChevronDoubleDownOutline,
        ChevronDoubleUpOutline,
    } from "flowbite-svelte-icons";
    import { teamStore } from "../../stores/TeamStore";
    import { toJsonString } from "../../utils/StringUtil";
    import { traitStore } from "../../stores/TraitStore";
    import ThresholdResolvedScenarioState from "./resolved_states/ThresholdResolvedScenarioState.svelte";
    import NoEffectResolvedScenarioState from "./resolved_states/NoLeagueEffectResolvedScenarioState.svelte";
    import ProportionalBidResolvedScenarioState from "./resolved_states/ProportionalBidResolvedScenarioState.svelte";
    import LotteryResolvedScenarioState from "./resolved_states/LotteryResolvedScenarioState.svelte";
    import LeagueChoiceResolvedScenarioState from "./resolved_states/LeagueChoiceResolvedScenarioState.svelte";
    import ScenarioEffectOutcome from "./ScenarioEffectOutcome.svelte";
    import { scenarioStore } from "../../stores/ScenarioStore";

    export let scenario: Scenario;
    export let state: ScenarioStateResolved;

    let selectedChoice: number | undefined;
    let vote: ScenarioVote | "ineligible" = "ineligible";

    $: teams = $teamStore;
    $: traits = $traitStore;

    scenarioStore.subscribeVotes((votes) => {
        console.log("Votes", votes);
        if (votes[Number(scenario.id)] !== undefined) {
            vote = votes[Number(scenario.id)];
        } else {
            vote = "ineligible";
            selectedChoice = undefined;
        }
    });
</script>

{#if teams !== undefined && traits !== undefined}
    <div>
        {#if "threshold" in state.metaEffectOutcome && "threshold" in scenario.kind}
            <ThresholdResolvedScenarioState
                scenarioId={scenario.id}
                scenario={scenario.kind.threshold}
                outcome={state.metaEffectOutcome.threshold}
                {state}
                {vote}
            />
        {:else if "noLeagueEffect" in state.metaEffectOutcome && "noLeagueEffect" in scenario.kind}
            <NoEffectResolvedScenarioState
                scenarioId={scenario.id}
                scenario={scenario.kind.noLeagueEffect}
                {state}
                {vote}
            />
        {:else if "proportionalBid" in state.metaEffectOutcome && "proportionalBid" in scenario.kind}
            <ProportionalBidResolvedScenarioState
                scenarioId={scenario.id}
                scenario={scenario.kind.proportionalBid}
                outcome={state.metaEffectOutcome.proportionalBid}
                {teams}
                {vote}
            />
        {:else if "lottery" in state.metaEffectOutcome && "lottery" in scenario.kind}
            <LotteryResolvedScenarioState
                scenarioId={scenario.id}
                scenario={scenario.kind.lottery}
                outcome={state.metaEffectOutcome.lottery}
                {teams}
                {state}
                {vote}
            />
        {:else if "leagueChoice" in state.metaEffectOutcome && "leagueChoice" in scenario.kind}
            <LeagueChoiceResolvedScenarioState
                scenarioId={scenario.id}
                scenario={scenario.kind.leagueChoice}
                outcome={state.metaEffectOutcome.leagueChoice}
                {state}
                {vote}
            />
        {:else}
            NOT IMPLEMENTED {toJsonString(state.metaEffectOutcome)}
        {/if}
    </div>

    <Accordion border={false} flush={true}>
        <AccordionItem
            paddingFlush=""
            defaultClass="flex items-center font-medium w-full text-right justify-center gap-2"
        >
            <span slot="header">
                <div class="text-md text-right">Outcomes</div>
            </span>
            <span slot="arrowdown">
                <ChevronDoubleDownOutline size="xs" />
            </span>
            <div slot="arrowup">
                <ChevronDoubleUpOutline size="xs" />
            </div>
            {#each state.effectOutcomes as outcome}
                <ScenarioEffectOutcome {outcome} {teams} {traits} />
            {/each}
        </AccordionItem>
    </Accordion>
{/if}
