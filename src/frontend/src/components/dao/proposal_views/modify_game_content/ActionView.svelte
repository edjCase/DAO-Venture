<script lang="ts">
  import { Action } from "../../../../ic-agent/declarations/main";
  import { toJsonString } from "../../../../utils/StringUtil";
  import EntityView from "./EntityView.svelte";

  export let action: Action;
</script>

<div>
  <div>Action</div>
  <EntityView entity={action} />
  <div>
    <h3>Effects:</h3>
    <ul>
      {#each action.effects as effect}
        <li>
          {#if "damage" in effect.kind}
            Damage: {effect.kind.damage.min}-{effect.kind.damage.max}
          {:else if "heal" in effect.kind}
            Heal: {effect.kind.heal.min}-{effect.kind.heal.max}
          {:else if "addStatusEffect" in effect.kind}
            Add Status Effect:
            {#if "retaliating" in effect.kind.addStatusEffect.kind}
              Retaliating (Flat: {effect.kind.addStatusEffect.kind.retaliating
                .flat})
            {:else if "weak" in effect.kind.addStatusEffect.kind}
              Weak
            {:else if "vulnerable" in effect.kind.addStatusEffect.kind}
              Vulnerable
            {:else if "stunned" in effect.kind.addStatusEffect.kind}
              Stunned
            {:else}
              NOT IMPLEMENTED ADD STATUS EFFECT KIND: {toJsonString(
                effect.kind.addStatusEffect.kind
              )}
            {/if}
            {#if effect.kind.addStatusEffect.duration}
              for {effect.kind.addStatusEffect.duration[0]} turns
            {:else}
              (duration: indefinite)
            {/if}
          {:else if "block" in effect.kind}
            Block: {effect.kind.block.min}-{effect.kind.block.max}
          {:else}
            NOT IMPLEMENTED EFFECT Kind: {toJsonString(effect.kind)}
          {/if}
          (Target:
          {#if "self" in effect.target}
            Self
          {:else if "targets" in effect.target}
            Targets
          {:else}
            NOT IMPLEMENTED EFFECT TARGET: {toJsonString(effect.target)}
          {/if})
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
