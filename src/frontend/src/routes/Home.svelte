<script lang="ts">
  import { Record } from "@dfinity/candid/lib/cjs/idl";
  import AssignPlayerToTeam from "../components/AssignPlayerToTeam.svelte";
  import CreatePlayer from "../components/CreatePlayer.svelte";
  import CreateStadium from "../components/CreateStadium.svelte";
  import CreateTeam from "../components/CreateTeam.svelte";
  import ScheduleMatch from "../components/ScheduleSeason.svelte";
  import TempInitialize from "../components/TempInitialize.svelte";
  import { teamStore } from "../stores/TeamStore";
  import { matchGroupStore } from "../stores/MatchGroupStore";
  import ScheduleSeason from "../components/ScheduleSeason.svelte";
  import { MatchGroupDetails, mapMatchGroup } from "../models/Match";
  import MatchGroupSummaryCard from "../components/MatchGroupSummaryCard.svelte";
  import TeamGrid from "../components/TeamGrid.svelte";

  $: teams = $teamStore;

  // TODO divisions
  let liveMatchGroups: MatchGroupDetails[] = [];
  let historicalMatchGroups: MatchGroupDetails[] = [];
  let upcomingMatchGroups: MatchGroupDetails[] = [];
  matchGroupStore.subscribe((matchGroups) => {
    liveMatchGroups = [];
    historicalMatchGroups = [];
    upcomingMatchGroups = [];
    for (let matchGroup of matchGroups.sort((a, b) =>
      Number(a.time - b.time)
    )) {
      let matchGroupDetails = mapMatchGroup(matchGroup);
      if ("inProgress" in matchGroup.state) {
        liveMatchGroups.push(matchGroupDetails);
      } else if ("completed" in matchGroup.state) {
        historicalMatchGroups.push(matchGroupDetails);
      } else {
        upcomingMatchGroups.push(matchGroupDetails);
      }
    }
  });
</script>

<div class="content">
  {#if teams.length === 0}
    <TempInitialize />
  {/if}

  <div>
    <h1>Teams</h1>
    <TeamGrid />
  </div>

  <div>
    <h1>Schedule Season</h1>
    <ScheduleSeason />
  </div>
  {#if liveMatchGroups.length > 0}
    <h1>Live</h1>
    <div class="live-matches">
      {#each liveMatchGroups as liveMatchGroup (liveMatchGroup)}
        <div class="match-group">
          <MatchGroupSummaryCard matchGroup={liveMatchGroup} />
        </div>
      {/each}
    </div>
  {/if}

  {#if historicalMatchGroups.length > 0}
    <h1>Latest</h1>
    <div class="latest-matches">
      {#each historicalMatchGroups as historicalMatchGroup (historicalMatchGroup)}
        <div class="match-group">
          <MatchGroupSummaryCard matchGroup={historicalMatchGroup} />
        </div>
      {/each}
    </div>
  {/if}

  {#if upcomingMatchGroups.length > 0}
    <h1>Upcoming</h1>
    <div class="upcoming-matches">
      {#each upcomingMatchGroups as upcomingMatchGroup (upcomingMatchGroup)}
        <div class="match-group">
          <MatchGroupSummaryCard matchGroup={upcomingMatchGroup} />
        </div>
      {/each}
    </div>
  {/if}

  <hr style="margin-top: 400px;" />

  <div>
    <h1>Schedule Match</h1>
    <ScheduleMatch />
  </div>
  <div>
    <h1>Create Team</h1>
    <CreateTeam />
  </div>
  <div>
    <h1>Create Stadium</h1>
    <CreateStadium />
  </div>
  <div>
    <h1>Create Player</h1>
    <CreatePlayer />
  </div>
  <div>
    <h1>Assign Player to Team</h1>
    <AssignPlayerToTeam />
  </div>
</div>

<style>
  .content {
    max-width: 1fr;
  }
  .latest-matches,
  .upcoming-matches,
  .live-matches {
    margin-bottom: 50px;
    text-align: center;
    display: flex;
    flex-direction: row;
    flex-wrap: wrap;
  }
  .match-group {
    padding: 20px;
  }
</style>
