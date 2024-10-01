<script lang="ts">
  import { SelectOptionType, Select } from "flowbite-svelte";
  import CombatEffectEditor from "./CombatEffectEditor.svelte";
  import {
    CombatEffect,
    CombatEffectKind,
    CombatEffectTarget,
  } from "../../../../ic-agent/declarations/main";

  export let value: CombatEffect;

  const combatEffectKinds: SelectOptionType<string>[] = [
    { value: "damage", name: "Damage" },
    { value: "heal", name: "Heal" },
    { value: "block", name: "Block" },
    { value: "addStatusEffect", name: "Add Status Effect" },
  ];
  let selectedCombatEffectKind: string = combatEffectKinds[0].value;

  const targetItems: SelectOptionType<string>[] = [
    { value: "targets", name: "Targets" },
    { value: "self", name: "Self" },
  ];

  let selectedTarget: string = targetItems[0].value;

  let updateCombatEffectKind = () => {
    let newKind: CombatEffectKind;
    switch (selectedCombatEffectKind) {
      case "damage":
        newKind = {
          damage: { min: 1n, max: 1n, timing: { immediate: null } },
        };
        break;
      case "heal":
        newKind = {
          heal: { min: 1n, max: 1n, timing: { immediate: null } },
        };
        break;
      case "addStatusEffect":
        newKind = {
          addStatusEffect: { kind: { weak: null }, duration: [] },
        };
        break;
      case "block":
        newKind = {
          block: { min: 1n, max: 1n, timing: { immediate: null } },
        };
        break;
      default:
        throw new Error(
          "Invalid combat effect kind: " + selectedCombatEffectKind
        );
    }
    value = { ...value, kind: newKind };
  };

  let updateCombatEffectTarget = () => () => {
    let newTarget: CombatEffectTarget;
    switch (selectedTarget) {
      case "self":
        newTarget = { self: null };
        break;
      case "targets":
        newTarget = { targets: null };
        break;
      default:
        throw new Error("Invalid combat effect target: " + selectedTarget);
    }
    value = { ...value, target: newTarget };
  };
</script>

<Select
  items={combatEffectKinds}
  on:change={updateCombatEffectKind}
  bind:value={selectedCombatEffectKind}
/>
<CombatEffectEditor bind:effect={value} />
<div>Target</div>
<Select
  items={targetItems}
  on:change={updateCombatEffectTarget}
  bind:value={selectedTarget}
/>
