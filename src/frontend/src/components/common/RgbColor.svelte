<script lang="ts">
    import { Input } from "flowbite-svelte";

    export let red: number;
    export let green: number;
    export let blue: number;
    $: rgb = `#${red.toString(16).padStart(2, "0")}${green
        .toString(16)
        .padStart(2, "0")}${blue.toString(16).padStart(2, "0")}`;
</script>

<div
    class="my-2"
    style="display: grid; grid-template-columns: auto auto; align-items: center; gap: 10px;"
>
    <span
        class="mx-2"
        style="width: 50px; height: 50px; background-color: {rgb};"
    ></span>
    <Input disabled type="text" value={rgb} />
</div>
