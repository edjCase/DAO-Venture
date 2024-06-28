<script lang="ts">
    import {
        ScenarioTeamOptionNat,
        VoteOnScenarioRequest,
    } from "../../ic-agent/declarations/league";
    import { leagueAgentFactory } from "../../ic-agent/League";
    import { teamStore } from "../../stores/TeamStore";
    import { scenarioStore } from "../../stores/ScenarioStore";
    import ScenarioOptionNat from "./ScenarioOptionNat.svelte";
    import BigIntInput from "./editors/BigIntInput.svelte";
    import LoadingButton from "../common/LoadingButton.svelte";

    export let scenarioId: bigint;
    export let teamId: bigint;
    export let teamEnergy: bigint | undefined;
    export let options: ScenarioTeamOptionNat[];

    let natValue: bigint | undefined;

    let vote = async function () {
        if (natValue === undefined) {
            console.error("No value selected");
            return;
        }
        let request: VoteOnScenarioRequest = {
            scenarioId: scenarioId,
            value: { nat: natValue },
        };
        console.log(
            `Voting for team ${teamId} and scenario ${scenarioId} with nat value ${natValue}`,
            request,
        );
        let leagueAgent = await leagueAgentFactory();
        let result = await leagueAgent.voteOnScenario(request);
        if ("ok" in result) {
            console.log("Voted for scenario", request.scenarioId);
            teamStore.refetch();
            scenarioStore.refetchVotes([scenarioId]);
        } else {
            console.error("Failed to vote for match: ", result);
        }
    };
</script>

{#if options.length < 1}
    No current bid proposals
{:else}
    {#each options as option}
        <ScenarioOptionNat
            {option}
            selected={natValue === option.value}
            {teamEnergy}
            onSelect={() => {
                natValue = option.value;
                vote();
            }}
        />
    {/each}
{/if}

<div>
    Propose Value
    <BigIntInput bind:value={natValue} />
    <LoadingButton onClick={vote}>Submit</LoadingButton>
</div>
