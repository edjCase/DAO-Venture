<script lang="ts">
  import { GameWithMetaData, User } from "../../ic-agent/declarations/main";
  import WorldGrid from "../world/WorldGrid.svelte";
  import GameNav from "./GameNav.svelte";

  export let game: GameWithMetaData;
  export let user: User;
</script>

<GameNav {game} {user}>
  <WorldGrid />
</GameNav>
