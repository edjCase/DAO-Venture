<script lang="ts">
  export let items: any[] | undefined;
  export let Component: any;
  export let propName: string = "value";
</script>

<div class="flex flex-wrap gap-2 justify-between">
  {#if items !== undefined}
    {#each items as item}
      <div class="border">
        <svelte:component
          this={Component}
          {...{ [propName]: item }}
          pixelSize={2}
        />
      </div>
    {/each}
  {/if}
</div>
