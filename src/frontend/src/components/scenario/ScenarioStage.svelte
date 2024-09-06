<script lang="ts">
  import {
    ScenarioMetaData,
    ScenarioStageResult,
  } from "../../ic-agent/declarations/main";
  import { toJsonString } from "../../utils/StringUtil";
  import CharacterStatIcon from "../character/CharacterStatIcon.svelte";

  export let stage: ScenarioStageResult;
  export let scenarioMetaData: ScenarioMetaData;
</script>

{#if "choice" in stage.kind}
  {@const choiceId = stage.kind.choice.choiceId}
  {@const option = scenarioMetaData.choices.find((c) => c.id === choiceId)}
  <div class="text-3xl text-primary-500">Choice</div>
  <div class="text-xl">
    {#if option !== undefined}
      {option.description}
    {:else}
      COULD NOT FIND OPTION {choiceId}
    {/if}
  </div>
{:else if "combat" in stage.kind}
  <div class="text-3xl text-primary-500">Combat</div>
  {#if "inProgress" in stage.kind.combat}
    <div>InProgress</div>
    <div>Character Health: {stage.kind.combat.inProgress.character.shield}</div>
    <div>Creatures:</div>
    {#each stage.kind.combat.inProgress.creatures as creature}
      <div>
        {creature.creatureId}: Health {creature.health}/{creature.maxHealth}
      </div>
    {/each}
  {:else if "victory" in stage.kind.combat}
    <div>Victory</div>
  {:else if "defeat" in stage.kind.combat}
    <div>DEFEAT</div>
    <div>Remaining Creatures:</div>
    {#each stage.kind.combat.defeat.creatures as creature}
      <div>
        {creature.creatureId}: Health {creature.health}/{creature.maxHealth}
      </div>
    {/each}
  {/if}
{/if}

<div class="text-3xl text-primary-500">Outcome Log</div>
<ul class="text-sm">
  {#each stage.effects as effect}
    <li>
      {#if "text" in effect}
        {effect.text}
      {:else if "healthDelta" in effect}
        HEALTH
        {effect.healthDelta >= 0 ? "+" : ""}{effect.healthDelta}
        <CharacterStatIcon kind={{ maxHealth: null }} />
      {:else if "maxHealthDelta" in effect}
        MAX HEALTH
        {effect.maxHealthDelta >= 0 ? "+" : ""}{effect.maxHealthDelta}
        <CharacterStatIcon kind={{ maxHealth: null }} />
      {:else if "goldDelta" in effect}
        {effect.goldDelta >= 0 ? "+" : ""}{effect.goldDelta}
        <CharacterStatIcon kind={{ gold: null }} />
      {:else if "addItem" in effect}
        +{effect.addItem}
      {:else if "removeItem" in effect}
        -{effect.removeItem}
      {:else if "addTrait" in effect}
        +{effect.addTrait}
      {:else if "removeTrait" in effect}
        -{effect.removeTrait}
      {:else}
        NOT IMPLEMENTED LOG ENTRY TYPE {toJsonString(effect)}
      {/if}
    </li>
  {/each}
</ul>
