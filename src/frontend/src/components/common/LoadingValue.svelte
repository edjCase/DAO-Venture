<script lang="ts">
  export let value: bigint | string | number | undefined;
</script>

{#if value !== undefined}
  <div>{value}</div>
{:else}
  <div class="animate-pulse h-3.5 bg-gray-700 w-1/12" />
{/if}
