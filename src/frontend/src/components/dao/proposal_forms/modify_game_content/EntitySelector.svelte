<script lang="ts">
  import { Label, Select, SelectOptionType } from "flowbite-svelte";
  import { Readable } from "svelte/store";

  type Entity = {
    id: string;
    name: string;
  };

  export let value: string;
  export let store: Readable<Entity[]>;
  export let label: string;

  let options: SelectOptionType<string>[] = [];

  $: entities = $store;

  $: {
    options =
      entities
        ?.map((e) => ({
          value: e.id,
          name: e.name,
        }))
        .sort((a, b) => a.name.localeCompare(b.name)) || [];
  }
</script>

<Label>{label}</Label>
<Select items={options} bind:value placeholder={"Select " + label} size="lg" />
