<script lang="ts">
  import { MatchGroupDetails } from "../models/Match";
  import MatchCard from "./MatchCard.svelte";

  export let matchGroup: MatchGroupDetails;
</script>

<div class="match-card-grid">
  {#each matchGroup.matches as match}
    <MatchCard {match} />
  {/each}
</div>

<style>
  .match-card-grid {
    display: flex;
    flex-direction: row;
    flex-wrap: wrap;
    justify-content: space-evenly;
  }
</style>
