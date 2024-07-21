<script lang="ts">
    import { Label } from "flowbite-svelte";
    import { Requirement } from "../../../ic-agent/declarations/main";
    import RequirementRangeEditor from "./RequirementRangeEditor.svelte";
    import { toJsonString } from "../../../utils/StringUtil";
    export let value: Requirement;
</script>

{#if "size" in value}
    <Label>Size</Label>
    <RequirementRangeEditor value={value.size} />
{:else if "age" in value}
    <Label>Age</Label>
    <RequirementRangeEditor value={value.age} />
{:else if "population" in value}
    <Label>Population</Label>
    <RequirementRangeEditor value={value.population} />
{:else if "currency" in value}
    <Label>Currency</Label>
    <RequirementRangeEditor value={value.currency} />
{:else}
    NOT IMPLEMENTED: {toJsonString(value)}
{/if}
