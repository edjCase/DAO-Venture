<script lang="ts">
  import { MatchDetails, MatchGroupDetails } from "../models/Match";
  import MatchCard from "./MatchCard.svelte";

  export let matchGroup: MatchGroupDetails;

  let selectedMatch: MatchDetails | undefined;
  let otherMatches: MatchDetails[] = matchGroup.matches;

  let selectMatch = (matchId: number) => () => {
    selectedMatch = matchGroup.matches.find((m) => m.id == matchId);
    otherMatches = matchGroup.matches.filter((m) => m.id != matchId);
  };
  selectMatch(0)();
</script>

<div class="container">
  <div class="selected-match">
    {#if selectedMatch}
      <MatchCard match={selectedMatch} compact={false} />
    {/if}
  </div>
  <div class="other-matches">
    {#each otherMatches as match}
      <div
        class="clickable"
        on:click={selectMatch(match.id)}
        on:keydown={() => {}}
        on:keyup={() => {}}
        role="button"
        tabindex="0"
      >
        <MatchCard {match} compact={true} />
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
  }
  .selected-match {
    display: flex;
    justify-content: center;
    align-items: stretch;
    margin: 0 10px;
    height: 50vh;
  }
  .other-matches {
    display: flex;
    flex-direction: column;
    justify-content: center;
    align-items: center;
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
