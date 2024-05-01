<script lang="ts">
    import { Input } from "flowbite-svelte";

    export let value: bigint;

    let numValue = Number(value);

    $: value = BigInt(value);
</script>

<Input type="number" bind:value={numValue} />
