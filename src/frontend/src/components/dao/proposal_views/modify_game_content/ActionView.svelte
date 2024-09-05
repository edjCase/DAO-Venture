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
            Add Status Effect: {effect.kind.addStatusEffect.kind}
          {:else if "block" in effect.kind}
            Block: {effect.kind.block.min}-{effect.kind.block.max}
          {:else}
            Unknown effect
          {/if}
          (Target:
          {#if "any" in effect.target.scope}
            Any
          {:else if "ally" in effect.target.scope}
            Ally
          {:else if "enemy" in effect.target.scope}
            Enemy
          {/if}
          {#if "all" in effect.target.selection}
            All
          {:else if "random" in effect.target.selection}
            Random {effect.target.selection.random.count}
          {:else if "chosen" in effect.target.selection}
            Chosen
          {/if})
        </li>
      {/each}
    </ul>
  </div>
</div>
