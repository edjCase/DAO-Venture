<script lang="ts">
  import { nanosecondsToRelativeWeekString } from "../../utils/DateUtils";
  import { scheduleStore } from "../../stores/ScheduleStore";
  import { MatchDetails, MatchGroupDetails } from "../../models/Match";
  import MatchCardCompact from "./MatchCardCompact.svelte";

  export let teamId: bigint;

  let matches: MatchDetails[] = [];

  scheduleStore.subscribeMatchGroups((matchGroups: MatchGroupDetails[]) => {
    matches = matchGroups
      .flatMap((mg) => mg.matches)
      // Filter to where the team is in the match
      .filter(
        (m) =>
          m.team1 &&
          m.team2 &&
          "id" in m.team1 &&
          "id" in m.team2 &&
          (m.team1.id == teamId || m.team2.id == teamId),
      )
      // Filter out the matches that haven't happened yet
      .filter((m) => m.time < BigInt(Date.now() * 1000000));
  });
</script>

<div class="match-history">
  {#each matches as match}
    <div>{nanosecondsToRelativeWeekString(match.time)}</div>
    <MatchCardCompact {match} liveMatch={undefined} />
  {/each}
</div>

<style>
  .match-history {
    display: flex;
    flex-direction: column;
    align-items: center;
  }
</style>
