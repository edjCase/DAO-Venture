<script lang="ts">
  import EntityView from "./EntityView.svelte";
  import UnlockRequirementView from "./UnlockRequirementView.svelte";

  export let zone;
</script>

<div>
  <div>Zone</div>
  <EntityView entity={zone} />
  <UnlockRequirementView value={zone.unlockRequirement} />
</div>
