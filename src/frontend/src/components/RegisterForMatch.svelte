<script lang="ts">
  import { teamStore } from "../stores/TeamStore";
  import { stadiumStore } from "../stores/StadiumStore";
  import { teamAgentFactory, type TeamConfig } from "../ic-agent/Team";
  import { playerStore } from "../stores/PlayerStore";
  import { Principal } from "@dfinity/principal";
  import { dndzone } from "svelte-dnd-action";
  import type { PlayerInfoWithId } from "../ic-agent/PlayerLedger";
  import DragDropList from "svelte-dragdroplist";

  $: teams = $teamStore;
  $: stadiums = $stadiumStore;

  let teamId: string;
  let stadiumId: string;
  let matchId: number;
  let teamPlayers: PlayerInfoWithId[];
  type StarterPlayer = { id: number; text: string; position: FieldPosition };
  let startingPlayers: StarterPlayer[] = [];
  let substitutes: number[] = [];

  $: {
    playerStore.subscribe((players) => {
      teamPlayers = players
        .filter((p) => p.teamId[0]?.toString() === teamId)
        .sort((a, b) => a.name.localeCompare(b.name));
    });
  }

  let register = function () {
    let config: TeamConfig = {
      pitcher: 0,
      catcher: 0,
      firstBase: 0,
      secondBase: 0,
      thirdBase: 0,
      shortStop: 0,
      leftField: 0,
      centerField: 0,
      rightField: 0,
      battingOrder: startingPlayers.map((p) => p.id),
      substitutes: substitutes,
    };
    startingPlayers.forEach((startingPlayer) => {
      switch (FieldPosition[startingPlayer.position]) {
        case FieldPosition.Pitcher:
          config.pitcher = startingPlayer.id;
          break;
        case FieldPosition.Catcher:
          config.catcher = startingPlayer.id;
          break;
        case FieldPosition.FirstBase:
          config.firstBase = startingPlayer.id;
          break;
        case FieldPosition.SecondBase:
          config.secondBase = startingPlayer.id;
          break;
        case FieldPosition.ThirdBase:
          config.thirdBase = startingPlayer.id;
          break;
        case FieldPosition.ShortStop:
          config.shortStop = startingPlayer.id;
          break;
        case FieldPosition.LeftField:
          config.leftField = startingPlayer.id;
          break;
        case FieldPosition.CenterField:
          config.centerField = startingPlayer.id;
          break;
        case FieldPosition.RightField:
          config.rightField = startingPlayer.id;
          break;
      }
    });
    teamAgentFactory(teamId)
      .registerForMatch(Principal.from(stadiumId), matchId, config)
      .then((result) => {
        console.log("Registered for match: ", result);
        teamStore.refetch();
      })
      .catch((err) => {
        console.log("Failed to make stadium: ", err);
      });
  };
  enum FieldPosition {
    Pitcher = "Pitcher",
    Catcher = "Catcher",
    FirstBase = "First Base",
    SecondBase = "Second Base",
    ThirdBase = "Third Base",
    ShortStop = "Shortstop",
    LeftField = "Left Field",
    CenterField = "Center Field",
    RightField = "Right Field",
  }

  $: availablePositions = (playerId: number) => {
    return Object.keys(FieldPosition).filter((position) => {
      return !startingPlayers.find(
        (p) => p.position === position && p.id !== playerId
      );
    });
  };

  let onPositionChange = (playerId: number) => (e) => {
    const positionValue = e.target.value;
    // Check if the value is a string containing only digits
    if (positionValue in FieldPosition) {
      // Add the player to the chosenPlayers array if not already present
      if (!startingPlayers.find((p) => p.id === playerId)) {
        startingPlayers = [
          ...startingPlayers,
          {
            id: playerId,
            text: teamPlayers.find((p) => p.id === playerId).name,
            position: positionValue,
          },
        ];
      }
    } else {
      // Remove the player from the chosenPlayers array if present
      startingPlayers = startingPlayers.filter(
        (chosenPlayer) => chosenPlayer.id !== playerId
      );
      if (positionValue === "sub") {
        substitutes = [...substitutes, playerId];
      } else {
        substitutes = substitutes.filter((id) => id !== playerId);
      }
    }
  };
</script>

<div>
  <label for="team">Team</label>
  <select id="team" bind:value={teamId}>
    {#each teams as team (team.id)}
      <option value={team.id.toString()}>{team.name}</option>
    {/each}
  </select>
</div>
<div>
  <label for="stadium">Stadium</label>
  <select id="stadium" bind:value={stadiumId}>
    {#each stadiums as stadium (stadium.id)}
      <option value={stadium.id}>{stadium.name}</option>
    {/each}
  </select>
</div>
<div>
  <label for="matchId">Match Id</label>
  <input type="number" id="matchId" bind:value={matchId} />
</div>
<div>
  <h2>Team Lineup</h2>
  {#each teamPlayers as player (player.id)}
    <div>
      <span>{player.name}</span>
      <select on:change={onPositionChange(player.id)}>
        <option value="">-</option>
        <option value="sub">Sub</option>
        {#each availablePositions(player.id) as position (position)}
          <option value={position}>
            {FieldPosition[position]}
          </option>
        {/each}
      </select>
    </div>
  {/each}
  <div>
    <h2>Batting Order</h2>
    <DragDropList bind:data={startingPlayers} removesItems={false} />
  </div>
</div>
<button on:click={register}>Register</button>

<style>
  :global(.dragdroplist) {
    width: 200px;
  } /* entire component */
  :global(.dragdroplist > .list > div.item) {
    background-color: var(--color-bg);
    color: var(--color-text);
  } /* list item */
  :global(.dragdroplist div.buttons > button.down) {
  } /* move down button */
  :global(.dragdroplist div.content) {
  } /* text/html contents of item */
</style>
