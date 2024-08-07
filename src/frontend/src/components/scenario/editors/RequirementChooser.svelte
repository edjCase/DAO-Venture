<script lang="ts">
    import { Select, SelectOptionType } from "flowbite-svelte";
    import { Requirement } from "../../../ic-agent/declarations/main";

    export let value: Requirement;
    let requirementKindItems: SelectOptionType<string>[] = [
        {
            name: "size",
            value: "Size",
        },
        {
            name: "age",
            value: "Age",
        },
        {
            name: "gold",
            value: "Gold",
        },
    ];

    let selectedKind = Object.keys(value)[0];

    let onRequirementKindChange = (e: Event) => {
        selectedKind = (e.target as HTMLSelectElement).value;
        let newValue: Requirement;
        switch (selectedKind) {
            case "size":
                newValue = { size: { above: BigInt(1) } };
                break;
            case "age":
                newValue = { age: { above: BigInt(1) } };
                break;
            case "gold":
                newValue = {
                    resource: {
                        kind: { gold: null },
                        range: { above: BigInt(1) },
                    },
                };
                break;
            default:
                console.error(
                    "Not Implemented requirement kind: " + selectedKind,
                );
                return;
        }
        value = newValue;
    };
</script>

<Select
    items={requirementKindItems}
    on:change={onRequirementKindChange}
    value={selectedKind}
/>
