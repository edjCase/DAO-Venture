<script lang="ts">
    import { Button } from "flowbite-svelte";
    import { teamsAgentFactory } from "../../ic-agent/Teams";
    import { ScenarioOption } from "../../ic-agent/declarations/league";
    import { VoteOnScenarioRequest } from "../../ic-agent/declarations/teams";
    import { teamStore } from "../../stores/TeamStore";
    import { User } from "../../ic-agent/declarations/users";
    import { toJsonString } from "../../utils/JsonUtil";

    export let scenarioId: string;
    export let options: ScenarioOption[];
    export let userContext: User | undefined;
    let selectedChoice: number | undefined;
    let teamId: bigint | undefined;
    let isOwner: boolean = false;
    $: {
        teamId = userContext?.team[0]?.id;
        isOwner = teamId != undefined && "owner" in userContext!.team[0]!.kind;
    }

    let register = function () {
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
        teamsAgentFactory()
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
        class="border border-gray-300 p-4 rounded-lg flex-1 cursor-pointer text-left w-96 text-base text-white"
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
            Submit Vote for Team {teamId}
        </Button>
    </div>
{/if}
