<script lang="ts">
    import { Button } from "flowbite-svelte";
    import { navigate } from "svelte-routing";
    import { Scenario } from "../../ic-agent/declarations/league";
    import { scenarioStore } from "../../stores/ScenarioStore";
    import { ScenarioVote } from "../../ic-agent/declarations/teams";

    let activeScenarios: Scenario[] = [];
    let votes: Record<string, ScenarioVote> = {};

    scenarioStore.subscribe((scenarios) => {
        activeScenarios = scenarios.filter(
            (scenario) => "inProgress" in scenario.state,
        );
        scenarioStore.refetchVotes(activeScenarios.map((s) => s.id));
    });

    scenarioStore.subscribeVotes((v) => {
        votes = v;
    });
    const getVotingStatus = (scenarioId: bigint) => {
        let vote = votes[Number(scenarioId)];
        if (vote === undefined) {
            return "Ineligible to vote";
        }
        if (vote.option.length === 0) {
            return "Not Voted";
        }
        return "Voted";
    };

    let activeScenariosWithVotingStatus: (Scenario & {
        votingStatus: string;
    })[] = [];

    // Reactive statement that updates activeScenariosWithVotingStatus whenever activeScenarios or votes changes
    $: activeScenariosWithVotingStatus = activeScenarios.map((scenario) => ({
        ...scenario,
        votingStatus: getVotingStatus(scenario.id),
    }));
</script>

<div>
    <div class="text-3xl text-center mb-5">Active Scenarios</div>
    {#if activeScenariosWithVotingStatus.length == 0}
        <div class="text-xl text-center">No active scenarios</div>
    {:else}
        <div class="flex flex-col items-center">
            <div class="mb-2">
                {#each activeScenariosWithVotingStatus as scenario}
                    <div class="text-xl text-center">
                        {scenario.title} - {scenario.votingStatus}
                    </div>
                {/each}
            </div>
            <Button on:click={() => navigate("/scenarios")}>
                View Scenarios
            </Button>
        </div>
    {/if}
</div>
