<script lang="ts">
    import { AddJobContent } from "../../../../ic-agent/declarations/main";
    import { toJsonString } from "../../../../utils/StringUtil";

    export let content: AddJobContent;
</script>

<div>New Job: {toJsonString(content.job)}</div>
