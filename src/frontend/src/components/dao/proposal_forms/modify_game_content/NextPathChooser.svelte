<script lang="ts">
  import { Select } from "flowbite-svelte";
  import { NextPathKind } from "../../../../ic-agent/declarations/main";
  import NextPathEditor from "./NextPathEditor.svelte";

  export let value: NextPathKind;

  let items = [
    { value: "none", name: "None" },
    { value: "single", name: "Single" },
    { value: "multi", name: "Multi" },
  ];

  let selectedPath = Object.keys(value)[0];

  let updatePath = () => {
    switch (selectedPath) {
      case "none":
        value = { none: null };
        break;
      case "single":
        value = { single: "" };
        break;
      case "multi":
        value = {
          multi: [
            {
              weight: { value: 1, kind: { raw: null } },
              effects: [],
              description: "",
              pathId: [],
            },
            {
              weight: { value: 1, kind: { raw: null } },
              effects: [],
              description: "",
              pathId: [],
            },
          ],
        };
        break;
      default:
        throw new Error("Invalid path: " + selectedPath);
    }
  };
</script>

<Select {items} bind:value={selectedPath} on:change={updatePath} />
<NextPathEditor bind:value />
