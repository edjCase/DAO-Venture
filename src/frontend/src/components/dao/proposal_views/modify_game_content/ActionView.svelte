<script lang="ts">
  import { Action } from "../../../../ic-agent/declarations/main";
  import { toJsonString } from "../../../../utils/StringUtil";
  import CombatEffectView from "./CombatEffectView.svelte";
  import EntityView from "./EntityView.svelte";
  import ScenarioEffectView from "./ScenarioEffectView.svelte";

  export let action: Action;
</script>

<div>
  <div>Action</div>
  <EntityView entity={action} />

  <div>
    <h3>Scenario Effects:</h3>
    <ul>
      {#each action.scenarioEffects as effect}
        <li>
          <ScenarioEffectView {effect} />
        </li>
      {/each}
    </ul>
  </div>

  <div>
    <h3>Combat Effects:</h3>
    <ul>
      {#each action.combatEffects as effect}
        <li>
          <CombatEffectView {effect} />
        </li>
      {/each}
    </ul>
  </div>
  <div>
    <h3>Target:</h3>
    <p>
      Scope:
      {#if "any" in action.target.scope}
        Any
      {:else if "ally" in action.target.scope}
        Ally
      {:else if "enemy" in action.target.scope}
        Enemy
      {:else}
        NOT IMPLEMENTED TARGET SCOPE: {toJsonString(action.target.scope)}
      {/if}
      Selection:
      {#if "all" in action.target.selection}
        All
      {:else if "random" in action.target.selection}
        Random {action.target.selection.random.count}
      {:else if "chosen" in action.target.selection}
        Chosen
      {:else}
        NOT IMPLEMENTED TARGET SELECTION: {toJsonString(
          action.target.selection
        )}
      {/if}
    </p>
  </div>
</div>
