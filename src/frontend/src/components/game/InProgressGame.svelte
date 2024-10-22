<script lang="ts">
  import {
    CompletedRouteLocationKind,
    InProgressGameStateWithMetaData,
    InProgressRouteLocationKind,
  } from "../../ic-agent/declarations/main";
  import RouteHexGrid from "./RouteHexGrid.svelte";
  import RouteLocation from "./RouteLocation.svelte";

  export let state: InProgressGameStateWithMetaData;

  let selectedLocationIndex: number;
  $: if (selectedLocationIndex === undefined) {
    selectedLocationIndex = state.completedLocations.length;
  }

  let location:
    | { inProgress: InProgressRouteLocationKind }
    | { completed: CompletedRouteLocationKind }
    | undefined;
  $: {
    if (selectedLocationIndex < state.completedLocations.length) {
      location = { completed: state.completedLocations[selectedLocationIndex] };
    } else if (selectedLocationIndex === state.completedLocations.length) {
      location = { inProgress: state.currentLocation };
    } else {
      location = undefined;
    }
  }
  let nextLocation = () => {
    selectedLocationIndex += 1;
  };
</script>

<RouteHexGrid
  bind:selectedLocationIndex
  route={state.route}
  completedLocations={state.completedLocations}
  currentLocation={state.currentLocation}
/>
{#if location !== undefined}
  <RouteLocation {location} character={state.character} {nextLocation} />
{/if}
