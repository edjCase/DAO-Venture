<script lang="ts">
  import { MatchDetails, MatchGroupDetails } from "../models/Match";
  import MatchCard from "./MatchCard.svelte";

  export let matchGroup: MatchGroupDetails;

  let selectedMatch: MatchDetails | undefined;
  let otherMatches: MatchDetails[] = matchGroup.matches;

  let selectMatch = (matchId: bigint) => () => {
    selectedMatch = matchGroup.matches.find((m) => m.id == matchId);
    otherMatches = matchGroup.matches.filter((m) => m.id != matchId);
  };
  selectMatch(BigInt(0))();
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
    padding: 5px;
    align-items: stretch;
  }
  .selected-match {
    flex: 2;
    display: flex;
    justify-content: center;
    align-items: stretch;
    margin: 0 10px;
    max-width: 600px;
  }
  .other-matches {
    flex: 1;
    display: flex;
    flex-direction: column;
    justify-content: center;
    align-items: center;
    max-width: 500px;
  }

  @media (max-width: 600px) {
    .selected-match,
    .other-matches {
      flex: 1;
    }
  }
  .clickable {
    cursor: pointer;
    width: 100%;
  }
</style>
