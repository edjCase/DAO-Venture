<script lang="ts">
  import { Weapon } from "../../ic-agent/declarations/main";
  import { weaponStore } from "../../stores/WeaponStore";
  import Entity from "./Entity.svelte";

  export let weapon: Weapon | string;
  export let pixelSize: number = 1;
</script>

<Entity entity={weapon} {pixelSize} store={weaponStore} />
