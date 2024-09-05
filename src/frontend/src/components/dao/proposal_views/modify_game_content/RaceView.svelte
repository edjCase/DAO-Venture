<script lang="ts">
  import EntityView from "./EntityView.svelte";
  import ActionsView from "./ActionsView.svelte";
  import TraitsView from "./TraitsView.svelte";
  import UnlockRequirementView from "./UnlockRequirementView.svelte";

  export let race;
</script>

<div>
  <div>Race</div>
  <EntityView entity={race} />
  <ActionsView actionIds={race.actionIds} />
  <TraitsView traitIds={race.actionIds} />
  <UnlockRequirementView value={race.unlockRequirement} />
</div>
