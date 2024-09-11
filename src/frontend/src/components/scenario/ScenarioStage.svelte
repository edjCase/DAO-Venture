<script lang="ts">
  import {
    OutcomeEffect,
    ScenarioMetaData,
    ScenarioStageResult,
  } from "../../ic-agent/declarations/main";
  import { toJsonString } from "../../utils/StringUtil";
  import ScenarioOutcomeEffect from "./ScenarioOutcomeEffect.svelte";

  export let stage: ScenarioStageResult;
  export let scenarioMetaData: ScenarioMetaData;

  // Seperate the text from the other effects
  $: effectRows = stage.effects.reduce((acc, effect) => {
    if ("text" in effect) {
      acc.push([effect]);
    } else {
      let currentIsText = "text" in acc[acc.length - 1][0];
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
  <div>
    {#each stage.kind.combat.log as logEntry}
      <div>
        {#if "damage" in logEntry}
          DAMAGE {logEntry.damage.damage} to {toJsonString(
            logEntry.damage.target
          )} by
          {toJsonString(logEntry.damage.source)}
        {:else if "heal" in logEntry}
          HEAL {logEntry.heal.heal} to {toJsonString(logEntry.heal.target)} by {toJsonString(
            logEntry.heal.source
          )}
        {:else if "block" in logEntry}
          BLOCK {logEntry.block.shield} to {toJsonString(logEntry.block.target)}
          by
          {toJsonString(logEntry.block.source)}
        {:else if "statusEffect" in logEntry}
          STATUS EFFECT {toJsonString(logEntry.statusEffect.statusEffect)} to {toJsonString(
            logEntry.statusEffect.target
          )} by {toJsonString(logEntry.statusEffect.source)}
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
