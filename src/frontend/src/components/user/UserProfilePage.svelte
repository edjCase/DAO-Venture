<script lang="ts">
  import LoginButton from "../../components/common/LoginButton.svelte";
  import { userStore } from "../../stores/UserStore";
  import CopyTextButton from "../common/CopyTextButton.svelte";
  import { nanosecondsToDate } from "../../utils/DateUtils";
  import GameHistory from "../game/GameHistory.svelte";

  $: user = $userStore;
</script>

<div class="bg-gray-800 p-4">
  {#if user}
    <div class="mb-4">
      <span>
        Id:
        {user.id.toString().substring(0, 6)}...{user.id
          .toString()
          .substring(user.id.toString().length - 6)}
      </span>
      <CopyTextButton value={user.id.toString()} />
    </div>
    {#if user.data !== undefined}
      <div class="mb-4">
        <div>
          Joined: {nanosecondsToDate(user.data.createTime).toLocaleDateString()}
        </div>
      </div>
      <div class="mt-4 flex justify-center">
        <LoginButton />
      </div>
      <GameHistory />
    {/if}
  {/if}
</div>
