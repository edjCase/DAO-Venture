<script lang="ts">
  import { Accordion, AccordionItem } from "flowbite-svelte";
  import { ScenarioPath } from "../../../../ic-agent/declarations/main";
  import { toJsonString } from "../../../../utils/StringUtil";
  import ChoiceRequirementView from "./ChoiceRequirementView.svelte";
  import CombatCreatureFilterView from "./CombatCreatureKindView.svelte";
  import ScenarioNextPathView from "./ScenarioNextPathView.svelte";
  import ScenarioPathEffectView from "./ScenarioPathEffectView.svelte";

  export let path: ScenarioPath;
</script>

<div>
  <div class="text-primary-500">Id</div>
  <div>{path.id}</div>
  <div class="text-primary-500">Description</div>
  <div>{path.description}</div>

  {#if "choice" in path.kind}
    <div class="text-primary-500 text-2xl">Choice</div>
    <Accordion>
      {#each path.kind.choice.choices as choice}
        <AccordionItem title={choice.id}>
          <div slot="header">
            {choice.id}
          </div>
          <div class="text-primary-500">Description</div>
          <div>{choice.description}</div>
          <div class="text-primary-500">Effects</div>
          <div>
            {#if choice.effects.length > 0}
              <ul class="list-disc list-inside">
                {#each choice.effects as effect}
                  <li>
                    <ScenarioPathEffectView value={effect} />
                  </li>
                {/each}
              </ul>
            {:else}
              None
            {/if}
          </div>
          <div class="text-primary-500">Requirement</div>
          <div>
            {#if choice.requirement[0] !== undefined}
              <ChoiceRequirementView value={choice.requirement[0]} />
            {:else}
              -
            {/if}
          </div>
          <div class="text-primary-500">Next Path</div>
          <ScenarioNextPathView value={choice.nextPath} />
        </AccordionItem>
      {/each}
    </Accordion>
  {:else if "combat" in path.kind}
    <div class="text-primary-500 text-2xl">Combat</div>
    <div class="text-primary-500">Creatures</div>
    <ul>
      {#each path.kind.combat.creatures as creature}
        <li>
          <CombatCreatureFilterView value={creature} />
        </li>
      {/each}
    </ul>
    <div class="text-primary-500">Next Path</div>
    <ScenarioNextPathView value={path.kind.combat.nextPath} />
  {:else if "reward" in path.kind}
    <div class="text-primary-500 text-2xl">Reward</div>
    {#if "random" in path.kind.reward.kind}
      Random
    {:else if "specificItemIds" in path.kind.reward.kind}
      <div>
        <div class="text-primary-500">Specific rewards</div>
        <ul class="list-disc list-inside">
          {#each path.kind.reward.kind.specific as kind}
            <li>
              {#if "item" in kind}
                Item: {kind.item}
              {:else if "weapon" in kind}
                Weapon: {kind.weapon}
              {:else if "gold" in kind}
                Gold: {kind.gold}
              {:else if "health" in kind}
                Health: {kind.health}
              {:else}
                NOT IMPLEMENTED REWARD KIND: {toJsonString(kind)}
              {/if}
            </li>
          {/each}
        </ul>
      </div>
    {:else}
      NOT IMPLEMENTED REWARD KIND: {toJsonString(path.kind.reward.kind)}
    {/if}
    <div class="text-primary-500">Next Path</div>
    <ScenarioNextPathView value={path.kind.reward.nextPath} />
  {:else}
    <p>NOT IMPLEMENTED PATH KIND {toJsonString(path.kind)}</p>
  {/if}
</div>
