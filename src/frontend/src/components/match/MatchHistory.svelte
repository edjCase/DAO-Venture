<script lang="ts">
  import { nanosecondsToDate } from "../../utils/DateUtils";
  import { scheduleStore } from "../../stores/ScheduleStore";
  import CompletedMatchCard from "./CompletedMatchCard.svelte";
  import {
    CompletedMatch,
    InProgressSeasonMatchGroupVariant,
  } from "../../ic-agent/declarations/main";

  export let teamId: bigint;

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
        // Filter to where the team is in the match
        .filter(
          (m) => m.match.team1.id == teamId || m.match.team2.id == teamId,
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
