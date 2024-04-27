<script lang="ts">
    import CollapsedOverview from "../common/CollapsedOverview.svelte";
    import EntropyBar from "./EntropyBar.svelte";
</script>

<CollapsedOverview title="Entropy">
    <ul class="list-disc list-inside text-sm space-y-1">
        <li>Entropy is a measure of chaos in the league</li>
        <li>
            If the entropy gets too high, the league will collapse into chaos
        </li>
        <li>
            Each team has their own entropy metric. When the team is
            collaborative the entropy goes down, when selfish it goes up
        </li>
    </ul>
</CollapsedOverview>
<EntropyBar />
