<script lang="ts">
  import { Trait } from "../../ic-agent/declarations/main";

  export let traits: Trait[];
</script>

<div class="border p-6">
  <ul class="text-md">
    {#each traits as trait}
      <li>{trait.name} - {trait.description}</li>
    {/each}
  </ul>
</div>
