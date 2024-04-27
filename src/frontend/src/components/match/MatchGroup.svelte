<script lang="ts">
  import { MatchDetails, MatchGroupDetails } from "../../models/Match";
  import LiveMatchComponent from "./LiveMatch.svelte";
  import {
    LiveMatch,
    liveMatchGroupStore,
  } from "../../stores/LiveMatchGroupStore";
  import MatchCardCompact from "./MatchCardCompact.svelte";
  import Countdown from "../common/Countdown.svelte";
  import { nanosecondsToDate } from "../../utils/DateUtils";
  import MatchUp from "./MatchUp.svelte";
  import { Hr } from "flowbite-svelte";

  export let matchGroup: MatchGroupDetails;
  export let lastMatchGroup: MatchGroupDetails | undefined;

  let selectedMatchId = BigInt(0);
  let liveMatches: LiveMatch[] | undefined = undefined;
  let matches: [MatchDetails, LiveMatch | undefined][] = [];
  $: matches = matchGroup.matches.map((match, index) => [
    match,
    liveMatches ? liveMatches[index] : undefined,
  ]);
  $: lastMatches = lastMatchGroup?.matches || [];
  $: selectedMatch = matchGroup.matches[Number(selectedMatchId)];
  $: selectedLiveMatch = liveMatches
    ? liveMatches[Number(selectedMatchId)]
    : undefined;

  liveMatchGroupStore.subscribe((liveMatchGroup) => {
    if (!liveMatchGroup || matchGroup.id != liveMatchGroup?.id) {
      selectedLiveMatch = undefined;
      liveMatches = undefined;
    } else {
      selectedLiveMatch = liveMatchGroup.matches[Number(selectedMatchId)];
      liveMatches = liveMatchGroup.matches;
    }
  });

  let selectMatch = (matchId: bigint) => () => {
    selectedMatchId = matchId;
  };
</script>

<section class="bg-gray-800">
  {#if matchGroup.state == "Scheduled"}
    <section>
      <h2 class="flex flex-col items-center justify-center">
        <div class="text-xl">Next matches in</div>
        <Countdown date={nanosecondsToDate(matchGroup.time)} />
      </h2>
      <Hr classHr="w-48 h-1 mx-auto my-6 rounded" />
      <div class="p-2">
        <div class="text-xl text-center mb-2">Predict Winners</div>
        <div class="flex justify-around flex-wrap gap-4">
          {#each matchGroup.matches as match}
            <MatchUp {match} />
          {/each}
        </div>
      </div>
    </section>
  {:else if matchGroup.state == "NotScheduled"}
    Not Scheduled TODO
  {:else}
    <div class="">
      {#each matches as [match, liveMatch]}
        <div
          class="cursor-pointer"
          on:click={selectMatch(match.id)}
          on:keydown={() => {}}
          on:keyup={() => {}}
          role="button"
          tabindex="0"
        >
          <MatchCardCompact
            {match}
            {liveMatch}
            selected={match.id == selectedMatchId}
          />
        </div>
      {/each}
    </div>
    <div class="flex flex-col items-center justify-center">
      {#if selectedLiveMatch}
        <div class="flex items-center justify-center w-screen sm:w-96">
          <LiveMatchComponent
            match={selectedMatch}
            liveMatch={selectedLiveMatch}
          />
        </div>
      {/if}
    </div>
  {/if}
  {#if lastMatchGroup}
    <Hr classHr="w-48 h-1 mx-auto my-6 rounded" />
    <div class="text-xl text-center">Last Matches</div>
    <div class="text-sm text-center">
      {nanosecondsToDate(lastMatchGroup.time).toDateString()}
    </div>

    <div class="flex flex-col items-center">
      {#each lastMatches as lastMatch}
        <div>
          <MatchCardCompact match={lastMatch} liveMatch={undefined} />
        </div>
      {/each}
    </div>
  {/if}
</section>
