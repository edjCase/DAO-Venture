<script lang="ts">
  import { Action } from "../../../../ic-agent/declarations/main";
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
            Add Status Effect: {JSON.stringify(effect.kind.addStatusEffect)}
          {:else if "block" in effect.kind}
            Block: {effect.kind.block.min}-{effect.kind.block.max}
          {:else}
            Unknown effect
          {/if}
          (Target:
          {#if "self" in effect.target}
            Self
          {:else if "targets" in effect.target}
            Targets
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
      {/if}
      Selection:
      {#if "all" in action.target.selection}
        All
      {:else if "random" in action.target.selection}
        Random {action.target.selection.random.count}
      {:else if "chosen" in action.target.selection}
        Chosen
      {/if}
    </p>
  </div>
</div>
