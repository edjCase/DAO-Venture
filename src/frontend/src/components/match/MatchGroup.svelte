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

  export let matchGroup: MatchGroupDetails;

  let selectedMatchId = BigInt(0);
  let liveMatches: LiveMatch[] | undefined = undefined;
  let matches: [MatchDetails, LiveMatch | undefined][] = [];
  $: matches = matchGroup.matches.map((match, index) => [
    match,
    liveMatches ? liveMatches[index] : undefined,
  ]);
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

<section>
  <section class="match-details">
    {#if matchGroup.state == "Scheduled"}
      <section class="bg-gray-800 p-6 text-white">
        <h2 class="text-3xl font-bold text-center mb-6">
          <div class="flex justify-center mb-5">
            <Countdown date={nanosecondsToDate(matchGroup.time)} />
          </div>
          Next Session Matchups
        </h2>
        <div class="grid grid-cols-1 gap-4">
          {#each matchGroup.matches as match}
            <MatchUp {match} />
          {/each}
        </div>
      </section>
    {:else if matchGroup.state == "NotScheduled"}
      Not Scheduled TODO
    {:else}
      <div class="flex flex-col items-center justify-center">
        {#if selectedLiveMatch}
          <div class="flex items-center justify-center w-screen sm:w-96">
            <LiveMatchComponent
              match={selectedMatch}
              liveMatch={selectedLiveMatch}
            />
          </div>
        {/if}
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
      </div>
    {/if}
  </section>
</section>
