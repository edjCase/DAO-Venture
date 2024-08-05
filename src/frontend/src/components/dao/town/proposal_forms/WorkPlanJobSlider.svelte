<script lang="ts">
    import { Label } from "flowbite-svelte";

    export let name: string;
    export let weight: number;
    export let isLocked: boolean;
    export let currentMaxWeight: number;
    export let maxWeight: number;
    export let onChange: () => void;
    export let toggleLock: () => void;
</script>

<div class="mb-4 flex items-center">
    <Label class="block text-sm font-medium w-1/4">
        {name}:
    </Label>
    <input
        type="range"
        bind:value={weight}
        min="1"
        max={isLocked ? maxWeight : currentMaxWeight}
        step="0.1"
        on:input={() => onChange()}
        class="w-1/3 h-2 rounded-lg appearance-none cursor-pointer"
        disabled={isLocked}
    />
    <input
        type="number"
        bind:value={weight}
        on:input={() => onChange()}
        min="0.1"
        max={isLocked ? maxWeight : currentMaxWeight}
        step="0.1"
        class="w-20 mx-2 px-2 py-1 border rounded bg-gray-800 text-white"
    />
    <button
        on:click={() => toggleLock()}
        class={`px-2 py-1 rounded ${isLocked ? "bg-red-500 text-white" : "bg-gray-700"}`}
    >
        {isLocked ? "Unlock" : "Lock"}
    </button>
</div>
