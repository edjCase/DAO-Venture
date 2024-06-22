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
    import { User } from "../../ic-agent/declarations/users";
    import { teamStore } from "../../stores/TeamStore";
    import { toJsonString } from "../../utils/StringUtil";
    import ScenarioOption from "./ScenarioOption.svelte";
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
    export let userContext: User | undefined;

    let selectedChoice: number | undefined;
    let vote: ScenarioVote | "ineligible" = "ineligible";
    $: {
        let v = state.teamChoices.find(
            (v) => v.teamId === userContext?.team[0]?.id,
        );
        if (v) {
            selectedChoice = Number(v.option);
        }
    }

    $: teams = $teamStore;
    $: traits = $traitStore;

    let optionTeamVotes: bigint[][] | undefined;
    $: if (teams) {
        optionTeamVotes = scenario.options.map((_, i) => {
            return state.teamChoices
                .filter((v) => v.option[0] === BigInt(i))
                .map((v) => v.teamId);
        });
    }
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
    {#if options.length < 1}
        No options available
    {:else}
        {#each options as option, index}
            <ScenarioOption
                scenarioId={scenario.id}
                optionId={index}
                {option}
                selected={selectedChoice === index}
                teamEnergy={undefined}
                teamTraits={undefined}
                {vote}
                state={{
                    resolved: {
                        teams: optionTeamVotes
                            ? optionTeamVotes[index]
                            : undefined,
                    },
                }}
            />
        {/each}
    {/if}
    <div>
        {#if "threshold" in state.metaEffectOutcome && "threshold" in scenario.kind}
            <ThresholdResolvedScenarioState
                scenario={scenario.kind.threshold}
                outcome={state.metaEffectOutcome.threshold}
            />
        {:else if "noEffect" in state.metaEffectOutcome}
            <NoEffectResolvedScenarioState />
        {:else if "proportionalBid" in state.metaEffectOutcome && "proportionalBid" in scenario.kind}
            <ProportionalBidResolvedScenarioState
                scenario={scenario.kind.proportionalBid}
                outcome={state.metaEffectOutcome.proportionalBid}
                {teams}
            />
        {:else if "lottery" in state.metaEffectOutcome && "lottery" in scenario.kind}
            <LotteryResolvedScenarioState
                scenario={scenario.kind.lottery}
                outcome={state.metaEffectOutcome.lottery}
                {teams}
            />
        {:else if "leagueChoice" in state.metaEffectOutcome && "leagueChoice" in scenario.kind}
            <LeagueChoiceResolvedScenarioState
                scenario={scenario.kind.leagueChoice}
                outcome={state.metaEffectOutcome.leagueChoice}
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
