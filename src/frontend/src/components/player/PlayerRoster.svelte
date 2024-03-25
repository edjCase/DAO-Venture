<script lang="ts">
  import { playerStore } from "../../stores/PlayerStore";
  import { PlayerWithId } from "../../ic-agent/declarations/players";
  import { Link } from "svelte-routing";
  import UniqueAvatar from "../common/UniqueAvatar.svelte";
  import { positionToString } from "../../models/FieldPosition";
  import PlayerSkillRadarChart from "./PlayerSkillChart.svelte";
  import { Button } from "flowbite-svelte";

  export let teamId: bigint;

  let players: PlayerWithId[] | undefined;
  playerStore.subscribe((playerList) => {
    players = playerList
      ?.filter((p) => p.teamId?.toString() === teamId.toString())
      .sort((a, b) => a.id - b.id);
  });
</script>

{#if players !== undefined}
  <div class="grid grid-cols-1">
    {#each players as player}
      <div class="flex flex-col mt-2 border roudned p-5">
        <div class="flex flex-col items-center justify-center">
          <UniqueAvatar
            id={player.id}
            size={20}
            borderStroke={undefined}
            condition={undefined}
          />
          <div class="">
            #{player.id}
            {player.name}
          </div>
        </div>
        <div>{positionToString(player.position)}</div>
        <div class="flex">
          <PlayerSkillRadarChart skills={player.skills} />
          <Link to={"/players/" + player.id}><Button>Details</Button></Link>
        </div>
      </div>
    {/each}
  </div>
{/if}
