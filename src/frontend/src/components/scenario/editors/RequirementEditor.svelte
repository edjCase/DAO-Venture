<script lang="ts">
    import { Label } from "flowbite-svelte";
    import { Requirement } from "../../../ic-agent/declarations/main";
    import RequirementRangeEditor from "./RequirementRangeEditor.svelte";
    import { toJsonString } from "../../../utils/StringUtil";
    import ResourceIcon from "../../icons/ResourceIcon.svelte";
    export let value: Requirement;
</script>

{#if "size" in value}
    <Label>Size</Label>
    <RequirementRangeEditor value={value.size} />
{:else if "age" in value}
    <Label>Age</Label>
    <RequirementRangeEditor value={value.age} />
{:else if "resource" in value}
    <Label><ResourceIcon kind={value.resource.kind} /></Label>
    <RequirementRangeEditor value={value.resource.range} />
{:else}
    NOT IMPLEMENTED: {toJsonString(value)}
{/if}
