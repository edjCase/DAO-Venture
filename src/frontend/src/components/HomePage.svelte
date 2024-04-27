<script lang="ts">
    import SeasonHome from "../components/season/SeasonHome.svelte";
    import ScenarioHome from "../components/scenario/ScenarioHome.svelte";
    import EntropyHome from "./entropy/EntropyHome.svelte";
    import MatchBanner from "../components/match/MatchBanner.svelte";
    import { Hr } from "flowbite-svelte";
    import PointsLeaderboard from "./user/PointsLeaderboard.svelte";
</script>

<div class="mt-2">
    <MatchBanner />
    <Hr classHr="w-48 h-1 mx-auto my-6 rounded" />
    <EntropyHome />
    <Hr classHr="w-48 h-1 mx-auto my-6 rounded" />
    <SeasonHome />
    <Hr classHr="w-48 h-1 mx-auto my-6 rounded" />
    <ScenarioHome />
    <Hr classHr="w-48 h-1 mx-auto my-6 rounded" />
    <PointsLeaderboard />
</div>
