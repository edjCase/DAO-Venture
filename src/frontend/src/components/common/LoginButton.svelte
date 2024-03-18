<script lang="ts">
  import { Button } from "flowbite-svelte";
  import { identityStore } from "../../stores/IdentityStore";

  $: identity = $identityStore;

  let login = async () => {
    await identityStore.login();
  };
  let logout = async () => {
    await identityStore.logout();
  };
</script>

{#if !identity.getPrincipal().isAnonymous()}
  <Button on:click={logout}>Logout</Button>
{:else}
  <Button on:click={login}>Login</Button>
{/if}
