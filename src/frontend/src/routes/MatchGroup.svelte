<script lang="ts">
  import { navigate } from "svelte-routing";
  import MatchGroup from "../components/match/MatchGroup.svelte";

  export let matchGroupIdString: string;

  let matchGroupId = Number(matchGroupIdString);
  if (isNaN(matchGroupId)) {
    // Handle the error, such as redirecting to an error page or showing a message
    navigate("/404", { replace: true });
  }
</script>

<MatchGroup {matchGroupId} />
