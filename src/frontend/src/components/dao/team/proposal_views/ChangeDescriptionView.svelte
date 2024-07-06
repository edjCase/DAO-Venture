<script lang="ts">
    import { ChangeTeamDescriptionContent } from "../../../../ic-agent/declarations/main";

    export let content: ChangeTeamDescriptionContent;
</script>

<div>New Description: {content.description}</div>
