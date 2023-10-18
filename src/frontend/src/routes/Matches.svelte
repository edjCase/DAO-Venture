<script lang="ts">
  import MatchCardGrid from "../components/MatchCardGrid.svelte";
</script>

<MatchCardGrid matchFilter={(m) => "completed" in m.state} />
