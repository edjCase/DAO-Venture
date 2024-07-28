<script lang="ts">
    import { Button } from "flowbite-svelte";
    import { Scenario, VotingData } from "../../ic-agent/declarations/main";
    import { User } from "../../ic-agent/declarations/main";
    import { scenarioStore } from "../../stores/ScenarioStore";
    import WorldChoiceInProgressScenarioState from "./in_progress_states/WorldChoiceInProgressScenarioState.svelte";
    import ThresholdInProgressScenarioState from "./in_progress_states/ThresholdInProgressScenarioState.svelte";
    import NoWorldEffectInProgressScenarioState from "./in_progress_states/NoWorldEffectInProgressScenarioState.svelte";
    import { toJsonString } from "../../utils/StringUtil";
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
    let selectedText: string | undefined;

    scenarioStore.subscribeVotingData((scenarioVotingData) => {
        votingData = scenarioVotingData[Number(scenario.id)];
        let yourData = votingData?.yourData[0];
        if (yourData !== undefined) {
            selectedId =
                yourData.value[0] !== undefined && "id" in yourData?.value[0]
                    ? yourData?.value[0].id
                    : undefined;
            selectedText =
                yourData?.value[0] !== undefined && "text" in yourData?.value[0]
                    ? yourData?.value[0].text
                    : undefined;
        } else {
            selectedId = undefined;
            selectedText = undefined;
        }
    });
    let proposeName = "";
    $: {
        if ("textInput" in scenario.kind) {
            proposeName = "Text";
        } else {
            proposeName =
                "NOT IMPLEMENTED SCENARIO KIND: " + toJsonString(scenario.kind);
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
    {@const yourData = votingData.yourData[0]}
    {#if yourData === undefined}
        Ineligible to vote
        {#if !userContext || !isOwner}
            <div>Want to participate in scenarios?</div>
            <Button>Become a Town co-owner</Button>
        {/if}
    {:else}
        {#if "worldChoice" in scenario.kind}
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
        {#if "text" in yourData.townOptions}
            <ScenarioOptionsRaw
                scenarioId={scenario.id}
                townId={yourData.townId}
                kind={{
                    text: {
                        options: yourData.townOptions.text,
                        vote: selectedText,
                    },
                }}
                {proposeName}
            />
        {:else if "discrete" in yourData.townOptions}
            {#each yourData.townOptions.discrete as option}
                {@const resourceCosts = option.resourceCosts.map((rc) => {
                    let townAmount;
                    if ("gold" in rc.kind) {
                        townAmount = town?.resources.gold;
                    } else if ("wood" in rc.kind) {
                        townAmount = town?.resources.wood;
                    } else if ("stone" in rc.kind) {
                        townAmount = town?.resources.stone;
                    } else if ("food" in rc.kind) {
                        townAmount = town?.resources.food;
                    } else {
                        townAmount = 0n;
                    }
                    return {
                        kind: rc.kind,
                        cost: rc.amount,
                        townAmount: townAmount,
                    };
                })}
                <ScenarioOptionDiscrete
                    scenarioId={scenario.id}
                    {option}
                    selected={selectedId === option.id}
                    {resourceCosts}
                    vote={yourData}
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
                yourData.townOptions,
            )}
        {/if}
        {(Number(yourData.townVotingPower.voted) /
            Number(yourData.townVotingPower.total)) *
            100}% of your town has voted
    {/if}
{/if}
