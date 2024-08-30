<script lang="ts">
  import {
    GameWithMetaData,
    User,
    VotingGameStateWithMetaData,
  } from "../../ic-agent/declarations/main";
  import { mainAgentFactory } from "../../ic-agent/Main";
  import { currentGameStore } from "../../stores/CurrentGameStore";
  import CharacterAvatar from "../character/CharacterAvatar.svelte";
  import GameNav from "./GameNav.svelte";
  import GenericOption from "../common/GenericOption.svelte";

  export let game: GameWithMetaData;
  export let user: User;
  export let state: VotingGameStateWithMetaData;

  let characterId: string | undefined = undefined;
  let vote = (optionId: string) => async () => {
    characterId = optionId;
    let mainAgent = await mainAgentFactory();
    let result = await mainAgent.voteOnNewGame({
      gameId: game.id,
      characterId: characterId,
    });
    if ("ok" in result) {
      currentGameStore.refetch();
    } else {
      console.error("Failed to vote", result);
    }
  };
</script>

<GameNav {game} {user}>
  <div class="text-3xl">Pick character</div>
  <div class="flex flex-col p-8">
    {#each state.characterOptions as character, id}
      <GenericOption
        optionId={id.toString()}
        choice={characterId?.toString()}
        vote={state.characterVotes}
        onSelect={vote(id.toString())}
      >
        <CharacterAvatar size="lg" {character} />
        <div class="flex-grow">
          <div class="text-2xl">
            {character.race.name}
            {character.class.name}
          </div>
          <div>
            {#if character.health > 100}
              <div>+{character.health - 100n} 🫀</div>
            {:else if character.health < 100}
              <div>-{100n - character.health} 🫀</div>
            {/if}
            {#if character.gold > 0}
              <div>+{character.gold} 🪙</div>
            {/if}
            {#if character.attack > 0}
              <div>+{character.attack} ⚔️</div>
            {/if}
            {#if character.defense > 0}
              <div>+{character.defense} 🛡️</div>
            {/if}
            {#if character.speed > 0}
              <div>+{character.speed} 🏃</div>
            {/if}
            {#if character.magic > 0}
              <div>+{character.magic} 🔮</div>
            {/if}
            {#each character.traits as trait}
              <div>+{trait.name}</div>
            {/each}
            {#each character.items as item}
              <div>+{item.name}</div>
            {/each}
          </div>
        </div>
      </GenericOption>
    {/each}
  </div>
</GameNav>
