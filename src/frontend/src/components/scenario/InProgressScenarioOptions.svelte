<script lang="ts">
    import {
        ScenarioOptionWithEffect,
        ScenarioVote,
    } from "../../ic-agent/declarations/league";
    import { Team } from "../../ic-agent/declarations/teams";
    import { teamStore } from "../../stores/TeamStore";
    import ScenarioOption from "./ScenarioOption.svelte";

    export let options: ScenarioOptionWithEffect[];
    export let scenarioId: bigint;
    export let vote: ScenarioVote;

    $: teams = $teamStore;

    let selectedChoice: number | undefined;
    let team: Team | undefined;

    $: team = teams?.find((team) => team.id === vote.teamId);
</script>

{#if options.length < 1}
    No options available
{:else}
    {#each options as option, index}
        <ScenarioOption
            optionId={index}
            {scenarioId}
            {option}
            selected={selectedChoice === index}
            teamEnergy={team?.energy}
            teamTraits={team?.traits.map((t) => t.id)}
            {vote}
            state={{
                inProgress: {
                    onSelect: () => {
                        selectedChoice = index;
                    },
                },
            }}
        />
    {/each}
{/if}
