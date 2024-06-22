<script lang="ts">
    import { TrashBinSolid } from "flowbite-svelte-icons";
    import { TraitRequirement } from "../../../ic-agent/declarations/league";
    import TraitRequirementEditor from "./TraitRequirementEditor.svelte";
    import { Button } from "flowbite-svelte";
    export let value: TraitRequirement[];
</script>

<div class="ml-4">
    {#each value as traitRequirement, i}
        <TraitRequirementEditor bind:value={traitRequirement} />
        <button
            on:click={() => {
                value = value.slice(i, 1);
            }}
        >
            <TrashBinSolid size="sm" />
        </button>
    {/each}
    <Button
        on:click={() => {
            value = [
                ...value,
                {
                    id: "",
                    kind: { required: null },
                },
            ];
        }}
    >
        Add Requirement
    </Button>
</div>
