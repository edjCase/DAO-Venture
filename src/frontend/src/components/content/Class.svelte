<script lang="ts">
  import { Class } from "../../ic-agent/declarations/main";
  import { classStore } from "../../stores/ClassStore";
  import Entity from "./Entity.svelte";

  export let value: Class | string;
  export let pixelSize: number = 1;
</script>

<Entity entity={value} {pixelSize} store={classStore} />
