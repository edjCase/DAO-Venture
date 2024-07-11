<script lang="ts">
    import SeasonHome from "../components/season/SeasonHome.svelte";
    import ScenarioHome from "../components/scenario/ScenarioHome.svelte";
    import EntropyHome from "./entropy/EntropyHome.svelte";
    import PointsLeaderboard from "./user/PointsLeaderboard.svelte";
</script>

<div class="bg-gray-800 rounded">
    <SeasonHome />
    <EntropyHome />
    <ScenarioHome />
    <PointsLeaderboard />
</div>
