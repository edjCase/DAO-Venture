<script lang="ts">
    import { Select } from "flowbite-svelte";
    import { TargetTown } from "../../../ic-agent/declarations/main";
    import { townStore } from "../../../stores/TownStore";

    export let value: TargetTown;
    $: towns = $townStore;
    $: townItems =
        towns?.map((town) => ({ value: town.id, name: town.name })) ?? [];
</script>

{#if "random" in value}
    <div></div>
{:else if "chosen" in value}
    <Select items={townItems} bind:value={value.chosen} />
{:else if "contextual" in value}
    <div></div>
{:else if "all" in value}
    <div></div>
{:else}
    NOT IMPLEMENTED : {JSON.stringify(value)}
{/if}
