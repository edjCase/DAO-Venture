<script lang="ts">
    import { Select } from "flowbite-svelte";
    import { ScenarioKindRequest } from "../../../ic-agent/declarations/main";
    import NoWorldEffectScenarioEditor from "./scenarios/NoWorldEffectScenarioEditor.svelte";
    import WorldChoiceScenarioEditor from "./scenarios/WorldChoiceScenarioEditor.svelte";
    import ThresholdScenarioEditor from "./scenarios/ThresholdScenarioEditor.svelte";
    import TextInputScenarioEditor from "./scenarios/TextInputScenarioEditor.svelte";

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
                                "Contribute 1 to the threshold, but -1 🪙.",
                            resourceCosts: [],
                            requirements: [],
                            value: { fixed: BigInt(1) },
                            townEffect: {
                                resource: {
                                    kind: { gold: null },
                                    town: { contextual: null },
                                    value: { flat: BigInt(-1) },
                                },
                            },
                        },
                        {
                            title: "Don't Contribute",
                            description:
                                "Don't contribute to the threshold, but no negative effect.",
                            resourceCosts: [],
                            requirements: [],
                            value: { fixed: BigInt(0) },
                            townEffect: { noEffect: null },
                        },
                    ],
                    success: {
                        effect: {
                            resource: {
                                kind: { gold: null },
                                town: { contextual: null },
                                value: { flat: BigInt(10) },
                            },
                        },
                        description: "+10 🪙 for each town",
                    },
                    failure: {
                        effect: {
                            entropy: {
                                town: { contextual: null },
                                delta: BigInt(1),
                            },
                        },
                        description: "+1 🔥 for each town",
                    },
                    minAmount: BigInt(1),
                },
            };
        } else if (selectedType === "worldChoice") {
            value = {
                worldChoice: {
                    options: [
                        {
                            title: "Fast Start",
                            description:
                                "There is no time to wait, give us the 🪙and crank up the 🔥. +10 🪙+2 entropy per town",
                            resourceCosts: [],
                            worldEffect: {
                                allOf: [
                                    {
                                        entropy: {
                                            delta: BigInt(2),
                                            town: {
                                                contextual: null,
                                            },
                                        },
                                    },
                                    {
                                        resource: {
                                            kind: { gold: null },
                                            town: { contextual: null },
                                            value: {
                                                flat: BigInt(10),
                                            },
                                        },
                                    },
                                ],
                            },
                            townEffect: {
                                noEffect: null,
                            },
                            requirements: [],
                        },
                        {
                            title: "Status Quo",
                            description:
                                "Things are in balance, lets not touch anything",
                            resourceCosts: [],
                            worldEffect: {
                                noEffect: null,
                            },
                            townEffect: {
                                noEffect: null,
                            },
                            requirements: [],
                        },
                        {
                            title: "Cool Down",
                            description:
                                "Entropy is running too hot, lets cool it off by investing in our world. -5 🪙-2 🔥 per town",
                            resourceCosts: [],
                            worldEffect: {
                                allOf: [
                                    {
                                        entropy: {
                                            delta: BigInt(-2),
                                            town: {
                                                contextual: null,
                                            },
                                        },
                                    },
                                    {
                                        resource: {
                                            kind: { gold: null },
                                            town: { contextual: null },
                                            value: {
                                                flat: BigInt(-5),
                                            },
                                        },
                                    },
                                ],
                            },
                            townEffect: {
                                noEffect: null,
                            },
                            requirements: [],
                        },
                    ],
                },
            };
        } else if (selectedType === "textInput") {
            value = {
                textInput: {
                    description: "Enter some text",
                },
            };
        } else if (selectedType === "noWorldEffect") {
            value = {
                noWorldEffect: {
                    options: [
                        {
                            title: "Option 1",
                            description: "Description 1",
                            resourceCosts: [],
                            requirements: [],
                            townEffect: { noEffect: null },
                        },
                        {
                            title: "Option 2",
                            description: "Description 2",
                            resourceCosts: [],
                            requirements: [],
                            townEffect: { noEffect: null },
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
            name: "World Choice",
            value: "worldChoice",
        },
        {
            name: "Text Input",
            value: "textInput",
        },
        {
            name: "No World Effect",
            value: "noWorldEffect",
        },
    ];
</script>

<Select items={types} on:change={onChange} value={selectedType} />
{#if "threshold" in value}
    <ThresholdScenarioEditor bind:value={value.threshold} />
{:else if "worldChoice" in value}
    <WorldChoiceScenarioEditor bind:value={value.worldChoice} />
{:else if "textInput" in value}
    <TextInputScenarioEditor bind:value={value.textInput} />
{:else if "noWorldEffect" in value}
    <NoWorldEffectScenarioEditor bind:value={value.noWorldEffect} />
{:else}
    NOT IMPLEMENTED SCENARIO KIND : {selectedType}
{/if}
