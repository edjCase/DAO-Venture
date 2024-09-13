<script lang="ts">
  import { Input } from "flowbite-svelte";

  export let value: bigint;
  let numberValue = Number(value);

  let updateValue = () => {
    value = BigInt(numberValue);
  };
</script>

<Input type="number" bind:value={numberValue} on:change={updateValue} />
