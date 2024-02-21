<script lang="ts">
  import CollapsedOverview from "../common/CollapsedOverview.svelte";
</script>

<CollapsedOverview title="In Between Matches">
  <section class="p-6">
    <!-- Introduction Paragraph -->
    <p class="text-lg mb-6">
      In between matches, dive into a world of strategic decisions and
      predictions, shaping the fate of your team. Engage with scenarios,
      forecast match winners, and immerse yourself in the ever-evolving
      narrative of DAOball.
    </p>

    <!-- Scenarios & Predictions -->
    <div class="bg-gray-700 p-4 rounded-lg shadow mb-6">
      <h3 class="text-xl font-semibold mb-2">Scenarios & Predictions</h3>
      <ul class="list-disc list-inside text-sm space-y-1">
        <li>
          Face dynamic <strong>scenarios</strong> that challenge your strategic acumen
        </li>
        <li>
          Make your mark by <strong>predicting match outcomes</strong>,
          competing with the community for points and prestige
        </li>
      </ul>
    </div>

    <!-- Upcoming Matches -->
    <div class="bg-gray-700 p-4 rounded-lg shadow">
      <h3 class="text-xl font-semibold mb-2">Upcoming Matches</h3>
      <ul class="list-disc list-inside text-sm space-y-1">
        <li>Stay ahead with a preview of <strong>upcoming matches</strong></li>
        <li>Strategize and anticipate in the dynamic world of DAOball</li>
      </ul>
    </div>
  </section>
</CollapsedOverview>
