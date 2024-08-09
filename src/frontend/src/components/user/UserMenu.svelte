<script lang="ts">
  import LoginButton from "../common/LoginButton.svelte";
  import { userStore } from "../../stores/UserStore";
  import UserAvatar from "./UserAvatar.svelte";
  import UserPseudonym from "./UserPseudonym.svelte";

  $: user = $userStore;
</script>

<div class="flex flex-col items-center">
  {#if user !== undefined}
    <UserAvatar userId={user.id} size="lg" />
    <div class="font-medium text-center">
      <div>
        <UserPseudonym userId={user.id} />
      </div>
      {#if user.worldData != undefined}
        <div class="text-center text-md font-bold">
          Level: {user.worldData.level}
        </div>
      {/if}
    </div>
  {:else}
    <LoginButton />
  {/if}
</div>
