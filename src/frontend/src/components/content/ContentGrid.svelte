<script lang="ts">
  interface Store {
    subscribe: (run: (value: any[]) => void) => () => void;
    refetch: () => Promise<void>;
  }
  export let label: string;
  export let store: Store;
  export let Component: any;

  $: items = $store;
</script>

<div class="text-2xl font-semibold text-primary-500 text-center">{label}</div>
<div class="flex flex-wrap gap-2 justify-between">
  {#if items !== undefined}
    {#each items as item}
      <div class="border">
        <svelte:component this={Component} value={item} pixelSize={2} />
      </div>
    {/each}
  {/if}
</div>
