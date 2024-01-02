<script lang="ts">
  import { MatchGroupDetails } from "../models/Match";
  import { scheduleStore } from "../stores/ScheduleStore";
  import MatchGroupSummaryCard from "./MatchGroupSummaryCard.svelte";

  let lastMatchGroup: MatchGroupDetails | undefined;
  let nextOrCurrentMatchGroup: MatchGroupDetails | undefined;

  scheduleStore.subscribeMatchGroups((matchGroups: MatchGroupDetails[]) => {
    lastMatchGroup = matchGroups
      .reverse()
      .find((mg) => mg.state == "Completed");
    nextOrCurrentMatchGroup = matchGroups.find(
      (mg) =>
        mg.id > (lastMatchGroup?.id || -1) &&
        (mg.state == "InProgress" || mg.state == "Scheduled")
    );
  });
</script>

<div class="lastAndNext">
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

<style lang="postcss">
  .lastAndNext {
    display: flex;
    justify-content: space-around;
  }
</style>
