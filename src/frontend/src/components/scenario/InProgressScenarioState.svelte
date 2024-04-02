<script lang="ts">
    import { Button } from "flowbite-svelte";
    import { teamsAgentFactory } from "../../ic-agent/Teams";
    import {
        ScenarioOption,
        TeamWithId,
    } from "../../ic-agent/declarations/league";
    import { VoteOnScenarioRequest } from "../../ic-agent/declarations/teams";
    import { teamStore } from "../../stores/TeamStore";
    import { User } from "../../ic-agent/declarations/users";
    import LoadingButton from "../common/LoadingButton.svelte";

    export let scenarioId: string;
    export let options: ScenarioOption[];
    export let userContext: User | undefined;

    $: teams = $teamStore;

    let selectedChoice: number | undefined;
    let voted: boolean = false;
    let teamId: bigint | undefined;
    let isOwner: boolean = false;
    let team: TeamWithId | undefined;
    $: {
        let teamIdIsDefined = teamId !== undefined;
        teamId = userContext?.team[0]?.id;
        if (!teamIdIsDefined && teamId !== undefined) {
            // If teamId was not defined, but now it is, refresh the vote
            refreshVote();
        }
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
        let teamsAgent = await teamsAgentFactory();
        let result = await teamsAgent.voteOnScenario(teamId, request);
        if ("ok" in result) {
            console.log("Voted for scenario", request.scenarioId);
            teamStore.refetch();
            refreshVote();
        } else {
            console.error("Failed to vote for match: ", result);
        }
    };

    let refreshVote = async () => {
        if (teamId !== undefined) {
            let teamsAgent = await teamsAgentFactory();
            let result = await teamsAgent.getScenarioVote({ scenarioId });
            if ("ok" in result) {
                if (result.ok[0] === undefined) {
                    selectedChoice = undefined;
                    voted = false;
                } else {
                    selectedChoice = Number(result.ok[0].option);
                    voted = true;
                }
            } else {
                console.error("Failed to get scenario vote: ", result);
            }
        }
    };
</script>

{#each options as { description }, index}
    {#if !voted}
        <div
            class="border border-gray-300 p-4 rounded-lg flex-1 cursor-pointer text-left text-base text-white"
            class:bg-gray-500={selectedChoice === index}
            class:border-gray-500={selectedChoice === index}
            class:bg-gray-800={selectedChoice !== index}
            on:click={() => {
                if (!voted) {
                    selectedChoice = index;
                }
            }}
            on:keypress={() => {}}
            role="button"
            tabindex={index}
        >
            <div class="">
                {@html description}
            </div>
        </div>
    {:else}
        <div
            class="border border-gray-300 p-4 rounded-lg flex-1 text-left text-base text-white"
            class:bg-gray-500={selectedChoice === index}
            class:border-gray-500={selectedChoice === index}
            class:bg-gray-800={selectedChoice !== index}
        >
            <div class="">
                {@html description}
            </div>
        </div>
    {/if}
{/each}
{#if userContext && isOwner}
    {#if !voted}
        <div class="flex justify-center p-5">
            <LoadingButton onClick={register}>
                Submit Vote for Team {team?.name}
            </LoadingButton>
        </div>
    {/if}
{:else}
    <div>Want to participate in scenarios?</div>
    <Button>Become a Team co-owner</Button>
{/if}
