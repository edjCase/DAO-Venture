<script lang="ts">
  import { Attribute, Choice } from "../../ic-agent/declarations/main";
  import ChoiceRequirement from "./ChoiceRequirement.svelte";
  import GenericOption from "../common/GenericOption.svelte";
  import CharacterAttributeIcon from "../character/CharacterAttributeIcon.svelte";
  import { Tooltip } from "flowbite-svelte";

  export let option: Choice;
  export let selected: boolean;
  export let onSelect: (id: string) => Promise<void>;

  let attributeScales: Attribute[] = [];
  $: if ("multi" in option.nextPath) {
    attributeScales = [];
    for (const m of option.nextPath.multi) {
      if ("attributeScaled" in m.weight.kind) {
        attributeScales.push(m.weight.kind.attributeScaled);
      }
    }
  } else {
    attributeScales = [];
  }
</script>

<GenericOption choiceId={option.id} {selected} {onSelect}>
  {option.description}
  {#if option.requirement[0] !== undefined}
    <ChoiceRequirement value={option.requirement[0]} />
  {/if}
  {#each attributeScales as attributeScale}
    <div class="text-primary-500 flex justify-center">
      <div>
        <span>🎲</span>
        <Tooltip>
          Attribute scales success probability. Positive = easier, negative =
          harder.
        </Tooltip>
      </div>
      <CharacterAttributeIcon value={attributeScale} />
    </div>
  {/each}
</GenericOption>
