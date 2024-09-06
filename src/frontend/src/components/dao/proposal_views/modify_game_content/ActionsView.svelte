<script lang="ts">
  import { actionStore } from "../../../../stores/ActionStore";
  import ActionView from "./ActionView.svelte";

  export let actionIds: string[];

  $: allActions = $actionStore;
  $: actions = allActions?.filter((action) => actionIds.includes(action.id));
</script>

<div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
  {#if actions !== undefined}
    {#each actions as action}
      <ActionView {action} />
    {/each}
  {/if}
</div>
