<script lang="ts">
  import { TraitState } from "../../ic-agent/declarations/main";

  export let traits: TraitState[];
</script>

<div class="border p-6">
  <ul class="text-md">
    {#each traits as trait}
      <li>{trait.name} - {trait.description}</li>
    {/each}
  </ul>
</div>
