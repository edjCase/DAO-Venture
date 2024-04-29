<script lang="ts">
    import { Input } from "flowbite-svelte";

    export let value: [number, number, number] = [0, 0, 0];
    export let disabled: boolean = false;
    let stringRgb: string = `#${value[0].toString(16).padStart(2, "0")}${value[1].toString(16).padStart(2, "0")}${value[2].toString(16).padStart(2, "0")}`;

    $: {
        let red = parseInt(stringRgb.slice(1, 3), 16);
        let green = parseInt(stringRgb.slice(3, 5), 16);
        let blue = parseInt(stringRgb.slice(5, 7), 16);
        value = [red, green, blue];
    }
</script>

<div class="my-2 flex items-center gap-4">
    <div>
        <Input
            {disabled}
            type="color"
            bind:value={stringRgb}
            defaultClass="ml-5 h-16 w-16"
        />
    </div>
    <div class="flex-shrink">
        <Input {disabled} type="text" bind:value={stringRgb} />
    </div>
</div>
