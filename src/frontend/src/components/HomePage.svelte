<script lang="ts">
    import SeasonHome from "../components/season/SeasonHome.svelte";
    import ScenarioHome from "../components/scenario/ScenarioHome.svelte";
    import EntropyHome from "./entropy/EntropyHome.svelte";
    import MatchBanner from "../components/match/MatchBanner.svelte";
</script>

<div class="mt-2">
    <MatchBanner />
    <hr class="mt-2 mb-5" />
    <EntropyHome />
    <hr class="my-5" />
    <SeasonHome />
    <hr class="my-5" />
    <ScenarioHome />
</div>
