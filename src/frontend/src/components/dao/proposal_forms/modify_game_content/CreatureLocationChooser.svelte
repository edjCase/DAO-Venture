<script lang="ts">
  import { Label, Select } from "flowbite-svelte";
  import { CreatureLocationKind } from "../../../../ic-agent/declarations/main";
  import TagsEditor from "./CommaDelimitedEditor.svelte";

  export let value: CreatureLocationKind;

  let locationTypes = [
    { value: "common", name: "Common", location: { common: null } },
    { value: "zoneIds", name: "Specific Zones", location: { zoneIds: [] } },
  ];
  let selectedLocationType: string = Object.keys(value)[0];

  let updateLocation = () => {
    if (selectedLocationType === "zoneIds") {
      value = { zoneIds: [] };
    } else if (selectedLocationType === "common") {
      value = { common: null };
    }
  };
</script>

<Select
  id="location"
  items={locationTypes}
  bind:value={selectedLocationType}
  on:change={updateLocation}
/>

{#if "zoneIds" in value}
  <div>
    <Label for="zoneIds">Zone Ids (comma-separated)</Label>
    <TagsEditor value={value.zoneIds} />
  </div>
{/if}
