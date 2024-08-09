<script lang="ts">
    import { Card } from "flowbite-svelte";
    import { Scenario } from "../../ic-agent/declarations/main";
    import { scenarioStore } from "../../stores/ScenarioStore";
    import { Link } from "svelte-routing";

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

    <div class="p-4 my-2">
        {#if activeScenariosWithVotingStatus.length == 0}
            <div class="text-xl text-center">None</div>
        {:else}
            <div class="flex flex-col items-center justify-between gap-2">
                {#each activeScenariosWithVotingStatus as scenario}
                    <!-- TODO link to specific one -->
                    <Link to={`/scenarios`}>
                        <Card class="w-48text-xl text-center">
                            <div>
                                {scenario.title}
                            </div>
                            <div>{scenario.votingStatus}</div>
                        </Card>
                    </Link>
                {/each}
            </div>
        {/if}
    </div>
</div>
