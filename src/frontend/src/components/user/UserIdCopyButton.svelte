<script lang="ts">
    import { Principal } from "@dfinity/principal";
    import { Tooltip } from "flowbite-svelte";
    import { CheckSolid, FileCopyOutline } from "flowbite-svelte-icons";

    export let userId: Principal;

    let idCopied = false;

    let copyPrincipal = (userId: Principal) => () => {
        idCopied = true;
        navigator.clipboard.writeText(userId.toString());
        setTimeout(() => {
            idCopied = false;
        }, 2000); // wait for 2 seconds
    };
</script>

<div id="button">
    {#if idCopied}
        <CheckSolid size="lg" />
    {:else}
        <FileCopyOutline on:click={copyPrincipal(userId)} size="lg" />
    {/if}
</div>
<Tooltip trigger="hover" triggeredBy="#button">
    <div>{userId}</div>
</Tooltip>
