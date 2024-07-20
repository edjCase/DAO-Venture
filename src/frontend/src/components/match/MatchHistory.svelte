<script lang="ts">
  import { nanosecondsToDate } from "../../utils/DateUtils";
  import { scheduleStore } from "../../stores/ScheduleStore";
  import CompletedMatchCard from "./CompletedMatchCard.svelte";
  import {
    CompletedMatch,
    InProgressSeasonMatchGroupVariant,
  } from "../../ic-agent/declarations/main";

  export let townId: bigint;

  type MatchDetails = {
    match: CompletedMatch;
    time: bigint;
    matchGroupId: number;
    matchId: number;
  };
  let matches: MatchDetails[] = [];

  scheduleStore.subscribeMatchGroups(
    (matchGroups: InProgressSeasonMatchGroupVariant[]) => {
      matches = matchGroups
        .filter((mg) => "completed" in mg)
        .flatMap((mg, matchGroupId) =>
          mg.completed.matches.map<MatchDetails>((m, matchId) => ({
            match: m,
            time: mg.completed.time,
            matchGroupId: matchGroupId,
            matchId: matchId,
          })),
        )
        // Filter to where the town is in the match
        .filter(
          (m) => m.match.town1.id == townId || m.match.town2.id == townId,
        );
    },
  );
</script>

<div class="flex flex-col items-center">
  {#each matches as match}
    <div>{nanosecondsToDate(match.time).toDateString()}</div>
    <div>
      <CompletedMatchCard
        matchGroupId={match.matchGroupId}
        matchId={match.matchId}
        match={match.match}
      />
    </div>
  {/each}
</div>
