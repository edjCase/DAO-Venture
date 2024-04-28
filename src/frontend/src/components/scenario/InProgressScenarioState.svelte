<script lang="ts">
    import { Button } from "flowbite-svelte";
    import {
        ScenarioOptionWithEffect,
        VoteOnScenarioRequest,
    } from "../../ic-agent/declarations/league";
    import { Team } from "../../ic-agent/declarations/teams";
    import { teamStore } from "../../stores/TeamStore";
    import { User } from "../../ic-agent/declarations/users";
    import LoadingButton from "../common/LoadingButton.svelte";
    import { scenarioStore } from "../../stores/ScenarioStore";
    import { leagueAgentFactory } from "../../ic-agent/League";

    export let scenarioId: bigint;
    export let options: ScenarioOptionWithEffect[];
    export let userContext: User | undefined;

    $: teams = $teamStore;

    let selectedChoice: number | undefined;
    let votedOrIneligible: boolean | undefined = undefined;
    let teamId: bigint | undefined;
    let isOwner: boolean = false;
    let team: Team | undefined;
    $: {
        teamId = userContext?.team[0]?.id;
        isOwner = teamId != undefined && "owner" in userContext!.team[0]!.kind;
        team = teams?.find((team) => team.id === teamId);
    }

    let register = async function () {
        if (!isOwner || teamId === undefined) {
            console.error("User cant vote unless they are a team owner");
            return;
        }
        if (selectedChoice === undefined) {
            console.error("No choice selected");
            return;
        }
        let request: VoteOnScenarioRequest = {
            scenarioId: scenarioId,
            option: BigInt(selectedChoice),
        };
        console.log(
            `Voting for team ${teamId} and scenario ${scenarioId} with option ${selectedChoice}`,
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
    scenarioStore.subscribeVotes((votes) => {
        if (votes[Number(scenarioId)] !== undefined) {
            let chosenOption = votes[Number(scenarioId)].option[0];
            if (chosenOption === undefined) {
                votedOrIneligible = false;
                selectedChoice = undefined;
            } else {
                votedOrIneligible = true;
                selectedChoice = Number(chosenOption);
            }
        } else {
            votedOrIneligible = undefined;
            selectedChoice = undefined;
        }
    });
</script>

{#each options as { description }, index}
    <div
        class="border border-gray-300 p-4 rounded-lg flex-1 text-left text-base text-white"
        class:bg-gray-900={selectedChoice === index}
        class:border-gray-500={selectedChoice !== index}
        class:bg-gray-700={selectedChoice !== index}
    >
        {#if votedOrIneligible === false}
            <div
                class="w-full h-full flex items-center justify-center cursor-pointer"
                on:click={() => {
                    if (votedOrIneligible === false) {
                        selectedChoice = index;
                    }
                }}
                on:keypress={() => {}}
                role="button"
                tabindex={index}
            >
                {@html description}
            </div>
        {:else}
            <div>
                {@html description}
            </div>
        {/if}
    </div>
{/each}

{#if votedOrIneligible === undefined}
    Ineligible to vote
    {#if !userContext || !isOwner}
        <div>Want to participate in scenarios?</div>
        <Button>Become a Team co-owner</Button>
    {/if}
{:else if votedOrIneligible === false}
    <div class="flex justify-center p-5">
        <LoadingButton onClick={register}>
            Submit Vote for Team {team?.name}
        </LoadingButton>
    </div>
{/if}
