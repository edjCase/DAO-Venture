<script lang="ts">
    import { Input, Label } from "flowbite-svelte";
    import { RangeRequirement } from "../../../ic-agent/declarations/main";

    export let value: RangeRequirement;
</script>

{#if "above" in value}
    <Label>Above</Label>
    <Input type="number" bind:value={value.above} />
{:else if "below" in value}
    <Label>Below</Label>
    <Input type="number" bind:value={value.below} />
{:else}
    NOT IMPLEMENTED: {JSON.stringify(value)}
{/if}
