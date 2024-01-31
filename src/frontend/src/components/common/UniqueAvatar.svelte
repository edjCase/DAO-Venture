<script lang="ts">
  import { toSvg } from "jdenticon";

  export let id: any;
  export let size: number;
</script>

{@html toSvg(id, size)}
