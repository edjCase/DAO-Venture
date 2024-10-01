<script lang="ts">
  import { LocationKind } from "../../../../ic-agent/declarations/main";
  import { SelectOptionType, Select } from "flowbite-svelte";
  import CommaDelimitedEditor from "./CommaDelimitedEditor.svelte";

  export let value: LocationKind;

  const locationTypes: SelectOptionType<string>[] = [
    { value: "common", name: "Common" },
    { value: "zoneIds", name: "Specific Zones" },
  ];
  let selectedLocationType: string = Object.keys(value)[0];

  let zoneIds: string[] = [];
</script>

<Select items={locationTypes} bind:value={selectedLocationType} />
{#if "zoneIds" in value}
  <CommaDelimitedEditor bind:value={zoneIds} />
{/if}
