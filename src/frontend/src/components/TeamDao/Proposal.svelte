<script lang="ts">
    import { Principal } from "@dfinity/principal";
    import { Button } from "flowbite-svelte";
    import { teamAgentFactory } from "../../ic-agent/Team";
    import { Proposal } from "../../ic-agent/declarations/team";
    import { toJsonString } from "../../utils/JsonUtil";
    import { userStore } from "../../stores/UserStore";
    import { nanosecondsToDate } from "../../utils/DateUtils";
    import { proposalStore } from "../../stores/ProposalStore";

    export let teamId: string | Principal;
    export let proposal: Proposal;

    $: user = $userStore;

    let yourVote: boolean | undefined;
    $: {
        if (user) {
            let yourUserId = user.id;
            let v = proposal.votes.find(
                ([memberId, _]) => memberId.compareTo(yourUserId) == "eq",
            )?.[1];
            yourVote = v && v.value.length > 0 ? v.value[0] : undefined;
        }
    }

    let vote = async (vote: boolean) => {
        console.log(
            "Voting on proposal",
            proposal.id,
            "for team",
            teamId,
            "vote",
            vote,
        );
        let result = await teamAgentFactory(teamId).voteOnProposal({
            proposalId: proposal.id,
            vote,
        });
        console.log("Vote Result: ", result);
        if ("ok" in result) {
            proposalStore.refetchTeamProposal(teamId, proposal.id);
        }
    };
</script>

<div class="border p-5">
    <div class="text-3xl">Proposal: {proposal.id}</div>
    <div>Created: {nanosecondsToDate(proposal.timeStart).toLocaleString()}</div>
    <div>Ends: {nanosecondsToDate(proposal.timeEnd).toLocaleString()}</div>
    {#if "trainPlayer"}
        <div class="text-xl">Type: Train Player</div>
        <div>PlayerId: {proposal.content.trainPlayer.playerId}</div>
        <div>Skill: {toJsonString(proposal.content.trainPlayer.skill)}</div>
    {:else}
        ProposalType Not Impletmented
    {/if}
    {#if "open" in proposal.status}
        <div class="text-2xl">Vote:</div>
        {#if yourVote === undefined}
            <div class="mb-6">
                <Button on:click={() => vote(true)}>Yes</Button>
                <Button on:click={() => vote(false)}>No</Button>
            </div>
        {:else}
            <div class="text-xl">
                You have voted: {yourVote ? "Yes" : "No"}
            </div>
        {/if}
    {:else if "executed" in proposal.status}
        <div class="text-xl">Proposal Executed</div>
    {:else if "rejected" in proposal.status}
        <div class="text-xl">Proposal Rejected</div>
    {/if}
</div>
