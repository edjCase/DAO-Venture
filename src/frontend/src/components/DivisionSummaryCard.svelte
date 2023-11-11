<script lang="ts">
  import { DivisionDetails, MatchGroupDetails } from "../models/Match";
  import MatchGroupSummaryCard from "./MatchGroupSummaryCard.svelte";

  export let division: DivisionDetails;

  let lastMatchGroup: MatchGroupDetails | undefined = division.matchGroups
    .filter((mg) => "completed" in mg.state)
    .sort((a, b) => Number(b.time) - Number(a.time))
    .at(0);
  let nextOrCurrent: MatchGroupDetails | undefined = division.matchGroups
    .filter((mg) => "inProgress" in mg.state || "notStarted" in mg.state)
    .sort((a, b) => Number(b.time) - Number(a.time))
    .at(0);
</script>

<div>
  {#if lastMatchGroup}
    <div>
      <div>Last</div>
      <MatchGroupSummaryCard matchGroup={lastMatchGroup} />
    </div>
  {/if}
  {#if nextOrCurrent}
    <div>
      <div>Next</div>
      <MatchGroupSummaryCard matchGroup={nextOrCurrent} />
    </div>
  {/if}
</div>
