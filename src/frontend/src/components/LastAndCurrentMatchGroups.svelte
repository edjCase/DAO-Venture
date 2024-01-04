<script lang="ts">
  import { MatchGroupDetails } from "../models/Match";
  import { scheduleStore } from "../stores/ScheduleStore";
  import MatchGroupSummaryCard from "./MatchGroupSummaryCard.svelte";

  let lastMatchGroup: MatchGroupDetails | undefined;
  let nextOrCurrentMatchGroup: MatchGroupDetails | undefined;

  scheduleStore.subscribeMatchGroups((matchGroups: MatchGroupDetails[]) => {
    lastMatchGroup = matchGroups
      .slice()
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
    <div class="item last">
      <div>Last</div>
      <MatchGroupSummaryCard matchGroup={lastMatchGroup} />
    </div>
  {/if}
  {#if nextOrCurrentMatchGroup}
    <div class="item next">
      <div>Next</div>
      <MatchGroupSummaryCard matchGroup={nextOrCurrentMatchGroup} />
    </div>
  {/if}
</div>

<style lang="postcss">
  .lastAndNext {
    display: flex;
    justify-content: center;
  }
  .item {
    margin: 0 20px;
  }
</style>
