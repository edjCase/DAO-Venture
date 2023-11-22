<script lang="ts">
  import { MatchGroupSchedule, SeasonStatus } from "../ic-agent/League";
  import { seasonStatusStore } from "../stores/ScheduleStore";
  import MatchGroupSummaryCard from "./MatchGroupSummaryCard.svelte";

  let lastMatchGroup: MatchGroupSchedule | undefined;
  let nextOrCurrentMatchGroup: MatchGroupSchedule | undefined;

  seasonStatusStore.subscribe((seasonStatus: SeasonStatus) => {
    if ("inProgress" in seasonStatus) {
      lastMatchGroup = seasonStatus.inProgress.matchGroups
        .filter((mg) => "completed" in mg.status)
        .sort((a, b) => Number(b.time) - Number(a.time))
        .at(0);
      nextOrCurrentMatchGroup = seasonStatus.inProgress.matchGroups
        .filter((mg) => "inProgress" in mg.status || "scheduled" in mg.status)
        .sort((a, b) => Number(b.time) - Number(a.time))
        .at(0);
    } else {
      lastMatchGroup = undefined;
      nextOrCurrentMatchGroup = undefined;
    }
  });
</script>

<div>
  {#if lastMatchGroup}
    <div>
      <div>Last</div>
      <MatchGroupSummaryCard matchGroup={lastMatchGroup} />
    </div>
  {/if}
  {#if nextOrCurrentMatchGroup}
    <div>
      <div>Next</div>
      <MatchGroupSummaryCard matchGroup={nextOrCurrentMatchGroup} />
    </div>
  {/if}
</div>
