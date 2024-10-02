<script lang="ts">
  import { Creature } from "../../ic-agent/declarations/main";
  import { classStore } from "../../stores/ClassStore";
  import Entity from "./Entity.svelte";

  export let value: Creature | string;
  export let pixelSize: number = 1;
</script>

<Entity entity={value} {pixelSize} store={classStore} entityType="Creature" />
