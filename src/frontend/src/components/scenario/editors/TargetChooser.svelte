<script lang="ts">
    import { Select } from "flowbite-svelte";
    import { Target } from "../../../ic-agent/declarations/league";
    import TargetEditor from "./TargetEditor.svelte";

    export let value: Target;
    let selectedType = Object.keys(value)[0];
    let onChange = (e: Event) => {
        selectedType = (e.target as HTMLSelectElement).value;
        if (selectedType === "teams") {
            value = {
                teams: [],
            };
        } else if (selectedType === "league") {
            value = {
                league: null,
            };
        } else if (selectedType === "positions") {
            value = {
                positions: [],
            };
        } else {
            throw new Error(`Unknown target type: ${selectedType}`);
        }
    };

    const types = [
        {
            name: "Teams",
            value: "teams",
        },
        {
            name: "League",
            value: "league",
        },
        {
            name: "Positions",
            value: "positions",
        },
    ];
</script>

<Select items={types} on:change={onChange} value={selectedType} />

<TargetEditor bind:value />
