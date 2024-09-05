<script lang="ts">
  import { Achievement } from "../../../../ic-agent/declarations/main";
  import EntityView from "./EntityView.svelte";

  export let achievement: Achievement;
</script>

<div>
  <div>Achievement</div>
  <EntityView entity={achievement} />
</div>
