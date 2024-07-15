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
    import { teamStore } from "../../stores/TeamStore";
    import { toJsonString } from "../../utils/StringUtil";
    import { traitStore } from "../../stores/TraitStore";
    import ThresholdResolvedScenarioState from "./resolved_states/ThresholdResolvedScenarioState.svelte";
    import NoLeagueEffectResolvedScenarioState from "./resolved_states/NoLeagueEffectResolvedScenarioState.svelte";
    import ProportionalBidResolvedScenarioState from "./resolved_states/ProportionalBidResolvedScenarioState.svelte";
    import LotteryResolvedScenarioState from "./resolved_states/LotteryResolvedScenarioState.svelte";
    import LeagueChoiceResolvedScenarioState from "./resolved_states/LeagueChoiceResolvedScenarioState.svelte";
    import ScenarioEffectOutcome from "./ScenarioEffectOutcome.svelte";
    import { scenarioStore } from "../../stores/ScenarioStore";
    import ScenarioOptionDiscrete from "./ScenarioOptionDiscrete.svelte";
    import TeamLogo from "../team/TeamLogo.svelte";

    export let scenario: Scenario;
    export let state: ScenarioStateResolved;

    let selectedChoice: bigint | undefined;
    let vote: ScenarioVote | "ineligible" = "ineligible";

    $: teams = $teamStore;
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

{#if teams !== undefined && traits !== undefined}
    <div>
        {#if "threshold" in state.scenarioOutcome && "threshold" in scenario.kind}
            <ThresholdResolvedScenarioState
                scenario={scenario.kind.threshold}
                outcome={state.scenarioOutcome.threshold}
            />
        {:else if "noLeagueEffect" in state.scenarioOutcome}
            <NoLeagueEffectResolvedScenarioState />
        {:else if "proportionalBid" in state.scenarioOutcome && "proportionalBid" in scenario.kind}
            <ProportionalBidResolvedScenarioState
                scenario={scenario.kind.proportionalBid}
                outcome={state.scenarioOutcome.proportionalBid}
                {teams}
            />
        {:else if "lottery" in state.scenarioOutcome}
            <LotteryResolvedScenarioState
                outcome={state.scenarioOutcome.lottery}
                {teams}
            />
        {:else if "leagueChoice" in state.scenarioOutcome && "leagueChoice" in scenario.kind && "discrete" in state.options.kind}
            <LeagueChoiceResolvedScenarioState
                outcome={state.scenarioOutcome.leagueChoice}
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
            No options were shown to any team
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
                            chosenByTeamIds: discreteOption.chosenByTeamIds,
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
                    {#each natOption.chosenByTeamIds as teamId}
                        <!-- TODO Fix this team not found hack -->
                        <TeamLogo
                            team={teams.find((t) => t.id == teamId) ||
                                teams[-1]}
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
                    {#each textOption.chosenByTeamIds as teamId}
                        <!-- TODO Fix this team not found hack -->
                        <TeamLogo
                            team={teams.find((t) => t.id == teamId) ||
                                teams[-1]}
                            size="xs"
                        />
                    {/each}
                </div>
            </div>
        {/each}
    {:else}
        NOT IMPLEMENTED OPTIONS KIND {toJsonString(state.options)}
    {/if}
    {#if state.options.undecidedOption.chosenByTeamIds.length > 0}
        <div>
            Undecided teams:
            <div class="flex items-center justify-center">
                {#each state.options.undecidedOption.chosenByTeamIds as teamId}
                    <!-- TODO Fix this team not found hack -->
                    <TeamLogo
                        team={teams.find((t) => t.id == teamId) || teams[-1]}
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
                    <ScenarioEffectOutcome {outcome} {teams} {traits} />
                {/each}
            {/if}
        </AccordionItem>
    </Accordion>
{/if}
