<script lang="ts">
    import { Select } from "flowbite-svelte";
    import { ScenarioKind } from "../../../ic-agent/declarations/league";
    import NoLeagueEffectScenarioKindEditor from "./scenarios/NoLeagueEffectScenarioEditor.svelte";
    import ProportionalBidScenarioKindEditor from "./scenarios/ProportionalBidScenarioEditor.svelte";
    import LotteryScenarioKindEditor from "./scenarios/LotteryScenarioEditor.svelte";
    import LeagueChoiceScenarioKindEditor from "./scenarios/LeagueChoiceScenarioEditor.svelte";
    import ThresholdScenarioKindEditor from "./scenarios/ThresholdScenarioEditor.svelte";

    export let value: ScenarioKind;
    $: selectedType = Object.keys(value)[0];
    let onChange = (e: Event) => {
        selectedType = (e.target as HTMLSelectElement).value;
        if (selectedType === "threshold") {
            value = {
                threshold: {
                    undecidedAmount: { fixed: BigInt(0) },
                    options: [
                        {
                            title: "Option 1",
                            description: "Description 1",
                            energyCost: BigInt(0),
                            traitRequirements: [],
                            value: { fixed: BigInt(0) },
                            teamEffect: { noEffect: null },
                        },
                        {
                            title: "Option 2",
                            description: "Description 2",
                            energyCost: BigInt(0),
                            traitRequirements: [],
                            value: { fixed: BigInt(0) },
                            teamEffect: { noEffect: null },
                        },
                    ],
                    success: {
                        effect: { noEffect: null },
                        description: "Success",
                    },
                    failure: {
                        effect: { noEffect: null },
                        description: "Failure",
                    },
                    minAmount: BigInt(1),
                },
            };
        } else if (selectedType === "leagueChoice") {
            value = {
                leagueChoice: {
                    options: [],
                },
            };
        } else if (selectedType === "lottery") {
            value = {
                lottery: {
                    minBid: BigInt(0),
                    prize: { noEffect: null },
                },
            };
        } else if (selectedType === "proportionalBid") {
            value = {
                proportionalBid: {
                    prize: {
                        kind: {
                            skill: {
                                duration: { matches: BigInt(1) },
                                skill: { random: null },
                                target: {
                                    position: { random: null },
                                    team: { contextual: null },
                                },
                            },
                        },
                        amount: BigInt(1),
                    },
                },
            };
        } else if (selectedType === "noLeagueEffect") {
            value = {
                noLeagueEffect: {
                    options: [
                        {
                            title: "Option 1",
                            description: "Description 1",
                            energyCost: BigInt(0),
                            traitRequirements: [],
                            teamEffect: { noEffect: null },
                        },
                        {
                            title: "Option 2",
                            description: "Description 2",
                            energyCost: BigInt(0),
                            traitRequirements: [],
                            teamEffect: { noEffect: null },
                        },
                    ],
                },
            };
        } else {
            throw new Error(`Unknown meta effect type: ${selectedType}`);
        }
    };

    const types = [
        {
            name: "Threshold",
            value: "threshold",
        },
        {
            name: "League Choice",
            value: "leagueChoice",
        },
        {
            name: "Lottery",
            value: "lottery",
        },
        {
            name: "Proportional Bid",
            value: "proportionalBid",
        },
        {
            name: "No League Effect",
            value: "noLeagueEffect",
        },
    ];
</script>

<Select items={types} on:change={onChange} value={selectedType} />
{#if "threshold" in value}
    <ThresholdScenarioKindEditor bind:value={value.threshold} />
{:else if "leagueChoice" in value}
    <LeagueChoiceScenarioKindEditor bind:value={value.leagueChoice} />
{:else if "lottery" in value}
    <LotteryScenarioKindEditor bind:value={value.lottery} />
{:else if "proportionalBid" in value}
    <ProportionalBidScenarioKindEditor bind:value={value.proportionalBid} />
{:else if "noLeagueEffect" in value}
    <NoLeagueEffectScenarioKindEditor bind:value={value.noLeagueEffect} />
{:else}
    NOT IMPLEMENTED SCENARIO KIND : {selectedType}
{/if}
