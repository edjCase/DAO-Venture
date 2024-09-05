<script lang="ts">
  import EntityView from "./EntityView.svelte";
  import WeaponView from "./WeaponView.svelte";
  import ActionsView from "./ActionsView.svelte";
  import TraitsView from "./TraitsView.svelte";
  import UnlockRequirementView from "./UnlockRequirementView.svelte";
  import { Class } from "../../../../ic-agent/declarations/main";
  import { weaponStore } from "../../../../stores/WeaponStore";

  export let class_: Class;
  $: weapons = $weaponStore;
  $: weapon = weapons?.find((weapon) => weapon.id === class_.weaponId);
</script>

<div>
  {#if weapon}
    <div>Class</div>
    <EntityView entity={class_} />
    <WeaponView {weapon} />
    <ActionsView actionIds={class_.actionIds} />
    <TraitsView traitIds={class_.startingTraitIds} />
    <UnlockRequirementView value={class_.unlockRequirement} />
  {/if}
</div>
