<script lang="ts">
  import { SelectOptionType, Input, Select, Label } from "flowbite-svelte";
  import {
    ActionTimingKind,
    TurnPhase,
  } from "../../../../ic-agent/declarations/main";

  export let value: { min: bigint; max: bigint; timing: ActionTimingKind };

  const timingKinds: SelectOptionType<string>[] = [
    { value: "immediate", name: "Immediate" },
    { value: "periodic", name: "Periodic" },
  ];

  const phaseKinds: SelectOptionType<string>[] = [
    { value: "start", name: "Start" },
    { value: "end", name: "End" },
  ];

  let selectedTimingKind: string = timingKinds[0].value;
  let selectedPhaseKind: string = phaseKinds[0].value;
  let periodicTurns: bigint = 1n;

  let updateTiming = () => {
    if (selectedTimingKind === "immediate") {
      value.timing = { immediate: null };
    } else {
      value.timing = {
        periodic: { phase: { start: null }, remainingTurns: periodicTurns },
      };
    }
  };

  let updatePeriodicTurns = () => {
    if ("periodic" in value.timing) {
      value.timing.periodic.remainingTurns = BigInt(periodicTurns);
    }
  };

  let updatePhaseKind = () => {
    if ("periodic" in value.timing) {
      value.timing.periodic.phase = { [selectedPhaseKind]: null } as TurnPhase;
    }
  };
</script>

<div class="mt-2">
  <div class="flex gap-2">
    <Label>Min</Label>
    <Input type="number" bind:value={value.min} placeholder="Min" />
    <Label>Max</Label>
    <Input type="number" bind:value={value.max} placeholder="Max" />
  </div>
  <Label>Timing</Label>
  <Select
    items={timingKinds}
    bind:value={selectedTimingKind}
    on:change={updateTiming}
  />
  {#if selectedTimingKind === "periodic"}
    <div class="flex gap-2">
      <Label>Phase</Label>
      <Select
        items={phaseKinds}
        bind:value={selectedPhaseKind}
        on:change={updatePhaseKind}
      />
      <Label>Period</Label>
      <Input
        type="number"
        bind:value={periodicTurns}
        on:change={updatePeriodicTurns}
      />
    </div>
  {/if}
</div>
