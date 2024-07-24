<script lang="ts">
    import { UpdateJobContent } from "../../../../ic-agent/declarations/main";
    import { toJsonString } from "../../../../utils/StringUtil";

    export let content: UpdateJobContent;
</script>

<div>Current Job Id: {content.jobId}</div>
<div>New Job: {toJsonString(content.job)}</div>
