<script lang="ts">
  import { Button } from "flowbite-svelte";
  import { userStore } from "../../stores/UserStore";
  import { toJsonString } from "../../utils/StringUtil";

  $: user = $userStore;

  let login = async () => {
    await userStore.login();
  };
  let logout = async () => {
    await userStore.logout();
  };

  $: {
    console.log("user", toJsonString(user));
  }
</script>

{#if user}
  <Button on:click={logout}>Logout</Button>
{:else}
  <Button on:click={login}>Login</Button>
{/if}
