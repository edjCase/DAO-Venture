<script lang="ts">
    import SectionWithOverview from "../common/SectionWithOverview.svelte";
    import MatchBanner from "../match/MatchBanner.svelte";
</script>

<SectionWithOverview title="Matches">
    <ul slot="details" class="list-disc list-inside text-sm space-y-1">
        <li>
            The season is a series of matches where teams compete to win the
            championship
        </li>
        <li>
            Each match group has a set of matches that are played in parallel
        </li>
        <li>
            The season champion is the team with the most points at the end of
            the season
        </li>
    </ul>

    <MatchBanner />
</SectionWithOverview>
