<script lang="ts">
    import {
        ScenarioOptionWithEffect,
        ScenarioVote,
    } from "../../ic-agent/declarations/league";
    import GenericOption from "./GenericOption.svelte";

    type State =
        | {
              inProgress: {
                  onSelect: () => void;
              };
          }
        | {
              resolved: {
                  teams: bigint[] | undefined;
              };
          };

    export let optionId: number;
    export let scenarioId: bigint;
    export let option: ScenarioOptionWithEffect;
    export let teamEnergy: bigint | undefined; // Undefined used for loading but also for resolved scenarios
    export let teamTraits: string[] | undefined; // Undefined used for loading but also for resolved scenarios
    export let selected: boolean;
    export let vote: ScenarioVote | "ineligible";
    export let state: State;
</script>

<GenericOption
    {optionId}
    {scenarioId}
    traitRequirements={option.traitRequirements}
    energyCost={option.energyCost}
    {vote}
    {teamEnergy}
    {teamTraits}
    {selected}
    {state}
>
    <div class="text-center text-xl font-bold">{option.title}</div>
    <div class="text-justify text-sm">{option.description}</div>
    {#if option.energyCost > 0}
        <div class="text-xl text-center">{option.energyCost} 💰</div>
    {/if}
</GenericOption>
