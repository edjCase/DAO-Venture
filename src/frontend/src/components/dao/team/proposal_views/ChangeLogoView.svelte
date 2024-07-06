<script lang="ts">
    import { ChangeTeamLogoContent } from "../../../../ic-agent/declarations/main";

    export let content: ChangeTeamLogoContent;
</script>

<div class="flex justify-center">
    <img
        style="width: 100px; height: 100px"
        src={content.logoUrl}
        alt="New Logo"
    />
</div>
