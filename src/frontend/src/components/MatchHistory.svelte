<script lang="ts">
  import { Principal } from "@dfinity/principal";
  import CompletedMatchCard from "./CompletedMatchCard.svelte";
  import {
    CompletedMatchState,
    Match,
    LiveMatchGroup,
  } from "../ic-agent/Stadium";
  import {
    CompletedMatchStateDetails,
    mapCompletedMatchState,
  } from "../models/Match";
  import { nanosecondsToRelativeWeekString } from "../utils/DateUtils";

  export let teamId: Principal;

  type MatchDetails = {
    matchGroup: LiveMatchGroup;
    match: Match;
    state: CompletedMatchStateDetails;
  };

  let matches: MatchDetails[] = [];

  matchGroupStore.subscribe((matchGroups) => {
    matches = matchGroups.flatMap((mg) =>
      mg.matches
        .map((m, i) => {
          let matchState;
          if ("completed" in mg.state) {
            matchState = { completed: mg.state.completed.matches[i] };
          } else if ("inProgress" in mg.state) {
            matchState = mg.state.inProgress.matches[i];
          }
          return { match: m, state: matchState, index: i };
        })
        .filter((m) => m.state != null && "completed" in m.state)
        .filter(
          (m) =>
            m.match.team1.id.compareTo(teamId) == "eq" ||
            m.match.team2.id.compareTo(teamId) == "eq"
        )
        .map((m) => {
          let matchState = (m.state as { completed: CompletedMatchState })
            .completed;
          let state = mapCompletedMatchState(mg.matches, matchState, m.index);
          return {
            matchGroup: mg,
            match: m.match,
            state: state,
          };
        })
    );
  });
</script>

<div class="match-history">
  {#each matches as match}
    <div>{nanosecondsToRelativeWeekString(match.matchGroup.time)}</div>
    <CompletedMatchCard
      match={match.match}
      matchState={match.state}
      compact={true}
    />
  {/each}
</div>

<style>
  .match-history {
    display: flex;
    flex-direction: column;
    align-items: center;
  }
</style>
