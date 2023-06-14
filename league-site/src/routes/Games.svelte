
<script lang="ts">
    import GameCardGrid from "../components/GameCardGrid.svelte";
  import { completedGamesStore } from "../stores/game-store";
</script>

<GameCardGrid games={$completedGamesStore} />