<script lang="ts">
  import { Accordion, AccordionItem } from "flowbite-svelte";
  import {
    OutcomeEffect,
    ScenarioStageResult,
  } from "../../ic-agent/declarations/main";
  import { toJsonString } from "../../utils/StringUtil";
  import GameIcon from "../game/GameIcon.svelte";
  import CombatTarget from "./CombatTarget.svelte";
  import ScenarioOutcomeEffect from "./ScenarioOutcomeEffect.svelte";
  import StatusEffect from "./StatusEffect.svelte";

  export let stage: ScenarioStageResult;

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
  <div class="text-xl">
    {stage.kind.choice.choice.description}
  </div>
{:else if "combat" in stage.kind}
  <div>
    <Accordion border={false} flush={true} class="max-w-48 mx-auto">
      <AccordionItem>
        <div slot="header">Combat Turn Log</div>
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
      </AccordionItem>
    </Accordion>

    {#if "victory" in stage.kind.combat.kind}
      <div>Victory</div>
    {:else if "defeat" in stage.kind.combat.kind}
      <div>DEFEAT</div>
    {/if}
  </div>
{:else if "reward" in stage.kind}
  <div class="text-2xl">Reward</div>
{/if}

<div class="flex flex-col max-w-96 justify-center items-center mx-auto my-6">
  {#each effectRows as row}
    <div class="flex justify-left gap-2">
      {#each row as effect}
        <ScenarioOutcomeEffect value={effect} />
      {/each}
    </div>
  {/each}
</div>
