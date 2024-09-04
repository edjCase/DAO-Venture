<script lang="ts">
  import { GameWithMetaData } from "../../ic-agent/declarations/main";
  import WorldGrid from "../world/WorldGrid.svelte";
  import GameNav from "./GameNav.svelte";

  export let game: GameWithMetaData;
</script>

<GameNav {game}>
  <WorldGrid />
</GameNav>
