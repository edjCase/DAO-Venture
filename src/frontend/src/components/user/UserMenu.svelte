<script lang="ts">
  import LoginButton from "../common/LoginButton.svelte";
  import { userStore } from "../../stores/UserStore";
  import UserAvatar from "./UserAvatar.svelte";

  $: user = $userStore;
</script>

<div class="flex flex-col items-center">
  {#if user?.data !== undefined}
    <UserAvatar userId={user.id} size="lg" />
  {:else}
    <LoginButton />
  {/if}
</div>
