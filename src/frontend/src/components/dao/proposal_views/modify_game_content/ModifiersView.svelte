<script lang="ts">
  import { CharacterModifier } from "../../../../ic-agent/declarations/main";
  import ModifierView from "./ModifierView.svelte";

  export let value: CharacterModifier[];
</script>

<div>Modifiers:</div>
<ul>
  {#each value as modifier}
    <li><ModifierView value={modifier} /></li>
  {/each}
</ul>
