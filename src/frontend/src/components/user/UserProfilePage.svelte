<script lang="ts">
  import LoginButton from "../../components/common/LoginButton.svelte";
  import { userStore } from "../../stores/UserStore";
  import CopyTextButton from "../common/CopyTextButton.svelte";
  import { nanosecondsToDate } from "../../utils/DateUtils";
  import GameHistory from "../game/GameHistory.svelte";
  import UserPseudonym from "./UserPseudonym.svelte";

  $: user = $userStore;
</script>

<div class="bg-gray-800 p-4">
  {#if user}
    <div>
      <span>
        <span class="font-semibold">Id:</span>
        {user.id.toString().substring(0, 6)}...{user.id
          .toString()
          .substring(user.id.toString().length - 6)}
      </span>
      <CopyTextButton value={user.id.toString()} />
    </div>
    <div class="font-medium">
      <span class="font-semibold">Name</span>:
      <UserPseudonym userId={user.id} />
    </div>
    {#if user.data !== undefined}
      <div class="mb-4">
        <span class="font-semibold">Joined</span>:
        {nanosecondsToDate(user.data.createTime).toLocaleDateString()}
      </div>
      <div class="my-4">
        <LoginButton />
      </div>
      <GameHistory />
    {/if}
  {/if}
</div>
