<script lang="ts">
  import { Tooltip } from "flowbite-svelte";
  import { CheckSolid, FileCopyOutline } from "flowbite-svelte-icons";

  export let value: string;
  export let tooltip: boolean = false;
  export let size: "xs" | "sm" | "md" | "lg" | "xl" | undefined = undefined;

  let copied = false;

  let copyValue = () => {
    copied = true;
    navigator.clipboard.writeText(value);
    setTimeout(() => {
      copied = false;
    }, 2000); // wait for 2 seconds
  };
</script>

<div class="cursor-pointer inline-block">
  {#if copied}
    <CheckSolid {size} />
  {:else}
    <FileCopyOutline on:click={copyValue} {size} />
  {/if}
</div>
{#if tooltip}
  <Tooltip trigger="hover">
    <div>{value}</div>
  </Tooltip>
{/if}
