<script lang="ts">
  import { MultiSelect, SelectOptionType } from "flowbite-svelte";
  import { Readable } from "svelte/store";

  type Entity = {
    id: string;
    name: string;
  };

  export let ids: string[];
  export let store: Readable<Entity[]>;
  export let label: string;

  let options: SelectOptionType<string>[] = [];

  $: entities = $store;

  $: {
    options =
      entities?.map((e) => ({
        value: e.id,
        name: e.name,
      })) || [];
  }
</script>

<MultiSelect
  items={options}
  bind:value={ids}
  placeholder={"Select " + label}
  size="lg"
/>
