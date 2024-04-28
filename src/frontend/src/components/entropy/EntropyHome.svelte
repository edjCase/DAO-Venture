<script lang="ts">
    import SectionWithOverview from "../common/SectionWithOverview.svelte";
    import EntropyBar from "./EntropyBar.svelte";
</script>

<SectionWithOverview title="Entropy">
    <ul slot="details" class="list-disc list-inside text-sm space-y-1">
        <li>Entropy is a measure of chaos in the league</li>
        <li>
            If the entropy gets too high, the league will collapse into chaos
        </li>
        <li>
            Each team has their own entropy metric. When the team is
            collaborative the entropy goes down, when selfish it goes up
        </li>
    </ul>
    <div class="border-2 rounded border-gray-700 p-4">
        <div class="w-96 mx-auto">
            <EntropyBar />
        </div>
    </div>
</SectionWithOverview>
