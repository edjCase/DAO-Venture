<script lang="ts">
  import { Choice } from "../../ic-agent/declarations/main";
  import ChoiceRequirement from "./ChoiceRequirement.svelte";
  import GenericOption from "../common/GenericOption.svelte";

  export let option: Choice;
  export let selected: boolean;
  export let onSelect: (id: string) => Promise<void>;
</script>

<GenericOption choiceId={option.id} {selected} {onSelect}>
  {option.description}
  {#if option.requirement[0] !== undefined}
    <ChoiceRequirement value={option.requirement[0]} />
  {/if}
</GenericOption>
