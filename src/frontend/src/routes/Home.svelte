<script lang="ts">
  import { Record } from "@dfinity/candid/lib/cjs/idl";
  import { scheduleStore } from "../stores/ScheduleStore";
  import TeamStandings from "../components/team/TeamStandings.svelte";
  import PlayerAwards from "../components/player/PlayerAwards.svelte";
  import SeasonWinners from "../components/season/SeasonWinners.svelte";
  import { MatchGroupDetails } from "../models/Match";
  import MatchGroup from "../components/match/MatchGroup.svelte";
  import InBetweenMatchesOverview from "../components/match/InBetweenMatchesOverview.svelte";
  import LiveMatchesOverview from "../components/match/LiveMatchesOverview.svelte";
  import MatchUp from "../components/match/MatchUp.svelte";
  import Countdown from "../components/common/Countdown.svelte";
  import { nanosecondsToDate } from "../utils/DateUtils";
  import { SeasonStatus } from "../ic-agent/declarations/league";

  let seasonStatus: SeasonStatus | undefined;
  let lastMatchGroup: MatchGroupDetails | undefined;
  let nextOrCurrentMatchGroup: MatchGroupDetails | undefined;

  scheduleStore.subscribeStatus((status) => {
    seasonStatus = status;
  });

  scheduleStore.subscribeMatchGroups((matchGroups: MatchGroupDetails[]) => {
    lastMatchGroup = matchGroups
      .slice()
      .reverse()
      .find((mg) => mg.state == "Completed");
    nextOrCurrentMatchGroup = matchGroups.find(
      (mg) =>
        mg.id > (lastMatchGroup?.id || -1) &&
        (mg.state == "InProgress" || mg.state == "Scheduled"),
    );
  });
</script>

<div class="content">
  {#if seasonStatus}
    {#if "notStarted" in seasonStatus}
      <div class="text-center text-3xl font-bold my-4">Season Not Started</div>
    {:else if "completed" in seasonStatus}
      <SeasonWinners completedSeason={seasonStatus.completed} />

      <div class="complete">
        <div class="teams">
          <TeamStandings completedSeason={seasonStatus.completed} />
        </div>
        <div class="players">
          <PlayerAwards completedSeason={seasonStatus.completed} />
        </div>
      </div>
    {:else if nextOrCurrentMatchGroup}
      {#if nextOrCurrentMatchGroup.state == "Scheduled"}
        <InBetweenMatchesOverview />
      {:else if nextOrCurrentMatchGroup.state == "InProgress"}
        <LiveMatchesOverview />
      {/if}
      <section class="bg-gray-800 p-6 text-white">
        <h2 class="text-3xl font-bold text-center mb-6">
          <div class="flex justify-center mb-5">
            <Countdown date={nanosecondsToDate(nextOrCurrentMatchGroup.time)} />
          </div>
          Next Session Matchups
        </h2>
        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          {#each nextOrCurrentMatchGroup.matches as match}
            <MatchUp {match} />
          {/each}
        </div>
      </section>

      <MatchGroup matchGroup={nextOrCurrentMatchGroup} />
    {:else}
      Loading...
    {/if}
  {/if}
</div>

<style>
  .complete {
    display: flex;
    flex-direction: row;
    flex-wrap: wrap;
    justify-content: space-evenly;
    gap: 20px;
  }
  .teams {
    max-width: 400px;
  }
  .players {
    max-width: 600px;
  }
</style>
