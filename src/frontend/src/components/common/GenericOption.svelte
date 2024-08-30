<script lang="ts">
  import { Spinner } from "flowbite-svelte";
  import { BadgeCheckOutline } from "flowbite-svelte-icons";
  import { VotingSummary } from "../../ic-agent/declarations/main";

  export let choice: string | undefined;
  export let optionId: string;
  export let vote: VotingSummary;
  export let onSelect: (id: string) => Promise<void>;

  let selecting = false;
  let onOptionSelect = async () => {
    selecting = true;
    try {
      await onSelect(optionId);
    } finally {
      selecting = false;
    }
  };
  $: choiceVotingPower =
    vote.votingPowerByChoice.find((v) => v.choice === optionId)?.votingPower ||
    0n;
  $: percentVote =
    vote.totalVotingPower === 0n
      ? 0
      : (Number(choiceVotingPower) / Number(vote.totalVotingPower)) * 100;
  $: classes = `p-4 border rounded w-full text-left relative overflow-hidden`;
  $: backgroundStyle = `width: ${percentVote}%;`;
</script>

<div class="flex items-center mb-2">
  <div class="w-8">
    {#if optionId == choice}
      <BadgeCheckOutline size="md" />
    {:else if selecting}
      <Spinner size="4" />
    {/if}
  </div>
  <button class={classes} on:click={onOptionSelect}>
    <div class="relative z-10">
      <slot />
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
