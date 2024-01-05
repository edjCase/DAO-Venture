<script lang="ts">
  import { Principal } from "@dfinity/principal";
  import { nanosecondsToRelativeWeekString } from "../utils/DateUtils";
  import { scheduleStore } from "../stores/ScheduleStore";
  import MatchCard from "./MatchCard.svelte";
  import { MatchDetails, MatchGroupDetails } from "../models/Match";

  export let teamId: Principal;

  let matches: MatchDetails[] = [];

  scheduleStore.subscribeMatchGroups((matchGroups: MatchGroupDetails[]) => {
    matches = matchGroups
      .flatMap((mg) => mg.matches)
      // Filter to where the team is in the match
      .filter(
        (m) =>
          m.team1.id.compareTo(teamId) == "eq" ||
          m.team2.id.compareTo(teamId) == "eq"
      )
      // Filter out the matches that haven't happened yet
      .filter((m) => m.time < BigInt(Date.now() * 1000000));
  });
</script>

<div class="match-history">
  {#each matches as match}
    <div>{nanosecondsToRelativeWeekString(match.time)}</div>
    <MatchCard {match} compact={true} />
  {/each}
</div>

<style>
  .match-history {
    display: flex;
    flex-direction: column;
    align-items: center;
  }
</style>
