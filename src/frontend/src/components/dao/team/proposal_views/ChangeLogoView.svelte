<script lang="ts">
    import { ChangeLogoContent } from "../../../../ic-agent/declarations/teams";

    export let content: ChangeLogoContent;
</script>

<div class="flex justify-center">
    <img
        style="width: 100px; height: 100px"
        src={content.logoUrl}
        alt="New Logo"
    />
</div>
