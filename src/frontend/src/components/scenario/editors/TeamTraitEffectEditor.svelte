<script lang="ts">
    import { Label, Select } from "flowbite-svelte";
    import TargetTeamChooser from "./TargetTeamChooser.svelte";
    import TeamTraitEditor from "./TeamTraitEditor.svelte";
    import { TeamTraitEffect } from "../../../ic-agent/declarations/main";

    export let value: TeamTraitEffect;

    $: selectedKind = Object.keys(value.kind)[0];

    let onChange = (e: Event) => {
        selectedKind = (e.target as HTMLSelectElement).value;
        if (selectedKind == "add") {
            value.kind = { add: null };
        } else if (selectedKind == "remove") {
            value.kind = { remove: null };
        }
    };
    let traitKindItems = [
        {
            value: "add",
            name: "Add",
        },
        {
            value: "remove",
            name: "Remove",
        },
    ];
</script>

<Label>Team</Label>
<TargetTeamChooser bind:value={value.target} />
<TeamTraitEditor bind:value={value.traitId} />
<Label>Kind</Label>
<Select items={traitKindItems} on:change={onChange} value={selectedKind} />
