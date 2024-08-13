<script lang="ts">
    import { Card } from "flowbite-svelte";
    import { Scenario } from "../../ic-agent/declarations/main";
    import { scenarioStore } from "../../stores/ScenarioStore";
    import { Link } from "svelte-routing";

    let scenarios: Scenario[] | undefined;

    scenarioStore.subscribe((s) => {
        if (scenarios === undefined) {
            return;
        }
        scenarios = s;
    });

    $: activeScenariosWithVotingStatus = scenarios?.map((scenario) => {
        let votingStatus: string;
        if ('mysteriousStructure' in scenario.kind ){
            scenario.kind.mysteriousStructure.proposal.votes[0][1].choice[0]!.
        } else 
        {
            throw new Error("Unimplemented scenario kind:", scenario.kind);
        }
        let vote = scenario.[Number(scenario.id)];
        if (vote === undefined) {
            votingStatus = "Ineligible to vote";
        } else if (vote.yourData[0]?.value.length === 0) {
            votingStatus = "Not Voted";
        } else {
            votingStatus = "Voted";
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
