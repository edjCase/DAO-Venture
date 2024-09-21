<script lang="ts">
  import { Zone } from "../../ic-agent/declarations/main";
  import { zoneStore } from "../../stores/ZoneStore";
  import Entity from "./Entity.svelte";

  export let value: Zone | string;
  export let pixelSize: number = 1;
</script>

<Entity entity={value} {pixelSize} store={zoneStore} />
