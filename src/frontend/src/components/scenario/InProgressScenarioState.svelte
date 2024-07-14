<script lang="ts">
    import { Button } from "flowbite-svelte";
    import { Scenario, VotingData } from "../../ic-agent/declarations/main";
    import { User } from "../../ic-agent/declarations/main";
    import { scenarioStore } from "../../stores/ScenarioStore";
    import LotteryInProgressScenarioState from "./in_progress_states/LotteryInProgressScenarioState.svelte";
    import LeagueChoiceInProgressScenarioState from "./in_progress_states/LeagueChoiceInProgressScenarioState.svelte";
    import ThresholdInProgressScenarioState from "./in_progress_states/ThresholdInProgressScenarioState.svelte";
    import NoLeagueEffectInProgressScenarioState from "./in_progress_states/NoLeagueEffectInProgressScenarioState.svelte";
    import { toJsonString } from "../../utils/StringUtil";
    import ProportionalBidInProgressScenarioState from "./in_progress_states/ProportionalBidInProgressScenarioState.svelte";
    import { teamStore } from "../../stores/TeamStore";
    import { Team } from "../../ic-agent/declarations/main";
    import ScenarioOptionDiscrete from "./ScenarioOptionDiscrete.svelte";
    import ScenarioOptionsRaw from "./ScenarioOptionsRaw.svelte";
    import TeamLogo from "../team/TeamLogo.svelte";
    import TextInputInProgressScenarioState from "./in_progress_states/TextInputInProgressScenarioState.svelte";

    export let scenario: Scenario;
    export let userContext: User | undefined;

    let teamId: bigint | undefined;
    let team: Team | undefined;
    let isOwner: boolean = false;

    $: teams = $teamStore;

    $: {
        teamId = userContext?.membership[0]?.teamId[0];
        team = teams?.find((team) => team.id === teamId);
        isOwner = userContext?.membership[0] !== undefined;
    }

    let votingData: VotingData | undefined;

    let selectedId: bigint | undefined;
    let selectedNat: bigint | undefined;
    let selectedText: string | undefined;

    scenarioStore.subscribeVotingData((scenarioVotingData) => {
        votingData = scenarioVotingData[Number(scenario.id)];
        if (votingData?.yourData[0] !== undefined) {
            selectedId =
                votingData.yourData[0].value[0] !== undefined &&
                "id" in votingData.yourData[0]?.value[0]
                    ? votingData.yourData[0]?.value[0].id
                    : undefined;
            selectedNat =
                votingData.yourData[0]?.value[0] !== undefined &&
                "nat" in votingData.yourData[0]?.value[0]
                    ? votingData.yourData[0]?.value[0].nat
                    : undefined;
            selectedText =
                votingData.yourData[0]?.value[0] !== undefined &&
                "text" in votingData.yourData[0]?.value[0]
                    ? votingData.yourData[0]?.value[0].text
                    : undefined;
        } else {
            selectedId = undefined;
            selectedNat = undefined;
            selectedText = undefined;
        }
    });
    let proposeName = "";
    let icon = "";
    $: {
        if ("lottery" in scenario.kind) {
            proposeName = "Ticket Count";
            icon = "🎟️";
        } else if ("proportionalBid" in scenario.kind) {
            proposeName = "Bid";
            icon = "💰";
        } else if ("textInput" in scenario.kind) {
            proposeName = "Text";
            icon = "📝";
        } else {
            proposeName =
                "NOT IMPLEMENTED SCENARIO KIND: " + toJsonString(scenario.kind);
            icon = "❓";
        }
    }
</script>

{#if teams && votingData}
    Teams with consensus on choice:
    <div class="flex">
        {#each teams as team}
            <div
                class={votingData.teamIdsWithConsensus.includes(team.id)
                    ? ""
                    : "opacity-25"}
            >
                <TeamLogo {team} size="xs" />
            </div>
        {/each}
    </div>
{/if}
{#if votingData}
    {#if votingData.yourData[0] === undefined}
        Ineligible to vote
        {#if !userContext || !isOwner}
            <div>Want to participate in scenarios?</div>
            <Button>Become a Team co-owner</Button>
        {/if}
    {:else}
        {#if "lottery" in scenario.kind}
            <LotteryInProgressScenarioState scenario={scenario.kind.lottery} />
        {:else if "proportionalBid" in scenario.kind}
            <ProportionalBidInProgressScenarioState
                scenario={scenario.kind.proportionalBid}
            />
        {:else if "leagueChoice" in scenario.kind}
            <LeagueChoiceInProgressScenarioState />
        {:else if "threshold" in scenario.kind}
            <ThresholdInProgressScenarioState
                scenario={scenario.kind.threshold}
            />
        {:else if "textInput" in scenario.kind}
            <TextInputInProgressScenarioState
                scenario={scenario.kind.textInput}
            />
        {:else if "noLeagueEffect" in scenario.kind}
            <NoLeagueEffectInProgressScenarioState />
        {:else}
            NOT IMPLEMENTED SCENARIO KIND: {toJsonString(scenario.kind)}
        {/if}
        {#if "nat" in votingData.yourData[0].teamOptions}
            <ScenarioOptionsRaw
                scenarioId={scenario.id}
                teamId={votingData.yourData[0].teamId}
                kind={{
                    nat: {
                        options: votingData.yourData[0].teamOptions.nat,
                        vote: selectedNat,
                        teamCurrency:
                            team === undefined ? undefined : team.currency,
                        icon: icon,
                    },
                }}
                {proposeName}
            />
        {:else if "text" in votingData.yourData[0].teamOptions}
            <ScenarioOptionsRaw
                scenarioId={scenario.id}
                teamId={votingData.yourData[0].teamId}
                kind={{
                    text: {
                        options: votingData.yourData[0].teamOptions.text,
                        vote: selectedText,
                    },
                }}
                {proposeName}
            />
        {:else if "discrete" in votingData.yourData[0].teamOptions}
            {#each votingData.yourData[0].teamOptions.discrete as option}
                <ScenarioOptionDiscrete
                    scenarioId={scenario.id}
                    {option}
                    selected={selectedId === option.id}
                    currency={team === undefined
                        ? undefined
                        : {
                              cost: option.currencyCost,
                              teamCurrency: team.currency,
                          }}
                    vote={votingData.yourData[0]}
                    state={{
                        inProgress: {
                            onSelect: () => {
                                selectedId = option.id;
                            },
                        },
                    }}
                />
            {/each}
        {:else}
            NOT IMPLEMENTED TEAM OPTIONS KIND: {toJsonString(
                votingData.yourData[0].teamOptions,
            )}
        {/if}
        {(Number(votingData.yourData[0].teamVotingPower.voted) /
            Number(votingData.yourData[0].teamVotingPower.total)) *
            100}% of your team has voted
    {/if}
{/if}
