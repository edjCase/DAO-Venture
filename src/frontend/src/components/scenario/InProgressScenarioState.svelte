<script lang="ts">
    import { Button } from "flowbite-svelte";
    import { Scenario, VotingData } from "../../ic-agent/declarations/main";
    import { User } from "../../ic-agent/declarations/main";
    import { scenarioStore } from "../../stores/ScenarioStore";
    import LotteryInProgressScenarioState from "./in_progress_states/LotteryInProgressScenarioState.svelte";
    import WorldChoiceInProgressScenarioState from "./in_progress_states/WorldChoiceInProgressScenarioState.svelte";
    import ThresholdInProgressScenarioState from "./in_progress_states/ThresholdInProgressScenarioState.svelte";
    import NoWorldEffectInProgressScenarioState from "./in_progress_states/NoWorldEffectInProgressScenarioState.svelte";
    import { toJsonString } from "../../utils/StringUtil";
    import ProportionalBidInProgressScenarioState from "./in_progress_states/ProportionalBidInProgressScenarioState.svelte";
    import { townStore } from "../../stores/TownStore";
    import { Town } from "../../ic-agent/declarations/main";
    import ScenarioOptionDiscrete from "./ScenarioOptionDiscrete.svelte";
    import ScenarioOptionsRaw from "./ScenarioOptionsRaw.svelte";
    import TownFlag from "../town/TownFlag.svelte";
    import TextInputInProgressScenarioState from "./in_progress_states/TextInputInProgressScenarioState.svelte";

    export let scenario: Scenario;
    export let userContext: User | undefined;

    let townId: bigint | undefined;
    let town: Town | undefined;
    let isOwner: boolean = false;

    $: towns = $townStore;

    $: {
        townId = userContext?.residency[0]?.townId;
        town = towns?.find((town) => town.id === townId);
        isOwner = userContext?.residency[0] !== undefined;
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

{#if towns && votingData}
    Towns with consensus on choice:
    <div class="flex">
        {#each towns as town}
            <div
                class={votingData.townIdsWithConsensus.includes(town.id)
                    ? ""
                    : "opacity-25"}
            >
                <TownFlag {town} size="xs" />
            </div>
        {/each}
    </div>
{/if}
{#if votingData}
    {#if votingData.yourData[0] === undefined}
        Ineligible to vote
        {#if !userContext || !isOwner}
            <div>Want to participate in scenarios?</div>
            <Button>Become a Town co-owner</Button>
        {/if}
    {:else}
        {#if "lottery" in scenario.kind}
            <LotteryInProgressScenarioState scenario={scenario.kind.lottery} />
        {:else if "proportionalBid" in scenario.kind}
            <ProportionalBidInProgressScenarioState
                scenario={scenario.kind.proportionalBid}
            />
        {:else if "worldChoice" in scenario.kind}
            <WorldChoiceInProgressScenarioState />
        {:else if "threshold" in scenario.kind}
            <ThresholdInProgressScenarioState
                scenario={scenario.kind.threshold}
            />
        {:else if "textInput" in scenario.kind}
            <TextInputInProgressScenarioState
                scenario={scenario.kind.textInput}
            />
        {:else if "noWorldEffect" in scenario.kind}
            <NoWorldEffectInProgressScenarioState />
        {:else}
            NOT IMPLEMENTED SCENARIO KIND: {toJsonString(scenario.kind)}
        {/if}
        {#if "nat" in votingData.yourData[0].townOptions}
            <ScenarioOptionsRaw
                scenarioId={scenario.id}
                townId={votingData.yourData[0].townId}
                kind={{
                    nat: {
                        options: votingData.yourData[0].townOptions.nat,
                        vote: selectedNat,
                        townCurrency:
                            town === undefined ? undefined : town.currency,
                        icon: icon,
                    },
                }}
                {proposeName}
            />
        {:else if "text" in votingData.yourData[0].townOptions}
            <ScenarioOptionsRaw
                scenarioId={scenario.id}
                townId={votingData.yourData[0].townId}
                kind={{
                    text: {
                        options: votingData.yourData[0].townOptions.text,
                        vote: selectedText,
                    },
                }}
                {proposeName}
            />
        {:else if "discrete" in votingData.yourData[0].townOptions}
            {#each votingData.yourData[0].townOptions.discrete as option}
                <ScenarioOptionDiscrete
                    scenarioId={scenario.id}
                    {option}
                    selected={selectedId === option.id}
                    currency={town === undefined
                        ? undefined
                        : {
                              cost: option.currencyCost,
                              townCurrency: town.currency,
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
                votingData.yourData[0].townOptions,
            )}
        {/if}
        {(Number(votingData.yourData[0].townVotingPower.voted) /
            Number(votingData.yourData[0].townVotingPower.total)) *
            100}% of your town has voted
    {/if}
{/if}
