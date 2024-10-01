<script lang="ts">
  import { Select } from "flowbite-svelte";
  import { PathEffect } from "../../../../ic-agent/declarations/main";
  import PathEffectEditor from "./PathEffectEditor.svelte";

  export let value: PathEffect;

  let items = [
    { value: "damage", name: "Damage" },
    { value: "heal", name: "Heal" },
    { value: "removeGold", name: "Remove Gold" },
    { value: "addItem", name: "Add Item" },
    { value: "removeItem", name: "Remove Item" },
    { value: "addItemWithTags", name: "Add Item With Tags" },
    { value: "removeItemWithTags", name: "Remove Item With Tags" },
  ];

  let selectedEffect = Object.keys(value)[0];

  function updateEffect() {
    switch (selectedEffect) {
      case "damage":
        value = { damage: { raw: 3n } };
        break;
      case "heal":
        value = { heal: { raw: 3n } };
        break;
      case "removeGold":
        value = { removeGold: { raw: 3n } };
        break;
      case "addItem":
        value = { addItem: "" };
        break;
      case "removeItem":
        value = { removeItem: "" };
        break;
      case "addItemWithTags":
        value = { addItemWithTags: [] };
        break;
      case "removeItemWithTags":
        value = { removeItemWithTags: [] };
    }
  }
</script>

<div>
  <Select {items} bind:value={selectedEffect} on:change={updateEffect} />
  <PathEffectEditor bind:value />
</div>
