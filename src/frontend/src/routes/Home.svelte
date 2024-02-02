<script lang="ts">
  import { Record } from "@dfinity/candid/lib/cjs/idl";
  import LastAndCurrentMatchGroups from "../components/match/LastAndCurrentMatchGroups.svelte";
  import { scheduleStore } from "../stores/ScheduleStore";
  import { SeasonStatus } from "../models/Season";
  import TeamStandings from "../components/team/TeamStandings.svelte";
  import PlayerAwards from "../components/player/PlayerAwards.svelte";
  import SeasonWinners from "../components/season/SeasonWinners.svelte";

  let seasonStatus: SeasonStatus | undefined;

  scheduleStore.subscribeStatus((status) => {
    seasonStatus = status;
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
    {:else}
      <LastAndCurrentMatchGroups />
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
