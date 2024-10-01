<script lang="ts">
  import EntityView from "./EntityView.svelte";
  import UnlockRequirementView from "./UnlockRequirementView.svelte";

  export let zone;
</script>

<div>
  <div class="text-primary-500 font-bold text-xl">Zone</div>
  <EntityView entity={zone} />
  <div class="text-primary-500">Unlock Requirement</div>
  <UnlockRequirementView value={zone.unlockRequirement} />
</div>
