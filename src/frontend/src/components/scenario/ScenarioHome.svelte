<script lang="ts">
    import { Button } from "flowbite-svelte";
    import { navigate } from "svelte-routing";
    import { Scenario, ScenarioVote } from "../../ic-agent/declarations/league";
    import { scenarioStore } from "../../stores/ScenarioStore";
    import SectionWithOverview from "../common/SectionWithOverview.svelte";

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
            } else if (vote.value.length === 0) {
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

<div>
    <SectionWithOverview title="Scenarios">
        <ul slot="details" class="list-disc list-inside text-sm space-y-1">
            <li>
                Scenarios are league events where each team makes a choice on
                what to do
            </li>
            <li>
                Team decisions are made by majority vote of the team owners
                choice votes
            </li>
            <li>
                Each choice will have its trade-offs affecting entropy, energy,
                skills, etc...
            </li>
            <li>
                Some choice outcomes will depend on what other teams choose
                and/or randomness
            </li>
        </ul>
        <div class="border-2 rounded border-gray-700 p-4">
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
    </SectionWithOverview>
</div>
