<script lang="ts">
  import { onMount } from "svelte";
  import { nanosecondsToDate } from "../../utils/DateUtils";
  import CharacterAvatarWithStats from "../character/CharacterAvatarWithStats.svelte";
  import { mainAgentFactory } from "../../ic-agent/Main";
  import { CompletedGameWithMetaData } from "../../ic-agent/declarations/main";
  import { toJsonString } from "../../utils/StringUtil";

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

  onMount(() => {
    if (completedGames.length === 0) {
      loadMoreGames();
    }
  });
</script>

<div>
  <div class="text-3xl text-primary-500 text-center">Game History</div>
  {#if completedGames.length === 0}
    <div class="text-center text-xl mt-4">No games found</div>
  {/if}
  <div class="space-y-4 mt-4">
    {#each completedGames as game}
      <div class="bg-gray-800 p-4">
        <div>
          {#if "victory" in game.outcome}
            Victory
            <div class="flex justify-center">
              <CharacterAvatarWithStats
                pixelSize={2}
                character={game.outcome.victory.character}
              />
            </div>
          {:else if "forfeit" in game.outcome}
            Forfeit
            {#if game.outcome.forfeit.character[0] !== undefined}
              <div class="flex justify-center">
                <CharacterAvatarWithStats
                  pixelSize={2}
                  character={game.outcome.forfeit.character[0]}
                />
              </div>
            {/if}
          {:else if "death" in game.outcome}
            Death
            <div class="flex justify-center">
              <CharacterAvatarWithStats
                pixelSize={2}
                character={game.outcome.death.character}
              />
            </div>
          {:else}
            NOT IMPLEMENTED GAME OUTCOME {toJsonString(game.outcome)}
          {/if}
        </div>
        <p>{nanosecondsToDate(game.endTime).toDateString()}</p>
      </div>
    {/each}
  </div>

  {#if hasMore}
    <button
      on:click={loadMoreGames}
      class="mt-4 px-4 py-2 bg-blue-500 text-white"
    >
      Load More
    </button>
  {/if}
</div>
