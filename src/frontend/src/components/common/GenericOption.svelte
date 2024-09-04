<script lang="ts">
  import { Spinner } from "flowbite-svelte";
  import { BadgeCheckOutline } from "flowbite-svelte-icons";

  export let choiceId: string;
  export let selected: boolean;
  export let onSelect: (id: string) => Promise<void>;

  let selecting = false;
  let onOptionSelect = async () => {
    selecting = true;
    try {
      await onSelect(choiceId);
    } finally {
      selecting = false;
    }
  };
  $: classes = `p-4 border rounded w-full`;
</script>

<div class="flex items-center mb-2">
  <div class="w-8">
    {#if selected}
      <BadgeCheckOutline size="md" />
    {:else if selecting}
      <Spinner size="4" />
    {/if}
  </div>
  <button class={classes} on:click={onOptionSelect}>
    <slot />
  </button>
</div>
