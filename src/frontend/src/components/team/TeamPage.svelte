<script lang="ts">
  import PlayerRoster from "../player/PlayerRoster.svelte";
  import MatchHistory from "../match/MatchHistory.svelte";
  import { Button } from "flowbite-svelte";
  import { TeamWithId } from "../../ic-agent/declarations/league";
  export let team: TeamWithId;
</script>

<div class="team-container">
  <div class="team-header flex flex-col p-5">
    <div class="flex-1 flex flex-col justify-center text-justify p-5 text-xl">
      {team.description}
    </div>
    <div class="flex-1 flex flex-col justify-center p-5">
      <img class="team-logo" src={team.logoUrl} alt={`Logo of ${team.name}`} />
      <h1>{team.name}</h1>
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
      <div class="team-info">
        <div class="team-info-title">Links:</div>
        <div class="team-info-text">
          <Button href={""}>Website</Button>
          <Button href={""}>Twitter</Button>
        </div>
      </div>
    </div>
  </div>
  <div class="flex flex-col justify-evenly">
    <PlayerRoster teamId={team.id} />
    <div>
      <h1>Match History</h1>
      <MatchHistory teamId={team.id} />
    </div>
  </div>
</div>

<style>
  .team-container {
    text-align: center;
    margin: 2rem auto;
    padding: 1rem;
    background-color: var(--color-bg-light);
    border-radius: 8px;
    border: 1px solid var(--color-border);
  }

  .team-logo {
    max-width: 200px;
    height: auto;
    margin: 0 auto 1rem;
  }

  h1 {
    font-size: 2.5rem;
    color: var(--color-text-light);
    margin-bottom: 0.5rem;
  }
  .team-info.inline div {
    display: inline;
  }
  .team-info-title {
    font-weight: bold;
    font-size: larger;
  }
</style>
