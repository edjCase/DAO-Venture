<script lang="ts">
    import { Input } from "flowbite-svelte";

    export let value: bigint | undefined;

    let numValue = value === undefined ? undefined : Number(value);

    $: value = numValue === undefined ? undefined : BigInt(numValue);
</script>

<Input type="number" bind:value={numValue} />
