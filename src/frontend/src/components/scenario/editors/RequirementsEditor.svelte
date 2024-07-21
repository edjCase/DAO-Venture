<script lang="ts">
    import { TrashBinSolid } from "flowbite-svelte-icons";
    import { Requirement } from "../../../ic-agent/declarations/main";
    import RequirementEditor from "./RequirementEditor.svelte";
    import { Button } from "flowbite-svelte";
    export let value: Requirement[];
</script>

<div class="ml-4">
    {#each value as traitRequirement, i}
        <RequirementEditor bind:value={traitRequirement} />
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
                    age: { above: BigInt(0) },
                },
            ];
        }}
    >
        Add Requirement
    </Button>
</div>
