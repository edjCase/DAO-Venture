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
    import ScenarioOption from "./ScenarioOption.svelte";

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

    let optionTeamVotes: bigint[][] | undefined;
    $: if (teams) {
        optionTeamVotes = []; // TODO
        // optionTeamVotes = options.map((_, i) => {
        //     return state.teamChoices
        //         .filter((v) => v.optionId[0] === BigInt(i))
        //         .map((v) => v.teamId);
        // });
    }
</script>

{#if vote === "ineligible"}
    Ineligible to vote
{:else if vote.teamOptions.length < 1}
    No options available
{:else}
    {#if teams !== undefined && traits !== undefined}
        <div>
            {#if "threshold" in state.scenarioOutcome && "threshold" in scenario.kind}
                <ThresholdResolvedScenarioState
                    scenarioId={scenario.id}
                    scenario={scenario.kind.threshold}
                    outcome={state.scenarioOutcome.threshold}
                    {state}
                    {vote}
                />
            {:else if "noLeagueEffect" in state.scenarioOutcome && "noLeagueEffect" in scenario.kind}
                <NoEffectResolvedScenarioState
                    scenarioId={scenario.id}
                    scenario={scenario.kind.noLeagueEffect}
                    {state}
                    {vote}
                />
            {:else if "proportionalBid" in state.scenarioOutcome && "proportionalBid" in scenario.kind}
                <ProportionalBidResolvedScenarioState
                    scenarioId={scenario.id}
                    scenario={scenario.kind.proportionalBid}
                    outcome={state.scenarioOutcome.proportionalBid}
                    {teams}
                    {vote}
                />
            {:else if "lottery" in state.scenarioOutcome && "lottery" in scenario.kind}
                <LotteryResolvedScenarioState
                    scenarioId={scenario.id}
                    scenario={scenario.kind.lottery}
                    outcome={state.scenarioOutcome.lottery}
                    {teams}
                    {state}
                    {vote}
                />
            {:else if "leagueChoice" in state.scenarioOutcome && "leagueChoice" in scenario.kind}
                <LeagueChoiceResolvedScenarioState
                    scenarioId={scenario.id}
                    scenario={scenario.kind.leagueChoice}
                    outcome={state.scenarioOutcome.leagueChoice}
                    {state}
                    {vote}
                />
            {:else}
                NOT IMPLEMENTED {toJsonString(state.scenarioOutcome)}
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

    {#each vote.teamOptions as option, index}
        <ScenarioOption
            scenarioId={scenario.id}
            optionId={index}
            {option}
            selected={selectedChoice === index}
            teamEnergy={undefined}
            {vote}
            state={{
                resolved: {
                    teams: optionTeamVotes ? optionTeamVotes[index] : undefined,
                },
            }}
        />
    {/each}
{/if}
