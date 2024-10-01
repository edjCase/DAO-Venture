<script lang="ts">
  import { CombatPath } from "../../../../ic-agent/declarations/main";
  import CombatCreatureKindChooser from "./CombatCreatureKindChooser.svelte";
  import NextPathChooser from "./NextPathChooser.svelte";
  import { Label } from "flowbite-svelte";
  export let value: CombatPath;
</script>

<Label>Creatures</Label>
<div>
  {#each value.creatures as creature}
    <CombatCreatureKindChooser bind:value={creature} />
  {/each}
</div>

<Label>Next Path</Label>
<NextPathChooser bind:value={value.nextPath} />
