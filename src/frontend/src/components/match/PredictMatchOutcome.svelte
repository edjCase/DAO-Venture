<script lang="ts">
  import { Button } from "flowbite-svelte";
  import { MatchDetails } from "../../models/Match";
  import { leagueAgentFactory } from "../../ic-agent/League";
  import TeamLogo from "../team/TeamLogo.svelte";

  export let match: MatchDetails;

  let predict = function (team: { team1: null } | { team2: null }) {
    leagueAgentFactory()
      .predictMatchOutcome({
        matchId: match.id,
        prediction: { winner: team },
      })
      .then((result) => {
        if ("ok" in result) {
          console.log("Predicted for match: ", match.id);
        } else {
          console.log("Failed to predict for match: ", result);
        }
      });
  };
</script>

<div class="container">
  <Button on:click={() => predict({ team1: null })}>
    <TeamLogo team={match.team1} size="lg" />
  </Button>
  OR
  <Button on:click={() => predict({ team2: null })}>
    <TeamLogo team={match.team2} size="lg" />
  </Button>
</div>

<style>
  .container {
    display: flex;
    flex-direction: row;
  }
</style>
