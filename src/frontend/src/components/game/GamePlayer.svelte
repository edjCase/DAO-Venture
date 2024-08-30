<script lang="ts">
  import VotingGame from "./VotingGame.svelte";
  import { GameWithMetaData, User } from "../../ic-agent/declarations/main";
  import LobbyGame from "./LobbyGame.svelte";
  import InProgressGame from "./InProgressGame.svelte";
  import CompleteGame from "./CompleteGame.svelte";

  export let game: GameWithMetaData;
  export let user: User;
</script>

<div>
  {#if "notStarted" in game.state}
    <LobbyGame {game} {user} />
  {:else if "voting" in game.state}
    <VotingGame {game} {user} state={game.state.voting} />
  {:else if "inProgress" in game.state}
    <InProgressGame {game} {user} />
  {:else}
    <CompleteGame {game} state={game.state.completed} />
  {/if}
  <!-- <MermaidDiagram /> -->
</div>
