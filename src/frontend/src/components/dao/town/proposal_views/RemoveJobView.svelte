<script lang="ts">
    import { RemoveJobContent } from "../../../../ic-agent/declarations/main";
    import { townStore } from "../../../../stores/TownStore";
    import { buildJobDescription } from "../../../../utils/ResourceUtil";

    export let content: RemoveJobContent;
    export let townId: bigint;

    $: towns = $townStore;
    $: town = towns?.find((t) => t.id == townId);
    $: job = town?.jobs[Number(content.jobId)];
</script>

<div>Job Id: {content.jobId}</div>
{#if job !== undefined}
    <div>{buildJobDescription(job)}</div>
{/if}
