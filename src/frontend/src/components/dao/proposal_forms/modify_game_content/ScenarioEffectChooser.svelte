<script lang="ts">
  import { Select } from "flowbite-svelte";
  import { ScenarioEffect } from "../../../../ic-agent/declarations/main";
  import ScenarioEffectEditor from "./ScenarioEffectEditor.svelte";

  export let value: ScenarioEffect;

  let effectTypes = [{ value: "attribute", name: "Attribute" }];

  let selectedEffect: string = effectTypes[0].value;

  let updateEffectKind = () => {
    switch (selectedEffect) {
      case "attribute":
        value = { attribute: { value: 1n, attribute: { strength: null } } };
        break;
      default:
        throw new Error("Invalid effect kind: " + selectedEffect);
    }
  };
</script>

<Select
  items={effectTypes}
  bind:value={selectedEffect}
  on:change={updateEffectKind}
/>
<ScenarioEffectEditor bind:value />
