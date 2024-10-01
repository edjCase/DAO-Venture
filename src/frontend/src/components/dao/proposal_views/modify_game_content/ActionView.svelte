<script lang="ts">
  import { Action } from "../../../../ic-agent/declarations/main";
  import { toJsonString } from "../../../../utils/StringUtil";
  import CombatEffectView from "./CombatEffectView.svelte";
  import EntityView from "./EntityView.svelte";
  import ScenarioEffectView from "./ScenarioEffectView.svelte";

  export let action: Action;
</script>

<div>
  <div class="text-xl text-primary-500 font-bold">Action</div>
  <EntityView entity={action} />

  <div class="text-primary-500">Scenario Effects</div>
  <div class="pl-8">
    <ul>
      {#each action.scenarioEffects as effect}
        <li>
          <ScenarioEffectView {effect} />
        </li>
      {/each}
    </ul>
  </div>

  <div class="text-primary-500">Combat Effects</div>
  <div class="pl-8">
    <ul>
      {#each action.combatEffects as effect}
        <li>
          <CombatEffectView {effect} />
        </li>
      {/each}
    </ul>
  </div>
  <div class="text-primary-500">Target</div>
  <div class="pl-8">
    <div class="text-primary-500">Scope</div>
    <div>
      {#if "any" in action.target.scope}
        Any
      {:else if "ally" in action.target.scope}
        Ally
      {:else if "enemy" in action.target.scope}
        Enemy
      {:else}
        NOT IMPLEMENTED TARGET SCOPE: {toJsonString(action.target.scope)}
      {/if}
    </div>
    <div class="text-primary-500">Selection</div>
    <div>
      {#if "all" in action.target.selection}
        All
      {:else if "random" in action.target.selection}
        Random {action.target.selection.random.count}
      {:else if "chosen" in action.target.selection}
        Choose Target
      {:else}
        NOT IMPLEMENTED TARGET SELECTION: {toJsonString(
          action.target.selection
        )}
      {/if}
    </div>
  </div>
</div>
