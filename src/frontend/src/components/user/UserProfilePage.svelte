<script lang="ts">
  import LoginButton from "../../components/common/LoginButton.svelte";
  import { userStore } from "../../stores/UserStore";
  import CopyTextButton from "../common/CopyTextButton.svelte";
  import { nanosecondsToDate } from "../../utils/DateUtils";
  import GameHistory from "../game/GameHistory.svelte";
  import UserPseudonym from "./UserPseudonym.svelte";
  import UserAvatar from "./UserAvatar.svelte";

  $: user = $userStore;
</script>

<h1 class="text-5xl font-semibold text-primary-500 my-4 text-center">
  User Profile
</h1>
<div class="p-4 mb-4 flex justify-between">
  {#if user}
    <div>
      <div>
        <span>
          <span class="font-semibold">Id:</span>
          {user.id.toString().substring(0, 6)}...{user.id
            .toString()
            .substring(user.id.toString().length - 6)}
        </span>
        <CopyTextButton value={user.id.toString()} />
      </div>
      <div class="flex items-center gap-2">
        Avatar: <UserAvatar userId={user.id} />
      </div>
      <div class="font-medium">
        <span class="font-semibold">Name</span>:
        <UserPseudonym userId={user.id} />
      </div>
      <div>
        <span class="font-semibold">Joined</span>:
        {nanosecondsToDate(user.data.createTime).toLocaleDateString()}
      </div>
    </div>
    <div class="mt-4">
      <LoginButton />
    </div>
  {:else}
    <div class="flex justify-center w-full">
      <LoginButton />
    </div>
  {/if}
</div>
{#if user}
  <GameHistory />
{/if}
