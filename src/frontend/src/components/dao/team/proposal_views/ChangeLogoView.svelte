<script lang="ts">
    import { ChangeLogoContent } from "../../../../ic-agent/declarations/teams";

    export let content: ChangeLogoContent;
</script>

<div><img src={content.logoUrl} alt="New Logo" /></div>
