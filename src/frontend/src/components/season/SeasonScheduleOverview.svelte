<script lang="ts">
  import SectionWithOverview from "../common/SectionWithOverview.svelte";
</script>

<SectionWithOverview title="Schedule Overview">
  <div slot="details">
    <!-- Match Groups -->
    <div class="mb-6">
      <div class="bg-gray-700 rounded-lg shadow p-4 border border-gray-600">
        <h3 class="text-xl font-semibold mb-3 text-gray-100">Match Groups</h3>
        <p class="text-sm">
          Central to the regular season, ensuring continuous action and
          engagement.
        </p>
      </div>
    </div>

    <!-- Regular Season -->
    <div class="mb-6">
      <div class="bg-gray-700 rounded-lg shadow p-4 border border-gray-600">
        <h3 class="text-xl font-semibold mb-3 text-gray-100">Regular Season</h3>
        <ul class="list-disc list-inside text-sm">
          <li>Format: <strong>Round Robin</strong></li>
          <li>Each town plays others <strong>once</strong></li>
          <li>Matches occur every <strong>2 Days</strong></li>
          <li>
            All matches in a group happen <strong>simultaneously</strong>
          </li>
        </ul>
      </div>
    </div>

    <!-- Playoffs -->
    <div class="mb-6">
      <div class="bg-gray-700 rounded-lg shadow p-4 border border-gray-600">
        <h3 class="text-xl font-semibold mb-3 text-gray-100">Playoffs</h3>
        <ul class="list-disc list-inside text-sm">
          <li>Format: <strong>Single Elimination</strong></li>
          <li>Based on <strong>regular season standings</strong></li>
        </ul>
      </div>
    </div>
  </div>
</SectionWithOverview>
