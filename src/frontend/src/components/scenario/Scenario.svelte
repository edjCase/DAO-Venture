<script lang="ts">
  import ResolvedScenarioState from "./ResolvedScenarioState.svelte";
  import InProgressScenarioState from "./InProgressScenarioState.svelte";
  import { Scenario } from "../../ic-agent/declarations/league";
  import { scenarioStore } from "../../stores/ScenarioStore";
  import { userStore } from "../../stores/UserStore";
  import { User } from "../../ic-agent/declarations/users";
  import { getIdentity } from "../../stores/IdentityStore";

  export let scenarioId: string;

  let scenario: Scenario | undefined;

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

  scenarioStore.subscribeById(scenarioId, (s) => {
    scenario = s;
  });
</script>

{#if scenario}
  <div>
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
      {:else if "notStarted" in scenario.state}
        Not Started
      {/if}
    </div>
  </div>
{:else}
  <div>Loading...</div>
{/if}
