<script lang="ts">
    import { Button, Input, Label } from "flowbite-svelte";
    import BigIntInput from "./BigIntInput.svelte";
    import { TrashBinSolid } from "flowbite-svelte-icons";

    export let value:
        | { fixed: bigint }
        | {
              weightedChance: {
                  weight: bigint;
                  value: bigint;
                  description: string;
              }[];
          };

    let add = () => {
        if ("weightedChance" in value) {
            value.weightedChance.push({
                weight: BigInt(1),
                value: BigInt(1),
                description: "",
            });
            value.weightedChance = value.weightedChance;
        }
    };

    let remove = (i: number) => {
        if ("weightedChance" in value) {
            value.weightedChance.splice(i, 1);
            value.weightedChance = value.weightedChance;
        }
    };
</script>

{#if "fixed" in value}
    <Label>Value</Label>
    <BigIntInput bind:value={value.fixed} />
{:else if "weightedChance" in value}
    <div class="ml-4">
        {#each value.weightedChance as weightedOption, i}
            <Label>Description</Label>
            <Input type="text" bind:value={weightedOption.description} />
            <Label>Weight</Label>
            <BigIntInput bind:value={weightedOption.weight} />
            <Label>Value</Label>
            <BigIntInput bind:value={weightedOption.value} />
            <button on:click={() => remove(i)}>
                <TrashBinSolid size="sm" />
            </button>
        {/each}
        <Button on:click={add}>Add</Button>
    </div>
{/if}
