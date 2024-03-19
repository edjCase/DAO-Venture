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

    export let scenarioId: string;
    export let options: ScenarioOption[];
    export let userContext: User | undefined;

    $: teams = $teamStore;

    let selectedChoice: number | undefined;
    let teamId: bigint | undefined;
    let isOwner: boolean = false;
    let team: TeamWithId | undefined;
    $: {
        teamId = userContext?.team[0]?.id;
        isOwner = teamId != undefined && "owner" in userContext!.team[0]!.kind;
        team = teams.find((team) => team.id === teamId);
    }

    let register = async function () {
        if (!isOwner || teamId === undefined) {
            console.log("User cant vote unless they are a team owner");
            return;
        }
        if (selectedChoice === undefined) {
            console.log("No choice selected");
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
        teamsAgent
            .voteOnScenario(teamId, request)
            .then((result) => {
                console.log("Voted for match: ", result);
                teamStore.refetch();
            })
            .catch((err) => {
                console.log("Failed to vote for match: ", err);
            });
    };
</script>

{#each options as { description }, index}
    <div
        class="border border-gray-300 p-4 rounded-lg flex-1 cursor-pointer text-left text-base text-white"
        class:bg-gray-500={selectedChoice === index}
        class:border-gray-500={selectedChoice === index}
        class:bg-gray-800={selectedChoice !== index}
        on:click={() => {
            selectedChoice = index;
        }}
        on:keypress={() => {}}
        role="button"
        tabindex={index}
    >
        <div class="">
            {@html description}
        </div>
    </div>
{/each}
{#if userContext && isOwner}
    <div class="flex justify-center p-5">
        <Button
            on:click={() => {
                register();
            }}
        >
            Submit Vote for Team {team?.name}
        </Button>
    </div>
{:else}
    <div>Want to participate in scenarios?</div>
    <Button>Become a Team co-owner</Button>
{/if}
