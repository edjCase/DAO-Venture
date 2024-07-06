<script lang="ts">
    import { ModifyTeamLinkContent } from "../../../../ic-agent/declarations/main";

    export let content: ModifyTeamLinkContent;
</script>

<div>Name: {content.name}</div>
{#if content.url.length > 0}
    <div>New Url: {content.url[0]}</div>
{:else}
    <div>Remove Url</div>
{/if}
