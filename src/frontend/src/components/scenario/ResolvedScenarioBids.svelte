<script lang="ts">
    import { ScenarioVote } from "../../ic-agent/declarations/league";
    import GenericOption from "./GenericOption.svelte";
    import { teamStore } from "../../stores/TeamStore";

    export let scenarioId: bigint;
    export let bids: bigint[];
    export let vote: ScenarioVote | "ineligible";

    let selectedIndex =
        vote == "ineligible" || vote.option.length < 1
            ? undefined
            : Number(vote.option[0]);

    $: teams = $teamStore;

    $: team =
        vote == "ineligible"
            ? undefined
            : teams?.find((team) => team.id === vote.teamId);
</script>

{#each bids as bidValue, i}
    <GenericOption
        optionId={i}
        {scenarioId}
        traitRequirements={[]}
        energyCost={bidValue}
        {vote}
        teamEnergy={team?.energy}
        teamTraits={team?.traits.map((t) => t.id)}
        selected={selectedIndex === i}
        state={{
            inProgress: {
                onSelect: () => {
                    selectedIndex = i;
                },
            },
        }}
    >
        <div class="text-center text-xl font-bold">Bid {bidValue} 💰</div>
    </GenericOption>
{/each}
