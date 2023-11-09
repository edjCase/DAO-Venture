<script lang="ts">
  import { MatchDetail } from "../models/Match";
  import MatchCardHeader from "./MatchCardHeader.svelte";

  export let match: MatchDetail;
  export let compact: boolean = false;
</script>

<div>
  <MatchCardHeader
    {match}
    team1Score={undefined}
    team2Score={undefined}
    winner={undefined}
  />
  {#if !compact}
    More info
  {/if}
</div>
