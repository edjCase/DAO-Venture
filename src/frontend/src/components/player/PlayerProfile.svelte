<script lang="ts">
  import { Player } from "../../ic-agent/PlayerLedger";
  import { positionToString } from "../../models/Player";

  export let player: Player;

  // Filter skills to include only those with non-zero values
  const relevantSkills = Object.entries(player.skills).filter(
    ([_, value]) => value !== 0
  );
</script>

<div class="rounded-lg p-6">
  <div class="text-lg font-bold">{player.name} - #{player.id}</div>
  <div class="text-md">{positionToString(player.position)}</div>
  <div class="text-sm text-gray-600">{player.genesis}</div>
  <div class="grid grid-cols-1 md:grid-cols-3 gap-4 mt-4">
    <div>
      <div class="font-semibold">Quirks:</div>
      <ul class="list-disc list-inside">
        {#each player.quirks as quirk}
          <li>{quirk}</li>
        {/each}
      </ul>
    </div>
    <div>
      <div class="font-semibold">Likes:</div>
      <ul class="list-disc list-inside">
        {#each player.likes as like}
          <li>{like}</li>
        {/each}
      </ul>
    </div>
    <div>
      <div class="font-semibold">Dislikes:</div>
      <ul class="list-disc list-inside">
        {#each player.dislikes as dislike}
          <li>{dislike}</li>
        {/each}
      </ul>
    </div>
  </div>
  <div class="mt-4">
    <div class="font-semibold">Skills:</div>
    <div class="p-4 rounded-lg">
      <ul class="list-disc list-inside">
        {#each relevantSkills as [skill, value]}
          <li class="font-semibold">
            {skill}: <span class="font-normal">{value}</span>
          </li>
        {/each}
      </ul>
    </div>
  </div>
</div>
