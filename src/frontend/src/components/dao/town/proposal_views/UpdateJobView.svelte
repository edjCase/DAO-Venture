<script lang="ts">
    import { UpdateJobContent } from "../../../../ic-agent/declarations/main";
    import { townStore } from "../../../../stores/TownStore";
    import { buildJobDescription } from "../../../../utils/ResourceUtil";

    export let content: UpdateJobContent;
    export let townId: bigint;

    $: towns = $townStore;
    $: town = towns?.find((t) => t.id == townId);
    $: job = town?.jobs[Number(content.jobId)];
</script>

<div>Job Id: {content.jobId}</div>
<!-- TODO only show this before execution, not a snapshot -->
{#if job !== undefined}
    <div>Current</div>
    <div>{buildJobDescription(job)}</div>
{/if}
<div>New</div>
<div>{buildJobDescription(content.job)}</div>
