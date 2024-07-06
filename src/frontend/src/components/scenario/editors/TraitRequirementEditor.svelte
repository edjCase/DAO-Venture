<script lang="ts">
    import { Select } from "flowbite-svelte";
    import { TraitRequirement } from "../../../ic-agent/declarations/main";
    import TeamTraitEditor from "./TeamTraitEditor.svelte";
    export let value: TraitRequirement;
    let requirementKindItems = [
        {
            value: "required",
            name: "Required",
        },
        {
            value: "prohibited",
            name: "Prohibited",
        },
    ];

    let selectedKind = Object.keys(value.kind)[0];

    let onRequirementKindChange = (e: Event) => {
        selectedKind = (e.target as HTMLSelectElement).value;
        let newValue;
        switch (selectedKind) {
            case "required":
                newValue = { required: null };
                break;
            case "prohibited":
                newValue = { prohibited: null };
                break;
            default:
                console.error(
                    "Not Implemented requirement kind: " + selectedKind,
                );
                return;
        }
        value.kind = newValue;
    };
</script>

<TeamTraitEditor bind:value={value.id} />
<Select
    items={requirementKindItems}
    on:change={onRequirementKindChange}
    value={selectedKind}
/>
