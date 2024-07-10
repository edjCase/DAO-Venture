<script lang="ts">
  import { navigate } from "svelte-routing";
  import MatchGroup from "../components/match/MatchGroup.svelte";
  import { scheduleStore } from "../stores/ScheduleStore";
  import { InProgressSeasonMatchGroupVariant } from "../ic-agent/declarations/main";

  export let matchGroupIdString: string;

  let matchGroupId = Number(matchGroupIdString);
  if (isNaN(matchGroupId)) {
    // Handle the error, such as redirecting to an error page or showing a message
    navigate("/404", { replace: true });
  }

  var matchGroup: InProgressSeasonMatchGroupVariant | undefined;
  scheduleStore.subscribeMatchGroups(
    (seasonMatchGroups: InProgressSeasonMatchGroupVariant[]) => {
      if (seasonMatchGroups.length > 0) {
        matchGroup = seasonMatchGroups[matchGroupId];
      }
    },
  );
</script>

{#if !!matchGroup}
  <MatchGroup {matchGroupId} {matchGroup} lastMatchGroup={undefined} />
{/if}
