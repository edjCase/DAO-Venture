<script lang="ts">
    import Proposal from "./Proposal.svelte";
    import { Proposal as ProposalType } from "../../ic-agent/declarations/teams";
    import { teamsAgentFactory } from "../../ic-agent/Teams";
    import { proposalStore } from "../../stores/ProposalStore";
    import { toJsonString } from "../../utils/StringUtil";

    export let proposal: ProposalType;
    export let teamId: bigint;

    let onVote = async (vote: boolean) => {
        let result = await teamsAgentFactory().voteOnProposal(teamId, {
            proposalId: proposal.id,
            vote,
        });
        console.log("Vote Result: ", result);
        if ("ok" in result) {
            proposalStore.refetchTeamProposal(teamId, proposal.id);
        }
    };
</script>

<Proposal {proposal} {onVote}>
    {#if "trainPlayer" in proposal.content}
        <div class="text-xl">Type: Train Player</div>
        <div>PlayerId: {proposal.content.trainPlayer.playerId}</div>
        <div>Skill: {toJsonString(proposal.content.trainPlayer.skill)}</div>
    {:else if "changeName" in proposal.content}
        <div class="text-xl">Type: Change Name</div>
        <div>New Name: {proposal.content.changeName.name}</div>
    {:else}
        Proposal Type Not Implemented {toJsonString(proposal.content)}
    {/if}
</Proposal>
