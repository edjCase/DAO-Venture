<script lang="ts">
  import { Label, Select, SelectOptionType } from "flowbite-svelte";
  import { ActionTarget } from "../../../../ic-agent/declarations/main";
  import BigIntInput from "../../../common/BigIntInput.svelte";

  export let value: ActionTarget;

  const targetScopes: SelectOptionType<string>[] = [
    { value: "enemy", name: "Enemy" },
    { value: "any", name: "Any" },
    { value: "ally", name: "Ally" },
  ];
  let selectedScope: string = Object.keys(value.scope)[0];

  const targetSelections: SelectOptionType<string>[] = [
    { value: "chosen", name: "Chosen" },
    { value: "all", name: "All" },
    { value: "random", name: "Random" },
  ];

  let selectedSelection: string = Object.keys(value.selection)[0];

  const updateScope = () => {
    if (selectedScope === "enemy") {
      value.scope = { enemy: null };
    } else if (selectedScope === "any") {
      value.scope = { any: null };
    } else if (selectedScope === "ally") {
      value.scope = { ally: null };
    }
  };

  const updateSelection = () => {
    if (selectedSelection === "chosen") {
      value.selection = { chosen: null };
    } else if (selectedSelection === "all") {
      value.selection = { all: null };
    } else if (selectedSelection === "random") {
      value.selection = { random: { count: 1n } };
    }
  };
</script>

<Label>Target</Label>
<div class="flex gap-4">
  <div class="flex-1">
    <Label for="targetScope">Scope</Label>
    <Select
      id="targetScope"
      items={targetScopes}
      on:change={updateScope}
      bind:value={selectedScope}
    />
  </div>
  <div class="flex-1">
    <Label>Selection</Label>
    <Select
      items={targetSelections}
      on:change={updateSelection}
      bind:value={selectedSelection}
    />
  </div>
</div>
{#if "random" in value.selection}
  <div class="mt-2">
    <Label>Random Count</Label>
    <BigIntInput bind:value={value.selection.random.count} />
  </div>
{/if}
