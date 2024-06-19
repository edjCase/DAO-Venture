<script lang="ts">
    import { Select } from "flowbite-svelte";
    import { MetaEffect } from "../../../ic-agent/declarations/league";
    import MetaEffectEditor from "./MetaEffectEditor.svelte";

    export let value: MetaEffect;
    $: selectedType = Object.keys(value)[0];
    let onChange = (e: Event) => {
        selectedType = (e.target as HTMLSelectElement).value;
        if (selectedType === "threshold") {
            value = {
                threshold: {
                    undecidedAmount: { fixed: BigInt(0) },
                    options: [
                        {
                            value: { fixed: BigInt(0) },
                        },
                        {
                            value: { fixed: BigInt(1) },
                        },
                    ],
                    success: { effect: { noEffect: null }, description: "" },
                    failure: { effect: { noEffect: null }, description: "" },
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
                    options: [],
                    prize: { noEffect: null },
                },
            };
        } else if (selectedType === "proportionalBid") {
            value = {
                proportionalBid: {
                    options: [],
                    prize: {
                        kind: {
                            skill: {
                                duration: { matches: BigInt(1) },
                                skill: { random: null },
                                target: {
                                    position: { random: null },
                                    team: { choosingTeam: null },
                                },
                            },
                        },
                        amount: BigInt(1),
                    },
                },
            };
        } else if (selectedType === "noEffect") {
            value = {
                noEffect: null,
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
            name: "No Effect",
            value: "noEffect",
        },
    ];
</script>

<Select items={types} on:change={onChange} value={selectedType} />
<MetaEffectEditor bind:value />
