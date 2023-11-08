<script lang="ts">
  import type { Match, MatchGroup } from "../ic-agent/Stadium";
  import { MatchGroupDetails, mapMatchGroup } from "../models/Match";
  import { matchGroupStore } from "../stores/MatchGroupStore";
  import { nanosecondsToDate } from "../utils/DateUtils";
  import { Link } from "svelte-routing";
  import MatchCard from "./MatchCard.svelte";

  export let matchGroupId: number;

  let matchGroup:
    | MatchGroupDetails
    | undefined
    | { notStarted: { id: number; startTime: Date; matches: Match[] } };

  matchGroupStore.subscribe((matchGroups: MatchGroup[]) => {
    let g = matchGroups.find((g) => g.id == matchGroupId);
    if (!g) {
      matchGroup = undefined;
      return;
    }
    if ("notStarted" in g.state) {
      matchGroup = {
        notStarted: {
          id: g.id,
          startTime: nanosecondsToDate(g.time),
          matches: g.matches,
        },
      };
      return;
    }
    matchGroup = mapMatchGroup(g);
  });
</script>

{#if matchGroup === undefined}
  <div>Loading...</div>
{:else if "notStarted" in matchGroup}
  <Link to={"/session/" + matchGroup.notStarted.id}>
    <div>Session starts at {new Date(matchGroup.notStarted.startTime)}</div>
    {#each matchGroup.notStarted.matches as match}
      <div>
        {match.team1.name} vs {match.team2.name}
      </div>
    {/each}
  </Link>
{:else if "completed" in matchGroup.state}
  <div>Match Group Completed</div>
  <div>Matches:</div>
  {#each matchGroup.state.completed.matches as match, index}
    <div>
      {matchGroup.matches[index].team1.name} vs {matchGroup.matches[index].team2
        .name}
    </div>
    {#if "played" in match}
      <div>
        Winner: {"team1" in match.played.winner
          ? matchGroup.matches[index].team1.name
          : matchGroup.matches[index].team2.name}
      </div>
      <div>Score: {match.played.team1.score} - {match.played.team2.score}</div>
    {:else if "allAbsent" in match}
      <div>All teams were absent</div>
    {:else if "absentTeam" in match}
      <div>Team {match.absentTeam.name} was absent and thus forfeit</div>
    {:else if "stateBroken" in match}
      <div>Match in broken state:</div>
      <pre>{match.stateBroken}</pre>
    {/if}
  {/each}
{:else}
  <div class="match-card-grid">
    {#if "inProgress" in matchGroup.state}
      {#each matchGroup.state.inProgress.matches as matchState, index}
        <MatchCard {matchState} match={matchGroup.matches[index]} />
      {/each}
    {/if}
  </div>

  <style>
    .match-card-grid {
      display: grid;
      grid-template-columns: repeat(auto-fill, 400px);
      justify-content: center;
    }
  </style>
{/if}
