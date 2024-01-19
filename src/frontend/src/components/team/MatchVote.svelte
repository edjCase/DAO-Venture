<script lang="ts">
  import { MatchDetails } from "../../models/Match";
  import VoteForMatchGroup from "../match/VoteForMatchGroup.svelte";

  export let match: MatchDetails;
  export let matchGroupId: number;
</script>

<h1>Vote: {match.team1.name} vs {match.team2.name}</h1>
<div class="match-vote">
  <div class="team-vote">
    <h1>{match.team1.name}</h1>
    <VoteForMatchGroup {matchGroupId} teamId={match.team1.id} />
  </div>
  <div class="team-vote">
    <h1>{match.team2.name}</h1>
    <VoteForMatchGroup {matchGroupId} teamId={match.team2.id} />
  </div>
</div>

<style>
  .match-vote {
    display: flex;
    flex-direction: row;
    align-items: center;
  }
  .team-vote {
    margin: 20px;
  }
</style>
