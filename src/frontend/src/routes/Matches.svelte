<script lang="ts">
  import MatchCardGrid from "../components/MatchCardGrid.svelte";
</script>

<MatchCardGrid matchFilter={(m) => m.winner != null} />
