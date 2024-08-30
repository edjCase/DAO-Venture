<script lang="ts">
  import { Button } from "flowbite-svelte";
  import { userStore } from "../../stores/UserStore";

  export let onLogin: (() => void) | undefined = undefined;

  $: user = $userStore;

  let login = async () => {
    await userStore.login();
    if (onLogin) {
      onLogin();
    }
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
