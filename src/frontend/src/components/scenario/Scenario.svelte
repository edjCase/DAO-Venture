<script lang="ts">
  import ResolvedScenarioState from "./ResolvedScenarioState.svelte";
  import InProgressScenarioState from "./InProgressScenarioState.svelte";
  import { Scenario } from "../../ic-agent/declarations/league";
  import { userStore } from "../../stores/UserStore";
  import { User } from "../../ic-agent/declarations/users";
  import { getIdentity } from "../../stores/IdentityStore";
  import Countdown from "../common/Countdown.svelte";
  import { nanosecondsToDate } from "../../utils/DateUtils";

  export let scenario: Scenario;

  let user: User | undefined;
  $: {
    (async () => {
      let identity = await getIdentity();
      let id = identity.getPrincipal();
      if (!id.isAnonymous()) {
        userStore.subscribeUser(id, (u) => {
          user = u;
        });
      }
    })();
  }
  let stateLabel: string;
  if ("resolved" in scenario.state) {
    stateLabel = "Complete";
  } else if ("inProgress" in scenario.state) {
    stateLabel = "In Progress";
  } else {
    stateLabel = "Upcoming";
  }
</script>

<div class="p-6">
  <div class="text-3xl">
    {stateLabel}: {scenario.title}
  </div>
  <div class="my-6">
    {@html scenario.description}
  </div>
  <div class="flex flex-col items-center gap-2">
    {#if "resolved" in scenario.state}
      <ResolvedScenarioState
        state={scenario.state.resolved}
        options={scenario.options}
        userContext={user}
      />
    {:else if "inProgress" in scenario.state}
      <InProgressScenarioState
        scenarioId={scenario.id}
        options={scenario.options}
        userContext={user}
      />
      <div class="text-center text-xl">
        Scenario ends in: <Countdown
          date={nanosecondsToDate(scenario.endTime)}
        />
      </div>
    {/if}
  </div>
</div>
