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
  import { DivisionDetails, mapMatchGroup } from "../models/Match";
  import TeamGrid from "../components/TeamGrid.svelte";
  import { TabItem, Tabs } from "flowbite-svelte";
  import DivisionSummaryCard from "../components/DivisionSummaryCard.svelte";
  import { divisionStore } from "../stores/DivisionStore";
  import { get } from "svelte/store";
  import { Division } from "../ic-agent/League";
  import { MatchGroup } from "../ic-agent/Stadium";

  $: teams = $teamStore;

  let divisions: DivisionDetails[] = [];

  let updateDivisions = (
    allDivisions: Division[],
    allMatchGroups: MatchGroup[]
  ) => {
    if (allDivisions.length == 0 || allMatchGroups.length == 0) {
      return;
    }
    divisions = allDivisions.map((d) => {
      let matchGroups = allMatchGroups
        .filter((mg) =>
          mg.matches.some(
            (m) => m.team1.divisionId === d.id || m.team2.divisionId === d.id
          )
        )
        .map((mg) => mapMatchGroup(mg));
      return {
        id: d.id,
        name: d.name,
        matchGroups: matchGroups,
      };
    });
  };

  divisionStore.subscribe((d) => {
    updateDivisions(d, get(matchGroupStore));
  });

  matchGroupStore.subscribe((matchGroups) => {
    updateDivisions(get(divisionStore), matchGroups);
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

  <Tabs style="pill">
    {#each divisions as division}
      <TabItem>
        <div slot="title">{division.name}</div>
        <DivisionSummaryCard {division} />
      </TabItem>
    {/each}
  </Tabs>

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
