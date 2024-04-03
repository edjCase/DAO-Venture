<script lang="ts">
    import { ModifyLinkContent } from "../../../../ic-agent/declarations/teams";

    export let content: ModifyLinkContent;
</script>

<div>Name: {content.name}</div>
{#if content.url.length > 0}
    <div>New Url: {content.url[0]}</div>
{:else}
    <div>Remove Url</div>
{/if}
