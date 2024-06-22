<script lang="ts">
    import { Input } from "flowbite-svelte";
    import LoadingButton from "../common/LoadingButton.svelte";
    import { scenarioStore } from "../../stores/ScenarioStore";
    import { leagueAgentFactory } from "../../ic-agent/League";
    import { ScenarioVote } from "../../ic-agent/declarations/league";
    import GenericOption from "./GenericOption.svelte";
    import { teamStore } from "../../stores/TeamStore";

    export let scenarioId: bigint;
    export let bids: bigint[];
    export let minBid: bigint;
    export let vote: ScenarioVote;

    let selectedIndex =
        vote.option.length < 1 ? undefined : Number(vote.option[0]);

    $: teams = $teamStore;

    $: team = teams?.find((team) => team.id === vote.teamId);

    let bid = 0;

    let addBid = async function () {
        if (bid === undefined) {
            console.error("No bid amount specified");
            return;
        }
        if (bid < minBid) {
            // TODO better error handling
            console.error("Bid amount is less than the minimum bid amount");
            return;
        }
        let leagueAgent = await leagueAgentFactory();
        let result = await leagueAgent.addScenarioCustomTeamOption({
            scenarioId: scenarioId,
            value: { nat: BigInt(bid) },
        });
        if ("ok" in result) {
            console.log("Added bid for scenario", scenarioId);
            scenarioStore.refetchById(scenarioId);
        } else {
            console.error("Failed to add bid for scenario: ", result);
        }
    };
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

<div>
    Add Bid
    <Input type="number" bind:value={bid} />
    <LoadingButton onClick={addBid}>Submit</LoadingButton>
</div>
