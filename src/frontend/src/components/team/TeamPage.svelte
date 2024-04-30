<script lang="ts">
  import PlayerRoster from "../player/PlayerRoster.svelte";
  import MatchHistory from "../match/MatchHistory.svelte";
  import { Button, TabItem, Tabs } from "flowbite-svelte";
  import TeamLogo from "./TeamLogo.svelte";
  import { Team } from "../../ic-agent/declarations/teams";
  export let team: Team;

  let links: { name: string; url: string }[] = []; // TODO
</script>

<div class="text-center my-2 mx-auto p-1 border rounded">
  <div class="flex flex-col p-2 gap-2">
    <div class="flex-1 flex justify-center items-center gap-2">
      <TeamLogo {team} size="md" />
      <div class="text-3xl">{team.name}</div>
    </div>
    <div class="">
      {#each links as link}
        <Button href={link.url}>{link.name}</Button>
      {/each}
    </div>
  </div>
  <Tabs>
    <TabItem title="Roster" open>
      <PlayerRoster teamId={team.id} />
    </TabItem>
    <TabItem title="Match History">
      <MatchHistory teamId={team.id} />
    </TabItem>
    <TabItem title="Fluff">
      <div class="flex-1 flex flex-col justify-center text-justify p-5 text-xl">
        {team.description}
      </div>
      <div class="flex-1 flex flex-col justify-center text-left p-5 text-lg">
        <div class="team-info">
          <div class="team-info-title">Team Motto</div>
          <div class="team-info-text">{team.motto}</div>
        </div>
        <div class="team-info inline">
          <div class="team-info-title">Managers:</div>
          <div class="team-info-text">0</div>
        </div>
        <div class="team-info inline">
          <div class="team-info-title">Championship Seasons:</div>
          <div class="team-info-text"></div>
        </div>
      </div>
    </TabItem>
  </Tabs>
</div>

<style>
  .team-info.inline div {
    display: inline;
  }
  .team-info-title {
    font-weight: bold;
    font-size: larger;
  }
</style>
