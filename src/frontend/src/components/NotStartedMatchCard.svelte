<script lang="ts">
  import { MatchDetail } from "../models/Match";
  import MatchCardHeader from "./MatchCardHeader.svelte";

  export let match: MatchDetail;
</script>

<div>
  <MatchCardHeader {match} team1Score={undefined} team2Score={undefined} />
</div>
