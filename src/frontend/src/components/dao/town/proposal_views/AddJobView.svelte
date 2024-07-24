<script lang="ts">
    import { AddJobContent } from "../../../../ic-agent/declarations/main";
    import { buildJobDescription } from "../../../../utils/ResourceUtil";

    export let content: AddJobContent;
    export let townId: bigint;
</script>

<div>{buildJobDescription(content.job)}</div>
