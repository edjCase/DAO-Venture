<script lang="ts">
    import SeasonHome from "../components/season/SeasonHome.svelte";
    import ScenarioHome from "../components/scenario/ScenarioHome.svelte";
    import EntropyHome from "../components/team/EntropyHome.svelte";
    import MatchBanner from "../components/match/MatchBanner.svelte";
</script>

<div class="mt-2">
    <MatchBanner />
    <hr class="mt-2 mb-5" />
    <SeasonHome />
    <hr class="my-5" />
    <ScenarioHome />
    <hr class="my-5" />
    <EntropyHome />
</div>
