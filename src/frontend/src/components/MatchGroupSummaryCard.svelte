<script lang="ts">
  import { MatchGroupDetails } from "../models/Match";
  import { Link, navigate } from "svelte-routing";
  import { nanosecondsToDate } from "../utils/DateUtils";
  import MatchCardHeader from "./MatchCardHeader.svelte";

  export let matchGroup: MatchGroupDetails;
</script>

<div
  class="match-group"
  on:click={() => navigate("/match-groups/" + matchGroup.id)}
  on:keydown={() => {}}
  on:keyup={() => {}}
>
  {#if "notStarted" in matchGroup.state}
    <div class="not-started">
      <div>
        {nanosecondsToDate(matchGroup.time).toLocaleString()}
      </div>
      {#each matchGroup.matches as match}
        <MatchCardHeader
          {match}
          team1Score={undefined}
          team2Score={undefined}
          winner={undefined}
        />
      {/each}
    </div>
  {:else if "completed" in matchGroup.state}
    <div>Completed Match Group</div>
    {#each matchGroup.state.completed.matches as match, index}
      <div class="completed">
        {#if "played" in match}
          <div class="teams">
            <MatchCardHeader
              match={matchGroup.matches[index]}
              team1Score={match.played.team1.score}
              team2Score={match.played.team2.score}
              winner={match.played.winner}
            />
          </div>
        {:else if "allAbsent" in match}
          <div class="all-absent">All teams were absent</div>
        {:else if "absentTeam" in match}
          <div class="absent-team">
            Team {match.absentTeam.name} was absent and thus forfeit
          </div>
        {:else if "stateBroken" in match}
          <div class="state-broken">
            Match in broken:
            <div>
              {match.stateBroken}
            </div>
          </div>
        {/if}
      </div>
    {/each}
  {:else}
    <div class="match-group in-progress">
      {#if "inProgress" in matchGroup.state}
        <Link to={"/match-groups/" + matchGroup.id}>
          <div>Live Now!</div>
          {#each matchGroup.matches as match}
            <div>
              {match.team1.name} vs {match.team2.name}
            </div>
          {/each}
        </Link>
      {/if}
    </div>
  {/if}
</div>

<style>
  .all-absent,
  .absent-team,
  .state-broken {
    width: 100%;
    text-wrap: pretty;
  }
  .match-group {
    width: 300px;
    background-color: rgb(28, 26, 26);
    border: 1px solid white;
    border-radius: 5px;
  }
  .match-group:hover {
    cursor: pointer;
  }
  .match-group .completed {
    display: flex;
    flex-direction: column;
    align-items: center;
  }
  .match-group .in-progress {
    display: flex;
    flex-direction: column;
    align-items: center;
  }
  .match-group .not-started {
    display: flex;
    flex-direction: column;
    align-items: center;
  }
  .teams {
    display: flex;
    flex-direction: row;
    align-items: center;
    justify-content: space-between;
    padding-top: 10px;
  }
</style>
