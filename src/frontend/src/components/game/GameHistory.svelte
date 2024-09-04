<script lang="ts">
  import { onMount } from "svelte";
  import { nanosecondsToDate } from "../../utils/DateUtils";
  import CharacterAvatarWithStats from "../character/CharacterAvatarWithStats.svelte";
  import DifficultyBadge from "../common/DifficultyBadge.svelte";
  import { mainAgentFactory } from "../../ic-agent/Main";
  import { CompletedGameWithMetaData } from "../../ic-agent/declarations/main";

  let completedGames: CompletedGameWithMetaData[] = [];
  let offset = 0n;
  let itemsPerPage = 10n;
  let hasMore = true;

  const loadMoreGames = async () => {
    const mainAgent = await mainAgentFactory();
    let pagedItems = await mainAgent.getCompletedGames({
      offset,
      count: itemsPerPage,
    });
    completedGames = [...completedGames, ...pagedItems.data];
    offset += itemsPerPage;
    hasMore = completedGames.length < Number(pagedItems.totalCount);
  };

  onMount(loadMoreGames);
</script>

<div>
  <div class="text-3xl">Game History</div>
  <hr />
  {#each completedGames as game}
    <div>
      <div>Result: {game.victory ? "Victory" : "Defeat"}</div>
      <p><DifficultyBadge value={game.difficulty} /></p>
      <p>{nanosecondsToDate(game.endTime).toDateString()}</p>
      <div class="flex justify-center">
        <CharacterAvatarWithStats size="lg" character={game.character} />
      </div>
    </div>
  {/each}

  {#if hasMore}
    <button
      on:click={loadMoreGames}
      class="mt-4 px-4 py-2 bg-blue-500 text-white rounded"
    >
      Load More
    </button>
  {/if}
</div>
