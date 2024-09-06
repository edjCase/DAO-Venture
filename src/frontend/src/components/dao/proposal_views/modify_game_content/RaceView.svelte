<script lang="ts">
  import EntityView from "./EntityView.svelte";
  import ActionsView from "./ActionsView.svelte";
  import ItemsView from "./ItemsView.svelte";
  import UnlockRequirementView from "./UnlockRequirementView.svelte";

  export let race;
</script>

<div>
  <div>Race</div>
  <EntityView entity={race} />
  <ActionsView actionIds={race.actionIds} />
  <ItemsView itemIds={race.startingItemIds} />
  <UnlockRequirementView value={race.unlockRequirement} />
</div>
