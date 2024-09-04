<script lang="ts">
  import {
    GameWithMetaData,
    StartingGameStateWithMetaData,
  } from "../../ic-agent/declarations/main";
  import { mainAgentFactory } from "../../ic-agent/Main";
  import { currentGameStore } from "../../stores/CurrentGameStore";
  import CharacterAvatar from "../character/CharacterAvatar.svelte";
  import GameNav from "./GameNav.svelte";
  import GenericOption from "../common/GenericOption.svelte";

  export let game: GameWithMetaData;
  export let state: StartingGameStateWithMetaData;

  let characterId: number | undefined = undefined;
  let selectCharacter = (id: number) => async () => {
    characterId = id;
    let mainAgent = await mainAgentFactory();
    let result = await mainAgent.startGame({
      characterId: BigInt(characterId),
    });
    if ("ok" in result) {
      currentGameStore.refetch();
    } else {
      console.error("Failed to vote", result);
    }
  };
</script>

<GameNav {game}>
  <div class="text-3xl">Pick character</div>
  <div class="flex flex-col p-8">
    {#each state.characterOptions as character, id}
      {@const selected = characterId === id}
      <GenericOption
        choiceId={id.toString()}
        {selected}
        onSelect={selectCharacter(id)}
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
