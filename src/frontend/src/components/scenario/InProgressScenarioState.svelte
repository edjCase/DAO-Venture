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
    import ScenarioOption from "./ScenarioOption.svelte";

    export let scenarioId: bigint;
    export let options: ScenarioOptionWithEffect[];
    export let userContext: User | undefined;

    $: teams = $teamStore;

    let selectedChoice: number | undefined;
    let voteStatus: number | "notVoted" | "ineligible" = "notVoted";
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
                voteStatus = "notVoted";
            } else {
                voteStatus = Number(chosenOption);
                selectedChoice = Number(chosenOption);
            }
        } else {
            voteStatus = "ineligible";
            selectedChoice = undefined;
        }
    });
</script>

{#each options as option, index}
    <ScenarioOption
        {option}
        selected={selectedChoice === index}
        teamEnergy={team?.energy}
        teamTraits={team?.traits.map((t) => t.id)}
        {voteStatus}
        state={{
            inProgress: {
                onSelect: () => {
                    selectedChoice = index;
                },
            },
        }}
    />
{/each}

{#if voteStatus === "ineligible"}
    Ineligible to vote
    {#if !userContext || !isOwner}
        <div>Want to participate in scenarios?</div>
        <Button>Become a Team co-owner</Button>
    {/if}
{:else if voteStatus === "notVoted"}
    <div class="flex justify-center p-5">
        <LoadingButton onClick={register}>
            Submit Vote for Team {team?.name}
        </LoadingButton>
    </div>
{/if}
