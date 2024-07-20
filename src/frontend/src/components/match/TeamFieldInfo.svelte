<!-- <script lang="ts">
  import { LiveTownDetails } from "../../stores/LiveMatchGroupStore";
  import TownLogo from "../town/TownLogo.svelte";

  export let town: LiveTownDetails;
  export let isOffense: boolean;
</script>

<div
  class="flex justify-between p-5 border border-gray-300 border-opacity-50 {!isOffense
    ? 'border-b-0 rounded-t'
    : 'border-t-0 rounded-b'}"
>
  <div class="flex-1 flex flex-col text-2xl items-center justify-center">
    <div class="flex justify-center font-bold underline">
      {isOffense ? "Offense" : "Defense"}
    </div>
    <div class="text-center">
      {town.name}
    </div>
  </div>
  <div class="flex-1 flex items-center justify-center">
    <TownLogo {town} size="md" />
  </div>
  <div class="flex-1 flex text-7xl items-center justify-center">
    {town.score}
  </div>
</div> -->
