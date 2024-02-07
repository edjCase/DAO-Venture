<script lang="ts">
  import { Button } from "flowbite-svelte";
  import { userStore } from "../../stores/UserStore";

  $: user = $userStore;

  let login = async () => {
    await userStore.login();
  };
  let logout = async () => {
    await userStore.logout();
  };
</script>

{#if user}
  <Button on:click={logout}>Logout</Button>
{:else}
  <Button on:click={login}>Login</Button>
{/if}
