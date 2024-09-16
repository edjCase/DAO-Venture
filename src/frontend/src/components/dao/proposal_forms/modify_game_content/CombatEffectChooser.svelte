<script lang="ts">
  import { SelectOptionType, Select } from "flowbite-svelte";
  import CombatEffectEditor from "./CombatEffectEditor.svelte";

  const combatEffectKinds: SelectOptionType<string>[] = [
    { value: "damage", name: "Damage" },
    { value: "heal", name: "Heal" },
    { value: "block", name: "Block" },
    { value: "addStatusEffect", name: "Add Status Effect" },
  ];
  let selectedCombatEffectKind: string = combatEffectKinds[0].value;

  let updateCombatEffectKind = (index: number) => () => {
    combatEffects = combatEffects.map((effect, i) => {
      if (i === index) {
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
            newKind = effect.kind;
        }
        return { ...effect, kind: newKind };
      }
      return effect;
    });
  };

  let updateCombatEffectTarget = (index: number) => {
    combatEffects = combatEffects.map((effect, i) => {
      if (i === index) {
        const newTarget: CombatEffectTarget =
          targetValue === "self" ? { self: null } : { targets: null };
        return { ...effect, target: newTarget };
      }
      return effect;
    });
  };
</script>

<Select
  items={combatEffectKinds}
  on:change={updateCombatEffectKind(index)}
  bind:value={selectedCombatEffectKind}
/>
<CombatEffectEditor {effect} />
<div>Target</div>
<Select
  items={[
    { value: "targets", name: "Targets" },
    { value: "self", name: "Self" },
  ]}
  on:change={updateCombatEffectTarget(index)}
  value={Object.keys(effect.target)[0]}
/>
