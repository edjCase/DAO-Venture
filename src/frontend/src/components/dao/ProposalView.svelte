<script lang="ts">
  import { WorldProposal } from "../../ic-agent/declarations/main";
  import { toJsonString } from "../../utils/StringUtil";
  import ModifyGameContentView from "./proposal_views/ModifyGameContentView.svelte";
  import MotionView from "./proposal_views/MotionView.svelte";

  export let proposal: WorldProposal;

  const components: Record<string, any> = {
    motion: MotionView,
    modifyGameContent: ModifyGameContentView,
  };

  $: type = Object.keys(proposal.content as any)[0];
  $: SelectedComponent = components[type];
  $: content = (proposal.content as any)[type];
</script>

{#if !SelectedComponent}
  Not Implemented View: <pre>{toJsonString(proposal.content)}</pre>
{:else}
  <svelte:component this={SelectedComponent} {content} />
{/if}
