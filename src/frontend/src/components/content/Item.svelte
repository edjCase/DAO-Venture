<script lang="ts">
  import { Item } from "../../ic-agent/declarations/main";
  import { itemStore } from "../../stores/ItemStore";
  import Entity from "./Entity.svelte";

  export let item: Item | string;
  export let pixelSize: number = 1;
</script>

<Entity entity={item} {pixelSize} store={itemStore} entityType="Item" />
