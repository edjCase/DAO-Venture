<script lang="ts">
    import {
        ScenarioOptionWithEffect,
        ScenarioStateResolved,
        ScenarioVote,
    } from "../../ic-agent/declarations/league";
    import { teamStore } from "../../stores/TeamStore";
    import ScenarioOption from "./ScenarioOption.svelte";

    export let options: ScenarioOptionWithEffect[];
    export let scenarioId: bigint;
    export let vote: ScenarioVote | "ineligible";
    export let state: ScenarioStateResolved;

    $: teams = $teamStore;

    let selectedChoice: number | undefined;

    let optionTeamVotes: bigint[][] | undefined;
    $: if (teams) {
        optionTeamVotes = options.map((_, i) => {
            return state.teamChoices
                .filter((v) => v.option[0] === BigInt(i))
                .map((v) => v.teamId);
        });
    }
</script>

{#if options.length < 1}
    No options available
{:else}
    {#each options as option, index}
        <ScenarioOption
            {scenarioId}
            optionId={index}
            {option}
            selected={selectedChoice === index}
            teamEnergy={undefined}
            teamTraits={undefined}
            {vote}
            state={{
                resolved: {
                    teams: optionTeamVotes ? optionTeamVotes[index] : undefined,
                },
            }}
        />
    {/each}
{/if}
