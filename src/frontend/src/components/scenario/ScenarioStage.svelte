<script lang="ts">
  import {
    OutcomeEffect,
    ScenarioMetaData,
    ScenarioStageResult,
  } from "../../ic-agent/declarations/main";
  import { toJsonString } from "../../utils/StringUtil";
  import GameIcon from "../game/GameIcon.svelte";
  import CombatTarget from "./CombatTarget.svelte";
  import ScenarioOutcomeEffect from "./ScenarioOutcomeEffect.svelte";
  import StatusEffect from "./StatusEffect.svelte";

  export let stage: ScenarioStageResult;
  export let scenarioMetaData: ScenarioMetaData;

  // Seperate the text from the other effects
  $: effectRows = stage.effects.reduce((acc, effect) => {
    if ("text" in effect) {
      acc.push([effect]);
    } else {
      let currentIsText = acc.length == 0 || "text" in acc[acc.length - 1][0];
      if (!currentIsText) {
        // current is not text, so add to the current row
        acc[acc.length - 1].push(effect);
      } else {
        // current is text, so start a new row
        acc.push([effect]);
      }
    }
    return acc;
  }, [] as OutcomeEffect[][]);
</script>

{#if "choice" in stage.kind}
  {@const choiceId = stage.kind.choice.choiceId}
  {@const option = scenarioMetaData.paths[0].kind.find(
    (c) => c.id === choiceId
  )}
  <div class="text-3xl text-primary-500">Choice</div>
  <div class="text-xl">
    {#if option !== undefined}
      {option.description}
    {:else}
      COULD NOT FIND OPTION {choiceId}
    {/if}
  </div>
{:else if "combat" in stage.kind}
  <div>
    {#each stage.kind.combat.log as logEntry}
      <div>
        {#if "damage" in logEntry}
          {logEntry.damage.amount}<GameIcon value="damage" /> to
          <CombatTarget value={logEntry.damage.target} /> by
          <CombatTarget value={logEntry.damage.source} />
        {:else if "heal" in logEntry}
          {logEntry.heal.amount}<GameIcon value="heal" /> to
          <CombatTarget value={logEntry.heal.target} /> by
          <CombatTarget value={logEntry.heal.source} />
        {:else if "block" in logEntry}
          {logEntry.block.amount}<GameIcon value="block" /> to
          <CombatTarget value={logEntry.block.target} /> by
          <CombatTarget value={logEntry.block.source} />
        {:else if "statusEffect" in logEntry}
          <StatusEffect value={logEntry.statusEffect.statusEffect} /> to
          <CombatTarget value={logEntry.statusEffect.target} /> by
          <CombatTarget value={logEntry.statusEffect.source} />
        {:else}
          NOT IMPLEMENTED LOG ENTRY TYPE {toJsonString(logEntry)}
        {/if}
      </div>
    {/each}
  </div>
  {#if "inProgress" in stage.kind.combat.kind}
    <div>
      Character Health: {stage.kind.combat.kind.inProgress.character
        .health}/{stage.kind.combat.kind.inProgress.character.maxHealth}
    </div>
    <div>Creatures:</div>
    {#each stage.kind.combat.kind.inProgress.creatures as creature}
      <div>
        {creature.creatureId}: Health {creature.health}/{creature.maxHealth}
      </div>
    {/each}
  {:else if "victory" in stage.kind.combat.kind}
    <div>Victory</div>
    <div>
      Character Health: {stage.kind.combat.kind.victory.characterHealth}
    </div>
  {:else if "defeat" in stage.kind.combat.kind}
    <div>DEFEAT</div>
    <div>Remaining Creatures:</div>
    {#each stage.kind.combat.kind.defeat.creatures as creature}
      <div>
        {creature.creatureId}: Health {creature.health}/{creature.maxHealth}
      </div>
    {/each}
  {/if}
{/if}

<div class="flex flex-col max-w-96 justify-center items-center mx-auto mt-6">
  {#each effectRows as row}
    <div class="flex justify-left gap-2">
      {#each row as effect}
        <ScenarioOutcomeEffect value={effect} />
      {/each}
    </div>
  {/each}
</div>
