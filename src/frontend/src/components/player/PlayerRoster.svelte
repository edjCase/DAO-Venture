<script lang="ts">
  import { Principal } from "@dfinity/principal";
  import { playerStore } from "../../stores/PlayerStore";
  import { Player } from "../../ic-agent/PlayerLedger";
  import { Link } from "svelte-routing";
  import { positionToString } from "../../models/Player";
  import UniqueAvatar from "../common/UniqueAvatar.svelte";

  export let teamId: Principal;

  const skillToString = (skill: number): string => {
    if (skill == 0) {
      return "";
    } else if (skill > 0) {
      return `+${skill}`;
    } else {
      return `${skill}`;
    }
  };

  let players: Player[] = [];
  playerStore.subscribe((playerList) => {
    players = playerList
      .filter((p) => p.teamId?.toString() === teamId.toString())
      .sort((a, b) => a.id - b.id);
  });
</script>

<table class="player-roster">
  <caption>Player Roster</caption>
  <thead>
    <tr>
      <th class="column-number">#</th>
      <th class="column-name">Name</th>
      <th class="column-position">Position</th>
      <th class="column-skill">BA</th>
      <th class="column-skill">BP</th>
      <th class="column-skill">TA</th>
      <th class="column-skill">TP</th>
      <th class="column-skill">CA</th>
      <th class="column-skill">DF</th>
      <th class="column-skill">PI</th>
      <th class="column-skill">SP</th>
    </tr>
  </thead>
  <tbody>
    {#each players as player}
      <tr>
        <td>{player.id}</td>
        <td>
          <Link to={"/players/" + player.id}>
            <span class="flex items-center gap-2">
              <UniqueAvatar
                id={player.id}
                size={20}
                borderStroke={undefined}
                condition={undefined}
              />
              {player.name}
            </span>
          </Link>
        </td>
        <td>{positionToString(player.position)}</td>
        <td>{skillToString(player.skills.battingAccuracy)}</td>
        <td>{skillToString(player.skills.battingPower)}</td>
        <td>{skillToString(player.skills.throwingAccuracy)}</td>
        <td>{skillToString(player.skills.throwingPower)}</td>
        <td>{skillToString(player.skills.catching)}</td>
        <td>{skillToString(player.skills.defense)}</td>
        <td>{skillToString(player.skills.piety)}</td>
        <td>{skillToString(player.skills.speed)}</td>
      </tr>
    {/each}
  </tbody>
</table>

<style>
  .player-roster {
    margin-top: 2rem;
    border-collapse: collapse;
  }

  .player-roster caption {
    font-size: 1.5rem;
    margin-bottom: 1rem;
  }

  .player-roster th,
  .player-roster td {
    border: 1px solid var(--color-border);
    padding: 0.5rem;
    text-align: left;
    text-overflow: ellipsis;
  }

  .player-roster th.column-number {
    width: 50px;
  }

  .player-roster th.column-skill {
    width: 10px;
  }

  .player-roster th.column-name {
    width: 200px;
  }

  .player-roster th.column-position {
    width: 120px;
  }

  .player-roster th {
    background-color: var(--color-bg-dark);
    color: var(--color-text-light);
  }

  .player-roster td {
    background-color: var(--color-bg-light);
    color: var(--color-text-light);
  }
</style>
