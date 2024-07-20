<script lang="ts">
    import { Select } from "flowbite-svelte";
    import { Effect } from "../../../ic-agent/declarations/main";
    import ScenarioEffectEditor from "./ScenarioEffectEditor.svelte";

    export let value: Effect;
    $: selectedType = Object.keys(value)[0];
    let onChange = (e: Event) => {
        selectedType = (e.target as HTMLSelectElement).value;
        if (selectedType === "allOf") {
            value = {
                allOf: [
                    {
                        noEffect: null,
                    },
                ],
            };
        } else if (selectedType === "oneOf") {
            value = {
                oneOf: [
                    {
                        weight: BigInt(1),
                        description: "",
                        effect: {
                            noEffect: null,
                        },
                    },
                ],
            };
        } else if (selectedType === "entropy") {
            value = {
                entropy: {
                    delta: BigInt(0),
                    town: { contextual: null },
                },
            };
        } else if (selectedType === "currency") {
            value = {
                currency: {
                    town: { contextual: null },
                    value: { flat: BigInt(1) },
                },
            };
        } else if (selectedType === "skill") {
            value = {
                skill: {
                    position: {
                        position: { random: null },
                        town: { contextual: null },
                    },
                    skill: { random: null },
                    duration: { matches: BigInt(1) },
                    delta: BigInt(0),
                },
            };
        } else if (selectedType === "injury") {
            value = {
                injury: {
                    position: {
                        position: { random: null },
                        town: { contextual: null },
                    },
                },
            };
        } else if (selectedType === "townTrait") {
            value = {
                townTrait: {
                    kind: { add: null },
                    town: { contextual: null },
                    traitId: "",
                },
            };
        } else if (selectedType === "noEffect") {
            value = {
                noEffect: null,
            };
        } else if (selectedType === "entropyThreshold") {
            value = {
                entropyThreshold: {
                    delta: BigInt(1),
                },
            };
        } else if (selectedType === "leagueIncome") {
            value = {
                leagueIncome: {
                    delta: BigInt(1),
                },
            };
        } else {
            throw new Error(`Unknown effect type: ${selectedType}`);
        }
    };

    const types = [
        {
            name: "All Of",
            value: "allOf",
        },
        {
            name: "One Of",
            value: "oneOf",
        },
        {
            name: "Entropy",
            value: "entropy",
        },
        {
            name: "Currency",
            value: "currency",
        },
        {
            name: "Skill",
            value: "skill",
        },
        {
            name: "Injury",
            value: "injury",
        },
        {
            name: "Town Trait",
            value: "townTrait",
        },
        {
            name: "Entropy Threshold",
            value: "entropyThreshold",
        },
        {
            name: "League Income",
            value: "leagueIncome",
        },
        {
            name: "No Effect",
            value: "noEffect",
        },
    ];
</script>

<Select items={types} on:change={onChange} value={selectedType} />
<ScenarioEffectEditor bind:value />
