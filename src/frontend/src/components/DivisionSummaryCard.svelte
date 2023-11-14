<script lang="ts">
  import { DivisionSchedule } from "../ic-agent/League";
  import { MatchGroup } from "../ic-agent/Stadium";
  import { MatchGroupDetails, mapMatchGroup } from "../models/Match";
  import { matchGroupStore } from "../stores/MatchGroupStore";
  import MatchGroupSummaryCard from "./MatchGroupSummaryCard.svelte";

  export let division: DivisionSchedule;

  let lastMatchGroup: MatchGroupDetails | undefined;
  let nextOrCurrentMatchGroup: MatchGroupDetails | undefined;

  matchGroupStore.subscribe((matchGroups: MatchGroup[]) => {
    let divisionMatchGroups = matchGroups.filter((mg) =>
      division.matchGroupIds.includes(mg.id)
    );
    let last = divisionMatchGroups
      .filter((mg) => "completed" in mg.state)
      .sort((a, b) => Number(b.time) - Number(a.time))
      .at(0);
    let nextOrCurrent = divisionMatchGroups
      .filter((mg) => "inProgress" in mg.state || "notStarted" in mg.state)
      .sort((a, b) => Number(b.time) - Number(a.time))
      .at(0);
    lastMatchGroup = !last ? undefined : mapMatchGroup(last);
    nextOrCurrentMatchGroup = !nextOrCurrent
      ? undefined
      : mapMatchGroup(nextOrCurrent);
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
