<script lang="ts">
  import { RewardPath } from "../../../../ic-agent/declarations/main";
  import NextPathChooser from "./NextPathChooser.svelte";
  import { Label } from "flowbite-svelte";
  export let value: RewardPath;
</script>

<div>TODO</div>

<Label>Next Path</Label>
<NextPathChooser bind:value={value.nextPath} />
