<script lang="ts">
  import { traitStore } from "../../../../stores/TraitStore";
  import TraitView from "./TraitView.svelte";

  export let traitIds: string[];

  $: allTraits = $traitStore;
  $: traits = allTraits?.filter((trait) => traitIds.includes(trait.id));
</script>

<div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
  {#if traits !== undefined}
    {#each traits as trait}
      <TraitView {trait} />
    {/each}
  {/if}
</div>
