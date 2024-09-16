<script lang="ts">
  import { ScenarioEffect } from "../../../../ic-agent/declarations/main";
  import { toJsonString } from "../../../../utils/StringUtil";
  import CharacterAttributeIcon from "../../../character/CharacterAttributeIcon.svelte";

  export let effect: ScenarioEffect;
</script>

<div>
  {#if "attribute" in effect}
    + {effect.attribute.value}
    <CharacterAttributeIcon value={effect.attribute.attribute} />
  {:else}
    NOT IMPLEMENTED Scenario EFFECT: {toJsonString(effect)}
  {/if}
</div>
