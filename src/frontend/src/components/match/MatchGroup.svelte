<script lang="ts">
  import Countdown from "../common/Countdown.svelte";
  import { nanosecondsToDate } from "../../utils/DateUtils";
  import MatchUp from "./MatchUp.svelte";
  import { Hr } from "flowbite-svelte";
  import { teamStore } from "../../stores/TeamStore";
  import {
    CompletedMatchGroup,
    InProgressSeasonMatchGroupVariant,
  } from "../../ic-agent/declarations/main";
  import MatchSummary from "./MatchSummary.svelte";
  import CompletedMatchCard from "./CompletedMatchCard.svelte";

  export let matchGroupId: number;
  export let matchGroup: InProgressSeasonMatchGroupVariant;
  export let lastMatchGroup: CompletedMatchGroup | undefined;

  $: lastMatches = lastMatchGroup?.matches || [];

  $: teams = $teamStore;
</script>

<section>
  {#if "scheduled" in matchGroup}
    <section>
      <h2 class="flex flex-col items-center justify-center">
        <div class="text-xl">Next matches in</div>
        <Countdown date={nanosecondsToDate(matchGroup.scheduled.time)} />
      </h2>
      <Hr classHr="w-48 h-1 mx-auto my-6 rounded" />
      <div class="p-2">
        <div class="text-xl text-center mb-2">Predict Winners</div>
        <div class="flex justify-around flex-wrap gap-4">
          {#if teams}
            {#each matchGroup.scheduled.matches as match, matchId}
              <MatchUp
                {matchGroupId}
                {matchId}
                team1Id={match.team1.id}
                team2Id={match.team2.id}
              />
            {/each}
          {/if}
        </div>
      </div>
    </section>
  {:else if "notScheduled" in matchGroup}
    Not Scheduled TODO
  {:else if "inProgress" in matchGroup}
    TODO Live Match groups
  {:else if "completed" in matchGroup}
    <div>
      {#each matchGroup.completed.matches as match, matchId}
        <div class="bg-gray-700 text-gray-200 p-2 border rounded-lg w-full">
          <CompletedMatchCard {matchGroupId} {matchId} {match} />
        </div>
      {/each}
    </div>
  {/if}
  {#if lastMatchGroup}
    <Hr classHr="w-48 h-1 mx-auto my-6 rounded" />
    <div class="text-xl text-center">Last Matches</div>
    <div class="text-sm text-center">
      {nanosecondsToDate(lastMatchGroup.time).toDateString()}
    </div>

    <div class="flex flex-col items-center">
      {#each lastMatches as lastMatch, matchId}
        <MatchSummary match={lastMatch} {matchGroupId} {matchId} />
        <Hr classHr="w-48 h-1 mx-auto my-6 rounded" />
      {/each}
    </div>
  {/if}
</section>
