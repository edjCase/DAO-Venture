<script lang="ts">
  import { navigate } from "svelte-routing";
  import MatchGroup from "../components/match/MatchGroup.svelte";
  import { scheduleStore } from "../stores/ScheduleStore";
  import { MatchGroupDetails } from "../models/Match";

  export let matchGroupIdString: string;

  let matchGroupId = Number(matchGroupIdString);
  if (isNaN(matchGroupId)) {
    // Handle the error, such as redirecting to an error page or showing a message
    navigate("/404", { replace: true });
  }

  var matchGroup: MatchGroupDetails | undefined;
  scheduleStore.subscribeMatchGroups(
    (seasonMatchGroups: MatchGroupDetails[]) => {
      if (seasonMatchGroups.length > 0) {
        matchGroup = seasonMatchGroups[matchGroupId];
      }
    }
  );
</script>

{#if !!matchGroup}
  <MatchGroup {matchGroup} />
{/if}
