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
      <div class="container">
        {#if selectedLiveMatch}
          <div class="selected-match">
            <LiveMatchComponent
              match={selectedMatch}
              liveMatch={selectedLiveMatch}
            />
          </div>
        {/if}
        <div class="other-matches">
          {#each matches as [match, liveMatch]}
            <div
              class="clickable"
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

<style>
  section {
    margin-bottom: 20px;
  }
  .match-details {
    display: flex;
    flex-direction: column;
    align-items: center;
  }

  .container {
    display: flex;
    flex-direction: row;
    justify-content: center;
    flex-wrap: wrap;
    align-items: stretch;
    padding: 5px;
    max-width: 800px;
  }
  .selected-match {
    display: flex;
    justify-content: center;
    align-items: stretch;
    margin: 0 10px;
    height: 50vh;
    flex: 1;
  }
  .other-matches {
    display: flex;
    flex-direction: column;
    justify-content: center;
    align-items: center;
    flex: 1;
  }

  @media (max-width: 768px) {
    .container {
      flex-direction: column;
      flex-wrap: nowrap;
      align-items: center;
    }
    .selected-match,
    .other-matches {
      flex: none;
    }
  }
  .clickable {
    cursor: pointer;
    width: 100%;
  }
</style>
