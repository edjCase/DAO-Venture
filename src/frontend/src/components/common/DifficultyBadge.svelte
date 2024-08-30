<script lang="ts">
  import { Badge } from "flowbite-svelte";
  import { Difficulty } from "../../ic-agent/declarations/main";
  import { toJsonString } from "../../utils/StringUtil";

  export let value: Difficulty;

  let color: "red" | "yellow" | "green" | undefined;
  let text: string;
  $: if ("easy" in value) {
    color = "green";
    text = "Easy";
  } else if ("normal" in value) {
    color = "yellow";
    text = "Normal";
  } else if ("hard" in value) {
    color = "red";
    text = "Hard";
  } else {
    text = "NOT IMPLEMENTED DIFFICULTY " + toJsonString(value);
  }
</script>

<div>
  {#if color !== undefined}
    <Badge {color}>{text}</Badge>
  {/if}
</div>
