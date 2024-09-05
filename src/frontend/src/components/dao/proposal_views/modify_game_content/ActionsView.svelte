<script lang="ts">
  import { actionStore } from "../../../../stores/ActionStore";
  import ActionView from "./ActionView.svelte";

  export let actionIds: string[];

  $: allAction = $actionStore;
  $: actions = allAction.filter((action) => actionIds.includes(action.id));
</script>

<div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
  {#each actions as action}
    <ActionView {action} />
  {/each}
</div>
