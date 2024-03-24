<script lang="ts">
    import SeasonHome from "../components/season/SeasonHome.svelte";
    import ScenarioHome from "../components/scenario/ScenarioHome.svelte";
    import TeamsHome from "../components/team/TeamsHome.svelte";
    import MatchBanner from "../components/match/MatchBanner.svelte";
</script>

<div>
    <MatchBanner />
    <SeasonHome />
    <hr class="my-5" />
    <ScenarioHome />
    <hr class="my-5" />
    <TeamsHome />
</div>
