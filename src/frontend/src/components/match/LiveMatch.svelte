<!-- <script lang="ts">
  import { MatchDetails } from "../../models/Match";

  import { LiveMatch, LiveTownDetails } from "../../stores/LiveMatchGroupStore";
  import { townStore } from "../../stores/TownStore";
  import Field from "./Field.svelte";
  import TownFieldInfo from "./TownFieldInfo.svelte";

  export let match: MatchDetails;
  export let liveMatch: LiveMatch;

  let offenseTown: LiveTownDetails | undefined;
  let defenseTown: LiveTownDetails | undefined;
  let winner: string | undefined;

  $: towns = $townStore;

  $: {
    if ("score" in match.town1 && "score" in match.town2) {
      match.town1.score = liveMatch.town1.score;
      match.town2.score = liveMatch.town2.score;
    }
    if (liveMatch) {
      match.winner = liveMatch.winner;
    }
    if (match.winner && "id" in match.town1 && "id" in match.town2) {
      let town1Id = match.town1.id;
      let town2Id = match.town2.id;
      if ("town1" in match.winner) {
        winner = towns?.find((t) => t.id == town1Id)?.name;
      } else if ("town2" in match.winner) {
        winner = towns?.find((t) => t.id == town2Id)?.name;
      } else {
        winner = "Tie";
      }
    }
    if (liveMatch.liveState) {
      if ("town1" in liveMatch.liveState.offenseTownId) {
        offenseTown = liveMatch.town1;
        defenseTown = liveMatch.town2;
      } else if ("town2" in liveMatch.liveState.offenseTownId) {
        offenseTown = liveMatch.town2;
        defenseTown = liveMatch.town1;
      }
    }
  }
</script>

<div class="w-full">
  {#if liveMatch && !!liveMatch.liveState}
    <div class="text-center text-3xl mb-5">
      Round {liveMatch.log?.rounds.length}
    </div>
    <div class="absolute top-[300px] left-[5%]">
        {#if "id" in match.town1 && "id" in match.town2}
          {#each lastTurn.events as e}
            <MatchEvent
              event={e}
              town1Id={match.town1.id}
              town2Id={match.town2.id}
            />
          {/each}
        {/if}
      </div>
    {#if defenseTown}
      <TownFieldInfo town={defenseTown} isOffense={false} />
    {/if}
    <Field match={liveMatch} />
    {#if offenseTown}
      <TownFieldInfo town={offenseTown} isOffense={true} />
    {/if}
  {:else if winner}
    <div class="text-center text-3xl mb-5">
      Winner: {winner}
    </div>
  {:else}
    <div class="text-center text-3xl mb-5">No Live</div>
  {/if}
</div>
-->
