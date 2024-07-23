<script lang="ts">
    import { Button } from "flowbite-svelte";
    import { ResourceCost } from "../../../ic-agent/declarations/main";
    import { TrashBinSolid } from "flowbite-svelte-icons";
    import BigIntInput from "./BigIntInput.svelte";
    import ResourceKindChooser from "./ResourceKindChooser.svelte";

    export let value: ResourceCost[];

    let addResourceCost = () => {
        value.push({ kind: { gold: null }, amount: BigInt(1) });
    };

    let removeResourceCost = (j: number) => () => {
        value.splice(j, 1);
    };
</script>

{#each value as cost, j}
    <ResourceKindChooser bind:value={cost.kind} />
    <BigIntInput bind:value={cost.amount} />
    <button on:click={removeResourceCost(j)}>
        <TrashBinSolid size="sm" />
    </button>
{/each}
<Button on:click={addResourceCost}>Add Option</Button>
