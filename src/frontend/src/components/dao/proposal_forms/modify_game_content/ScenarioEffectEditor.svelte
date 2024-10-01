<script lang="ts">
  import { ScenarioEffect } from "../../../../ic-agent/declarations/main";
  import { toJsonString } from "../../../../utils/StringUtil";
  import BigIntInput from "../../../common/BigIntInput.svelte";
  import CharacterAttributeChooser from "./CharacterAttributeChooser.svelte";
  export let value: ScenarioEffect;
</script>

{#if "attribute" in value}
  <div class="flex">
    <BigIntInput bind:value={value.attribute.value} />
    <CharacterAttributeChooser bind:value={value.attribute.attribute} />
  </div>
{:else}
  NOT IMPLEMENETED SCENARIO EFFECT : {toJsonString(value)}
{/if}
