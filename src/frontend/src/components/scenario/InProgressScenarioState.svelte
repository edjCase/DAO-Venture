<script lang="ts">
    import { Button, Input } from "flowbite-svelte";
    import {
        Scenario,
        ScenarioVote,
        VoteOnScenarioRequest,
    } from "../../ic-agent/declarations/league";
    import { Team } from "../../ic-agent/declarations/teams";
    import { teamStore } from "../../stores/TeamStore";
    import { User } from "../../ic-agent/declarations/users";
    import { scenarioStore } from "../../stores/ScenarioStore";
    import { leagueAgentFactory } from "../../ic-agent/League";
    import ScenarioOption from "./ScenarioOption.svelte";
    import LoadingButton from "../common/LoadingButton.svelte";

    export let scenario: Scenario;
    export let userContext: User | undefined;

    $: teams = $teamStore;

    let selectedChoice: number | undefined;
    let yourVote: ScenarioVote | "ineligible" = "ineligible";
    let teamId: bigint | undefined;
    let isOwner: boolean = false;
    let team: Team | undefined;
    let bid: number | undefined;
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
            scenarioId: scenario.id,
            option: BigInt(selectedChoice),
        };
        console.log(
            `Voting for team ${teamId} and scenario ${scenario.id} with option ${selectedChoice}`,
            request,
        );
        let leagueAgent = await leagueAgentFactory();
        let result = await leagueAgent.voteOnScenario(request);
        if ("ok" in result) {
            console.log("Voted for scenario", request.scenarioId);
            teamStore.refetch();
            scenarioStore.refetchVotes([scenario.id]);
        } else {
            console.error("Failed to vote for match: ", result);
        }
    };

    let addBid = async function () {
        if (bid === undefined) {
            console.error("No bid amount specified");
            return;
        }
        let leagueAgent = await leagueAgentFactory();
        let result = await leagueAgent.addScenarioBidOption({
            scenarioId: scenario.id,
            value: BigInt(bid),
        });
        if ("ok" in result) {
            console.log("Added bid for scenario", scenario.id);
            scenarioStore.refetchById(scenario.id);
        } else {
            console.error("Failed to add bid for scenario: ", result);
        }
    };

    scenarioStore.subscribeVotes((votes) => {
        if (votes[Number(scenario.id)] !== undefined) {
            yourVote = votes[Number(scenario.id)];
        } else {
            yourVote = "ineligible";
            selectedChoice = undefined;
        }
    });
</script>

{#if scenario.options.length < 1}
    No options available
{:else}
    {#each scenario.options as option, index}
        <ScenarioOption
            optionId={index}
            {option}
            selected={selectedChoice === index}
            teamEnergy={team?.energy}
            teamTraits={team?.traits.map((t) => t.id)}
            {yourVote}
            state={{
                inProgress: {
                    onSelect: () => {
                        selectedChoice = index;
                        register();
                    },
                },
            }}
        />
    {/each}
{/if}

{#if yourVote === "ineligible"}
    Ineligible to vote
    {#if !userContext || !isOwner}
        <div>Want to participate in scenarios?</div>
        <Button>Become a Team co-owner</Button>
    {/if}
{:else if "lottery" in scenario.metaEffect}
    <div>
        Add Ticket Count
        <Input type="number" bind:value={bid} />
        <LoadingButton onClick={addBid}>Submit</LoadingButton>
    </div>
{:else if "proportionalBid" in scenario.metaEffect}
    <div>
        Add Bid
        <Input type="number" bind:value={bid} />
        <LoadingButton onClick={addBid}>Submit</LoadingButton>
    </div>
{/if}
