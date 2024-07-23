<script lang="ts">
    import { Button, Input, Label } from "flowbite-svelte";
    import BigIntInput from "./BigIntInput.svelte";
    import { Effect } from "../../../ic-agent/declarations/main";
    import { toJsonString } from "../../../utils/StringUtil";
    import { TrashBinSolid } from "flowbite-svelte-icons";
    import ScenarioEffectChooser from "./ScenarioEffectChooser.svelte";
    import TargetTownChooser from "./TargetTownChooser.svelte";
    import ResourceKindChooser from "./ResourceKindChooser.svelte";
    export let value: Effect;

    let addOption = () => {
        if ("allOf" in value) {
            value.allOf.push({ noEffect: null });
            value.allOf = value.allOf;
        } else if ("oneOf" in value) {
            value.oneOf.push({
                weight: BigInt(1),
                effect: { noEffect: null },
                description: "",
            });
            value.oneOf = value.oneOf;
        }
    };

    let remove = (i: number) => {
        if ("allOf" in value) {
            value.allOf.splice(i, 1);
            value.allOf = value.allOf;
        } else if ("oneOf" in value) {
            value.oneOf.splice(i, 1);
            value.oneOf = value.oneOf;
        }
    };
</script>

{#if "allOf" in value}
    <div class="ml-6 border rounded">
        {#each value.allOf as innerEffect, i}
            <ScenarioEffectChooser bind:value={innerEffect} />
            <button on:click={() => remove(i)}>
                <TrashBinSolid size="sm" />
            </button>
        {/each}
        <Button on:click={addOption}>Add Option</Button>
    </div>
{:else if "oneOf" in value}
    <div class="ml-6 border rounded">
        {#each value.oneOf as innerEffect}
            <Label>Description</Label>
            <Input type="text" bind:value={innerEffect.description} />
            <Label>Weight</Label>
            <BigIntInput bind:value={innerEffect.weight} />
            <ScenarioEffectChooser bind:value={innerEffect.effect} />
        {/each}
        <Button on:click={addOption}>Add Option</Button>
    </div>
{:else if "entropy" in value}
    <Label>Amount</Label>
    <BigIntInput bind:value={value.entropy.delta} />
    <TargetTownChooser bind:value={value.entropy.town} />
{:else if "resource" in value}
    <ResourceKindChooser bind:value={value.resource.kind} />
    <Label>Amount</Label>
    <BigIntInput bind:value={value.resource.value.flat} />
    <Label>Town</Label>
    <TargetTownChooser bind:value={value.resource.town} />
{:else if "noEffect" in value}
    <div></div>
{:else}
    NOT IMPLEMENTED : {toJsonString(value)}
{/if}
