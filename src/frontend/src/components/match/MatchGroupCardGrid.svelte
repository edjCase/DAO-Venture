<script lang="ts">
  import { MatchDetails, MatchGroupDetails } from "../../models/Match";
  import MatchCardCompact from "./MatchCardCompact.svelte";
  import LiveMatchCard from "./LiveMatch.svelte";
  import {
    LiveMatch,
    liveMatchGroupStore,
  } from "../../stores/LiveMatchGroupStore";

  export let matchGroup: MatchGroupDetails;

  let selectedMatchId = 0;
  let selectedMatch: MatchDetails = matchGroup.matches[selectedMatchId];
  let liveMatches: LiveMatch[] | undefined = undefined;
  let selectedLiveMatch: LiveMatch | undefined;
  let matches: [MatchDetails, LiveMatch | undefined][] = [];

  let updateMatches = () => {
    matches = matchGroup.matches.map((match, index) => [
      match,
      liveMatches ? liveMatches[index] : undefined,
    ]);
    selectedMatch = matchGroup.matches[selectedMatchId];
    selectedLiveMatch = liveMatches ? liveMatches[selectedMatchId] : undefined;
  };

  liveMatchGroupStore.subscribe((liveMatchGroup) => {
    if (!liveMatchGroup || matchGroup.id != liveMatchGroup?.id) {
      selectedLiveMatch = undefined;
      liveMatches = undefined;
    } else {
      selectedLiveMatch = liveMatchGroup.matches[selectedMatchId];
      liveMatches = liveMatchGroup.matches;
    }
    updateMatches();
  });

  let selectMatch = (matchId: number) => () => {
    selectedMatchId = matchId;
    updateMatches();
  };
</script>

<div class="container">
  <div class="selected-match">
    {#if selectedMatch && selectedLiveMatch}
      <LiveMatchCard match={selectedMatch} liveMatch={selectedLiveMatch} />
    {:else}
      Loading...
    {/if}
  </div>
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

<style>
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
