<script lang="ts">
  import { Card } from "flowbite-svelte";
  import { playerStore } from "../../stores/PlayerStore";
  import { teamStore } from "../../stores/TeamStore";
  import { Link } from "svelte-routing";
  import UniqueAvatar from "../common/UniqueAvatar.svelte";
  import { positionToString } from "../../models/FieldPosition";
  import { PlayerWithId } from "../../ic-agent/declarations/stadium";

  // Assuming you have a way to fetch players
  let players: PlayerWithId[] | undefined; // Populate this array with player data
  $: players = $playerStore?.sort((a, b) => a.name.localeCompare(b.name));
  $: teams = $teamStore;
</script>

<div class="p-6 mx-auto lg:max-w-2xl xl:max-w-3xl">
  {#if players !== undefined}
    <div class="grid grid-cols-1 md:grid-cols-3">
      {#each players as player}
        <Card class="mx-auto mb-2 cursor-pointer relative">
          <Link to={"/players/" + player.id}>
            <div class="font-bold text-lg">{player.name}</div>
            {#if player.teamId}
              <div class="text-sm text-gray-600">
                {teams?.find(
                  (t) => t.id.toString() === player.teamId?.toString(),
                )?.name}
              </div>
            {/if}
            <div class="text-sm">{positionToString(player.position)}</div>
            <div class="absolute top-5 right-5">
              <UniqueAvatar
                id={player.id}
                size={50}
                borderStroke={undefined}
                condition={undefined}
              />
            </div>

            <div class="text-sm text-gray-600">{player.description}</div>
          </Link>
        </Card>
      {/each}
    </div>
  {/if}
</div>
