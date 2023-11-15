<script lang="ts">
  import { identityStore } from "../stores/IdentityStore";

  $: identity = $identityStore;

  let login = async () => {
    await identityStore.login();
  };
  let logout = async () => {
    await identityStore.logout();
  };
</script>

{#if identity}
  <button class="button-style" on:click={logout}>Logout</button>
{:else}
  <button class="button-style" on:click={login}>Login</button>
{/if}
