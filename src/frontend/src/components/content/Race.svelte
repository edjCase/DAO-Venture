<script lang="ts">
  import { Race } from "../../ic-agent/declarations/main";
  import { raceStore } from "../../stores/RaceStore";
  import Entity from "./Entity.svelte";

  export let value: Race | string;
  export let pixelSize: number = 1;
</script>

<Entity entity={value} {pixelSize} store={raceStore} entityType="Race" />
