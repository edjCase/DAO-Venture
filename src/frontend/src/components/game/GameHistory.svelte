<script lang="ts">
  import { completedGameStore } from "../../stores/CompletedGameStore";
  import { nanosecondsToDate } from "../../utils/DateUtils";
  import CharacterAvatarWithStats from "../character/CharacterAvatarWithStats.svelte";
  import DifficultyBadge from "../common/DifficultyBadge.svelte";
  import UserAvatar from "../user/UserAvatar.svelte";

  $: completedGames = $completedGameStore;
</script>

<div>
  {#if completedGames !== undefined}
    <div class="text-3xl">Game History</div>
    <hr />
    {#each completedGames as game}
      <div>
        <div>Result: {game.victory ? "Victory" : "Defeat"}</div>
        <div>
          Type:
          {#if game.guestUserIds.length < 1}
            Solo
          {:else}
            Group
            {#each game.guestUserIds as guestUserId}
              <p><UserAvatar size="xs" userId={guestUserId} /></p>
            {/each}
          {/if}
        </div>
        <p><DifficultyBadge value={game.difficulty} /></p>
        <p>{nanosecondsToDate(game.endTime).toDateString()}</p>
        <div class="flex justify-center">
          <CharacterAvatarWithStats size="lg" character={game.character} />
        </div>
      </div>
    {/each}
  {/if}
</div>
