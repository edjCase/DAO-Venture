<script lang="ts">
  import EntityView from "./EntityView.svelte";
  import WeaponView from "./WeaponView.svelte";
  import ActionsView from "./ActionsView.svelte";
  import ItemsView from "./ItemsView.svelte";
  import UnlockRequirementView from "./UnlockRequirementView.svelte";
  import { Class } from "../../../../ic-agent/declarations/main";
  import { weaponStore } from "../../../../stores/WeaponStore";
  import PixelArtCanvas from "../../../common/PixelArtCanvas.svelte";
  import { decodeImageToPixels } from "../../../../utils/PixelUtil";

  export let class_: Class;
  $: weapons = $weaponStore;
  $: weapon = weapons?.find((weapon) => weapon.id === class_.weaponId);

  $: layers = [decodeImageToPixels(class_.image, 32, 32)];
</script>

<div>
  <div>Class</div>
  <EntityView entity={class_} />
  {#if weapon}
    <WeaponView {weapon} />
  {/if}
  <PixelArtCanvas {layers} pixelSize={2} />
  <ActionsView actionIds={class_.startingSkillActionIds} />
  <ItemsView itemIds={class_.startingItemIds} />
  <UnlockRequirementView value={class_.unlockRequirement} />
</div>
