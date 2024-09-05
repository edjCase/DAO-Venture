<script lang="ts">
  import EntityView from "./EntityView.svelte";
  import UnlockRequirementView from "./UnlockRequirementView.svelte";
  import ActionsView from "./ActionsView.svelte";
  import { Weapon } from "../../../../ic-agent/declarations/main";

  export let weapon: Weapon;
</script>

<div>
  <div>Weapon</div>
  <EntityView entity={weapon} />
  <UnlockRequirementView value={weapon.unlockRequirement} />
  <ActionsView actionIds={weapon.actionIds} />
</div>
