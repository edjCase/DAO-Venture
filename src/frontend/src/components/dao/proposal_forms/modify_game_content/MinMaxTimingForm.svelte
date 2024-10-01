<script lang="ts">
  import { SelectOptionType, Select, Label } from "flowbite-svelte";
  import {
    ActionTimingKind,
    TurnPhase,
  } from "../../../../ic-agent/declarations/main";
  import BigIntInput from "../../../common/BigIntInput.svelte";

  export let value: { min: bigint; max: bigint; timing: ActionTimingKind };

  const timingKinds: SelectOptionType<string>[] = [
    { value: "immediate", name: "Immediate" },
    { value: "periodic", name: "Periodic" },
  ];

  const phaseKinds: SelectOptionType<string>[] = [
    { value: "start", name: "Start" },
    { value: "end", name: "End" },
  ];

  let selectedTimingKind: string = Object.keys(value.timing)[0];
  let selectedPhaseKind: string;
  let periodicTurns: bigint;
  if ("periodic" in value.timing) {
    selectedPhaseKind = Object.keys(value.timing.periodic.phase)[0];
    periodicTurns = value.timing.periodic.turnDuration;
  } else {
    selectedPhaseKind = phaseKinds[0].value;
    periodicTurns = 1n;
  }

  let updateTiming = () => {
    if (selectedTimingKind === "immediate") {
      value.timing = { immediate: null };
    } else {
      value.timing = {
        periodic: { phase: { start: null }, turnDuration: periodicTurns },
      };
    }
  };

  let updatePeriodicTurns = () => {
    if ("periodic" in value.timing) {
      value.timing.periodic.turnDuration = periodicTurns;
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
    <BigIntInput bind:value={value.min} />
    <Label>Max</Label>
    <BigIntInput bind:value={value.max} />
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
      <Label>Turns</Label>
      <BigIntInput bind:value={periodicTurns} on:change={updatePeriodicTurns} />
    </div>
  {/if}
</div>
