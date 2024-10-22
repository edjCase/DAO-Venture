<script lang="ts">
  import {
    CharacterWithMetaData,
    CompletedRouteLocationKind,
    InProgressRouteLocationKind,
  } from "../../ic-agent/declarations/main";
  import CompletedScenario from "../scenario/CompletedScenario.svelte";
  import Scenario from "../scenario/Scenario.svelte";

  export let location:
    | { inProgress: InProgressRouteLocationKind }
    | { completed: CompletedRouteLocationKind };
  export let character: CharacterWithMetaData;
  export let nextLocation: () => void;
</script>

{#if "inProgress" in location}
  <Scenario scenario={location.inProgress.scenario} {character} />
{:else}
  <CompletedScenario scenario={location.completed.scenario} {nextLocation} />
{/if}
