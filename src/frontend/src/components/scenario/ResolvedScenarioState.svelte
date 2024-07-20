<script lang="ts">
    import {
        Scenario,
        ScenarioStateResolved,
        ScenarioVote,
    } from "../../ic-agent/declarations/main";
    import { Accordion, AccordionItem } from "flowbite-svelte";
    import {
        ChevronDoubleDownOutline,
        ChevronDoubleUpOutline,
    } from "flowbite-svelte-icons";
    import { townStore } from "../../stores/TownStore";
    import { toJsonString } from "../../utils/StringUtil";
    import { traitStore } from "../../stores/TraitStore";
    import ThresholdResolvedScenarioState from "./resolved_states/ThresholdResolvedScenarioState.svelte";
    import NoWorldEffectResolvedScenarioState from "./resolved_states/NoWorldEffectResolvedScenarioState.svelte";
    import ProportionalBidResolvedScenarioState from "./resolved_states/ProportionalBidResolvedScenarioState.svelte";
    import LotteryResolvedScenarioState from "./resolved_states/LotteryResolvedScenarioState.svelte";
    import WorldChoiceResolvedScenarioState from "./resolved_states/WorldChoiceResolvedScenarioState.svelte";
    import ScenarioEffectOutcome from "./ScenarioEffectOutcome.svelte";
    import { scenarioStore } from "../../stores/ScenarioStore";
    import ScenarioOptionDiscrete from "./ScenarioOptionDiscrete.svelte";
    import TownLogo from "../town/TownLogo.svelte";

    export let scenario: Scenario;
    export let state: ScenarioStateResolved;

    let selectedChoice: bigint | undefined;
    let vote: ScenarioVote | "ineligible" = "ineligible";

    $: towns = $townStore;
    $: traits = $traitStore;

    scenarioStore.subscribeVotingData((scenarioVotingData) => {
        let votingData = scenarioVotingData[Number(scenario.id)];
        if (votingData) {
            if (votingData.yourData[0] !== undefined) {
                vote = votingData.yourData[0];
                selectedChoice =
                    vote.value[0] !== undefined && "id" in vote.value[0]
                        ? vote.value[0].id
                        : undefined;
            } else {
                vote = "ineligible";
                selectedChoice = undefined;
            }
        }
    });

    let icon = "";
    $: {
        if ("lottery" in scenario.kind) {
            icon = "🎟️";
        } else if ("proportionalBid" in scenario.kind) {
            icon = "💰";
        } else {
            icon = "✅";
        }
    }
</script>

{#if towns !== undefined && traits !== undefined}
    <div>
        {#if "threshold" in state.scenarioOutcome && "threshold" in scenario.kind}
            <ThresholdResolvedScenarioState
                scenario={scenario.kind.threshold}
                outcome={state.scenarioOutcome.threshold}
            />
        {:else if "noWorldEffect" in state.scenarioOutcome}
            <NoWorldEffectResolvedScenarioState />
        {:else if "proportionalBid" in state.scenarioOutcome && "proportionalBid" in scenario.kind}
            <ProportionalBidResolvedScenarioState
                scenario={scenario.kind.proportionalBid}
                outcome={state.scenarioOutcome.proportionalBid}
                {towns}
            />
        {:else if "lottery" in state.scenarioOutcome}
            <LotteryResolvedScenarioState
                outcome={state.scenarioOutcome.lottery}
                {towns}
            />
        {:else if "worldChoice" in state.scenarioOutcome && "worldChoice" in scenario.kind && "discrete" in state.options.kind}
            <WorldChoiceResolvedScenarioState
                outcome={state.scenarioOutcome.worldChoice}
                options={state.options.kind.discrete}
            />
        {:else}
            NOT IMPLEMENTED SCENARIO OUTCOME {toJsonString(
                state.scenarioOutcome,
            )}
        {/if}
    </div>
    {#if "discrete" in state.options.kind}
        {#if state.options.kind.discrete.length < 1}
            No options were shown to any town
        {:else}
            {#each state.options.kind.discrete as discreteOption}
                <ScenarioOptionDiscrete
                    scenarioId={scenario.id}
                    option={discreteOption}
                    selected={selectedChoice === discreteOption.id}
                    currency={undefined}
                    {vote}
                    state={{
                        resolved: {
                            chosenByTownIds: discreteOption.chosenByTownIds,
                        },
                    }}
                />
            {/each}
        {/if}
    {:else if "nat" in state.options.kind}
        {#each state.options.kind.nat as natOption}
            <div class="flex items-center justify-center">
                <div>{natOption.value} {icon}</div>
                <div class="flex">
                    {#each natOption.chosenByTownIds as townId}
                        <!-- TODO Fix this town not found hack -->
                        <TownLogo
                            town={towns.find((t) => t.id == townId) ||
                                towns[-1]}
                            size="xs"
                        />
                    {/each}
                </div>
            </div>
        {/each}
    {:else if "text" in state.options.kind}
        {#each state.options.kind.text as textOption}
            <div class="flex items-center justify-center">
                <div>{textOption.value} {icon}</div>
                <div class="flex">
                    {#each textOption.chosenByTownIds as townId}
                        <!-- TODO Fix this town not found hack -->
                        <TownLogo
                            town={towns.find((t) => t.id == townId) ||
                                towns[-1]}
                            size="xs"
                        />
                    {/each}
                </div>
            </div>
        {/each}
    {:else}
        NOT IMPLEMENTED OPTIONS KIND {toJsonString(state.options)}
    {/if}
    {#if state.options.undecidedOption.chosenByTownIds.length > 0}
        <div>
            Undecided towns:
            <div class="flex items-center justify-center">
                {#each state.options.undecidedOption.chosenByTownIds as townId}
                    <!-- TODO Fix this town not found hack -->
                    <TownLogo
                        town={towns.find((t) => t.id == townId) || towns[-1]}
                        size="xs"
                    />
                {/each}
            </div>
        </div>
    {/if}
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
            {#if state.effectOutcomes.length < 1}
                Nothing happened...
            {:else}
                {#each state.effectOutcomes as outcome}
                    <ScenarioEffectOutcome {outcome} {towns} {traits} />
                {/each}
            {/if}
        </AccordionItem>
    </Accordion>
{/if}
