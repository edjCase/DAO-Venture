<script lang="ts">
    import { Card } from "flowbite-svelte";
    import { Scenario, VotingData } from "../../ic-agent/declarations/main";
    import { scenarioStore } from "../../stores/ScenarioStore";

    let activeScenarios: Scenario[] = [];
    let votes: Record<string, VotingData> = {};

    scenarioStore.subscribe((scenarios) => {
        if (scenarios === undefined) {
            return;
        }
        activeScenarios = scenarios.filter(
            (scenario) => "inProgress" in scenario.state,
        );
        scenarioStore.refetchVotes(activeScenarios.map((s) => s.id));
    });

    scenarioStore.subscribeVotingData((v) => {
        votes = v;
    });

    let activeScenariosWithVotingStatus: (Scenario & {
        votingStatus: string;
    })[] = [];

    $: activeScenariosWithVotingStatus = activeScenarios.map((scenario) => {
        let votingStatus: string;
        if (Object.keys(votes).length === 0) {
            votingStatus = "Loading...";
        } else {
            let vote = votes[Number(scenario.id)];
            if (vote === undefined) {
                votingStatus = "Ineligible to vote";
            } else if (vote.yourData[0]?.value.length === 0) {
                votingStatus = "Not Voted";
            } else {
                votingStatus = "Voted";
            }
        }
        return {
            ...scenario,
            votingStatus: votingStatus,
        };
    });
</script>

<div class="">
    <div class="text-3xl text-center">Active Scenarios</div>

    <div class="border-2 rounded border-gray-700 p-4 m-2">
        {#if activeScenariosWithVotingStatus.length == 0}
            <div class="text-xl text-center">None</div>
        {:else}
            <div class="flex items-center flex-wrap justify-around">
                {#each activeScenariosWithVotingStatus as scenario}
                    <Card class="max-w-48">
                        <div class="text-xl text-center">
                            {scenario.title}
                        </div>
                        <div>{scenario.votingStatus}</div>
                    </Card>
                {/each}
            </div>
        {/if}
    </div>
</div>
