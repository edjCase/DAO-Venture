<script lang="ts">
  import { BadgeCheckOutline } from "flowbite-svelte-icons";
  import { Choice, ScenarioVote } from "../../ic-agent/declarations/main";
  import ChoiceRequirement from "./ChoiceRequirement.svelte";
  import { Spinner } from "flowbite-svelte";

  export let option: Choice;
  export let vote: ScenarioVote;
  export let onSelect: (id: string) => Promise<void>;

  $: choiceVotingPower =
    vote.votingPowerByChoice.find((v) => v.choice === option.id)?.votingPower ||
    0n;
  $: percentVote =
    vote.totalVotingPower === 0n
      ? 0
      : (Number(choiceVotingPower) / Number(vote.totalVotingPower)) * 100;
  $: classes = `p-4 border rounded w-full text-left relative overflow-hidden`;
  $: backgroundStyle = `width: ${percentVote}%;`;

  let voting = false;
  let onOptionSelect = async () => {
    voting = true;
    try {
      await onSelect(option.id);
    } finally {
      voting = false;
    }
  };
</script>

<div class="flex items-center mb-2">
  <div class="w-8">
    {#if option.id == vote.yourVote[0]?.choice[0]}
      <BadgeCheckOutline size="md" />
    {:else if voting}
      <Spinner size="4" />
    {/if}
  </div>
  <button class={classes} on:click={onOptionSelect}>
    <div class="relative z-10">
      {option.description}
      {#if option.requirement[0] !== undefined}
        <ChoiceRequirement value={option.requirement[0]} />
      {/if}
    </div>
    <div
      class="absolute inset-0 bg-blue-200 opacity-50 transition-all duration-300 ease-in-out"
      style={backgroundStyle}
    ></div>
  </button>
  <div class="text-sm w-16 ml-2">
    {percentVote.toFixed(1)}%
  </div>
</div>
