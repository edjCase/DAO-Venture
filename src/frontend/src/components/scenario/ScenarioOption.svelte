<script lang="ts">
  import { Choice, ScenarioVote } from "../../ic-agent/declarations/main";
  import ChoiceRequirement from "./ChoiceRequirement.svelte";
  import GenericOption from "../common/GenericOption.svelte";

  export let option: Choice;
  export let vote: ScenarioVote;
  export let onSelect: (id: string) => Promise<void>;
</script>

<GenericOption
  optionId={option.id}
  choice={vote.yourVote[0]?.choice[0]}
  {vote}
  {onSelect}
>
  {option.description}
  {#if option.requirement[0] !== undefined}
    <ChoiceRequirement value={option.requirement[0]} />
  {/if}
</GenericOption>
