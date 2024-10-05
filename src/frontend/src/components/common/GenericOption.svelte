<script lang="ts">
  import { Spinner } from "flowbite-svelte";

  export let onSelect: () => Promise<void>;

  let selecting = false;
  let onOptionSelect = async () => {
    selecting = true;
    try {
      await onSelect();
    } finally {
      selecting = false;
    }
  };
  $: classes = `p-4 border w-full`;
</script>

<div class="flex items-center mb-2">
  <div class="w-8">
    {#if selecting}
      <Spinner size="4" />
    {/if}
  </div>
  <button class={classes} on:click={onOptionSelect}>
    <slot />
  </button>
</div>
