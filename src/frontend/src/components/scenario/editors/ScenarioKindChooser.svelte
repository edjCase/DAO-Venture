<script lang="ts">
    import { Select } from "flowbite-svelte";
    import { ScenarioKindRequest } from "../../../ic-agent/declarations/main";
    import NoLeagueEffectScenarioKindEditor from "./scenarios/NoLeagueEffectScenarioEditor.svelte";
    import ProportionalBidScenarioKindEditor from "./scenarios/ProportionalBidScenarioEditor.svelte";
    import LotteryScenarioKindEditor from "./scenarios/LotteryScenarioEditor.svelte";
    import LeagueChoiceScenarioKindEditor from "./scenarios/LeagueChoiceScenarioEditor.svelte";
    import ThresholdScenarioKindEditor from "./scenarios/ThresholdScenarioEditor.svelte";

    export let value: ScenarioKindRequest;
    $: selectedType = Object.keys(value)[0];
    let onChange = (e: Event) => {
        selectedType = (e.target as HTMLSelectElement).value;
        if (selectedType === "threshold") {
            value = {
                threshold: {
                    undecidedAmount: { fixed: BigInt(0) },
                    options: [
                        {
                            title: "Contribute",
                            description:
                                "Contribute 1 to the threshold, but -1 random skill to a random player on the team for a match.",
                            energyCost: BigInt(0),
                            traitRequirements: [],
                            value: { fixed: BigInt(1) },
                            teamEffect: {
                                skill: {
                                    duration: { matches: BigInt(1) },
                                    skill: { random: null },
                                    position: {
                                        position: { random: null },
                                        team: { contextual: null },
                                    },
                                    delta: BigInt(-1),
                                },
                            },
                        },
                        {
                            title: "Don't Contribute",
                            description:
                                "Don't contribute to the threshold, but no negative effect.",
                            energyCost: BigInt(0),
                            traitRequirements: [],
                            value: { fixed: BigInt(0) },
                            teamEffect: { noEffect: null },
                        },
                    ],
                    success: {
                        effect: {
                            energy: {
                                team: { contextual: null },
                                value: { flat: BigInt(10) },
                            },
                        },
                        description: "+10 💰 for each team",
                    },
                    failure: {
                        effect: {
                            entropy: {
                                team: { contextual: null },
                                delta: BigInt(1),
                            },
                        },
                        description: "+1 🔥 for each team",
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
                    prize: {
                        description: "+10 💰",
                        effect: {
                            energy: {
                                team: { contextual: null },
                                value: { flat: BigInt(10) },
                            },
                        },
                    },
                },
            };
        } else if (selectedType === "proportionalBid") {
            value = {
                proportionalBid: {
                    prize: {
                        description:
                            "+1 random skill for 1 match to a random player on the team",
                        kind: {
                            skill: {
                                duration: { matches: BigInt(1) },
                                skill: { random: null },
                                position: {
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
