<script lang="ts">
  import ResolvedScenarioState from "./ResolvedScenarioState.svelte";
  import InProgressScenarioState from "./InProgressScenarioState.svelte";
  import { Scenario } from "../../ic-agent/declarations/league";
  import { userStore } from "../../stores/UserStore";
  import { User } from "../../ic-agent/declarations/users";
  import { getIdentity } from "../../stores/IdentityStore";

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

<div>
  <div class="text-3xl p-5">
    {stateLabel}: {scenario.title}
  </div>
  <div class="p-5 pt-0">
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
    {/if}
  </div>
</div>
