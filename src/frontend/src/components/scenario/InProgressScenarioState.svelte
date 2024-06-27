<script lang="ts">
    import { Button } from "flowbite-svelte";
    import { Scenario, ScenarioVote } from "../../ic-agent/declarations/league";
    import { User } from "../../ic-agent/declarations/users";
    import { scenarioStore } from "../../stores/ScenarioStore";
    import LotteryInProgressScenarioState from "./in_progress_states/LotteryInProgressScenarioState.svelte";
    import LeagueChoiceInProgressScenarioState from "./in_progress_states/LeagueChoiceInProgressScenarioState.svelte";
    import ThresholdInProgressScenarioState from "./in_progress_states/ThresholdInProgressScenarioState.svelte";
    import NoLeagueEffectInProgressScenarioState from "./in_progress_states/NoLeagueEffectInProgressScenarioState.svelte";
    import { toJsonString } from "../../utils/StringUtil";
    import ProportionalBidInProgressScenarioState from "./in_progress_states/ProportionalBidInProgressScenarioState.svelte";
    import { teamStore } from "../../stores/TeamStore";
    import { Team } from "../../ic-agent/declarations/teams";
    import ScenarioOption from "./ScenarioOption.svelte";

    export let scenario: Scenario;
    export let userContext: User | undefined;

    let teamId: bigint | undefined;
    let team: Team | undefined;
    let isOwner: boolean = false;

    $: teams = $teamStore;

    $: {
        teamId = userContext?.team[0]?.id;
        team = teams?.find((team) => team.id === teamId);
        isOwner = teamId != undefined && "owner" in userContext!.team[0]!.kind;
    }

    let vote: ScenarioVote | "ineligible" = "ineligible";

    let selectedChoice: bigint | undefined;

    scenarioStore.subscribeVotes((votes) => {
        if (votes[Number(scenario.id)] !== undefined) {
            vote = votes[Number(scenario.id)];
            selectedChoice = vote.optionId[0];
        } else {
            vote = "ineligible";
            selectedChoice = undefined;
        }
    });
</script>

{#if vote === "ineligible"}
    Ineligible to vote
    {#if !userContext || !isOwner}
        <div>Want to participate in scenarios?</div>
        <Button>Become a Team co-owner</Button>
    {/if}
{:else}
    {#if "lottery" in scenario.kind}
        <LotteryInProgressScenarioState
            scenarioId={scenario.id}
            scenario={scenario.kind.lottery}
            {vote}
        />
    {:else if "proportionalBid" in scenario.kind}
        <ProportionalBidInProgressScenarioState
            scenarioId={scenario.id}
            scenario={scenario.kind.proportionalBid}
            {vote}
        />
    {:else if "leagueChoice" in scenario.kind}
        <LeagueChoiceInProgressScenarioState
            scenarioId={scenario.id}
            scenario={scenario.kind.leagueChoice}
            {vote}
        />
    {:else if "threshold" in scenario.kind}
        <ThresholdInProgressScenarioState
            scenarioId={scenario.id}
            scenario={scenario.kind.threshold}
            {vote}
        />
    {:else if "noLeagueEffect" in scenario.kind}
        <NoLeagueEffectInProgressScenarioState
            scenarioId={scenario.id}
            scenario={scenario.kind.noLeagueEffect}
            {vote}
        />
    {:else}
        NOT IMPLEMENTED SCENARIO KIND: {toJsonString(scenario.kind)}
    {/if}
    {#if vote.teamOptions.length < 1}
        No options available
    {:else}
        {#each vote.teamOptions as option}
            <ScenarioOption
                scenarioId={scenario.id}
                {option}
                selected={selectedChoice === option.id}
                energy={team === undefined
                    ? undefined
                    : { cost: option.energyCost, teamEnergy: team.energy }}
                {vote}
                state={{
                    inProgress: {
                        onSelect: () => {
                            selectedChoice = option.id;
                        },
                    },
                }}
            />
        {/each}
    {/if}
{/if}
