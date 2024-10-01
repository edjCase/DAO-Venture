<script lang="ts">
  import { Accordion, AccordionItem } from "flowbite-svelte";
  import { NextPathKind } from "../../../../ic-agent/declarations/main";
  import { toJsonString } from "../../../../utils/StringUtil";
  import CharacterAttributeIcon from "../../../character/CharacterAttributeIcon.svelte";
  import ScenarioPathEffectView from "./ScenarioPathEffectView.svelte";

  export let value: NextPathKind;

  $: totalWeight =
    "multi" in value
      ? value.multi.reduce((acc, option) => acc + option.weight.value, 0)
      : 0;
</script>

<div>
  {#if "none" in value}
    None (End of scenario)
  {:else if "single" in value}
    {value.single}
  {:else if "multi" in value}
    <div>Multiple Outcomes</div>
    <Accordion>
      {#each value.multi as option, index}
        {@const basePercentage = (option.weight.value / totalWeight) * 100}
        <AccordionItem>
          <div
            slot="header"
            class="flex justify-between items-center w-full pr-2"
          >
            <span>#{index + 1}</span>
            <span class="text-sm text-gray-500">
              Base Chance: {basePercentage}%
            </span>
          </div>
          <div class="text-primary-500">Description</div>
          <div>
            {option.description}
          </div>
          <div class="text-primary-500">Weight</div>
          <div>
            {option.weight.value}
            {#if "raw" in option.weight.kind}
              <span></span>
            {:else if "attributeScaled" in option.weight.kind}
              <span>
                (scaled by <CharacterAttributeIcon
                  value={option.weight.kind.attributeScaled}
                />)
              </span>
            {:else}
              NOT IMPLEMENTED WEIGHT KIND: {toJsonString(option.weight.kind)}
            {/if}
          </div>
          <div class="text-primary-500">Effects</div>
          <div>
            {#if option.effects.length > 0}
              <ul class="pl-8">
                {#each option.effects as effect}
                  <li>
                    <ScenarioPathEffectView value={effect} />
                  </li>
                {/each}
              </ul>
            {:else}
              None
            {/if}
          </div>
          <div class="text-primary-500">Next Path</div>
          <div>
            {option.pathId[0] ? option.pathId[0] : "-"}
          </div>
        </AccordionItem>
      {/each}
    </Accordion>
  {/if}
</div>
