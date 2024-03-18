<script lang="ts">
    import Proposal from "./Proposal.svelte";
    import { Proposal as ProposalType } from "../../ic-agent/declarations/league";
    import { proposalStore } from "../../stores/ProposalStore";
    import { toJsonString } from "../../utils/StringUtil";
    import { leagueAgentFactory } from "../../ic-agent/League";

    export let proposal: ProposalType;

    let onVote = async (vote: boolean) => {
        let result = await leagueAgentFactory().voteOnProposal({
            proposalId: proposal.id,
            vote,
        });
        console.log("Vote Result: ", result);
        if ("ok" in result) {
            proposalStore.refetchLeagueProposal(proposal.id);
        }
    };
</script>

<Proposal {proposal} {onVote}>
    <slot context="details">
        {#if "changeTeamName" in proposal.content}
            <div class="text-xl">Type: Change Team Name</div>
            <div>Team: {proposal.content.changeTeamName.teamId}</div>
            <div>New Name: {proposal.content.changeTeamName.name}</div>
        {:else}
            Proposal Type Not Implemented {toJsonString(proposal.content)}
        {/if}
    </slot>
</Proposal>
