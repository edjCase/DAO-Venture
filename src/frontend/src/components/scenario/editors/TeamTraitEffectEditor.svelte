<script lang="ts">
    import { Label, Select } from "flowbite-svelte";
    import TargetTownChooser from "./TargetTownChooser.svelte";
    import TownTraitEditor from "./TownTraitEditor.svelte";
    import { TownTraitEffect } from "../../../ic-agent/declarations/main";

    export let value: TownTraitEffect;

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

<Label>Town</Label>
<TargetTownChooser bind:value={value.town} />
<TownTraitEditor bind:value={value.traitId} />
<Label>Kind</Label>
<Select items={traitKindItems} on:change={onChange} value={selectedKind} />
