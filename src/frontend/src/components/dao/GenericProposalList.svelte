<script lang="ts">
    import { Accordion, AccordionItem } from "flowbite-svelte";
    import { identityStore } from "../../stores/IdentityStore";
    import GenericProposal, { ProposalType } from "./GenericProposal.svelte";

    export let proposals: ProposalType[];
    export let onVote: (proposalId: bigint, vote: boolean) => Promise<void>;

    $: proposals = proposals.sort((a, b) => {
        return Number(b.timeStart - a.timeStart);
    });

    $: identity = $identityStore;

    let getVotingStatus = (proposal: ProposalType) => {
        if (identity) {
            let vote = proposal.votes.find(
                (v) => v[0].toString() === identity.getPrincipal().toString(),
            );
            if (vote) {
                let voteValue = vote[1].value[0];
                if (voteValue === undefined) {
                    return "Not voted";
                } else if (voteValue) {
                    return "Voted to Adopt";
                } else if (!voteValue) {
                    return "Voted to Reject";
                }
            }
        }
        return "Ineligible to vote";
    };

    let getProposalStatus = (proposal: ProposalType) => {
        let lastStatus = proposal.statusLog[proposal.statusLog.length - 1];
        if (!lastStatus) {
            return "Open";
        } else if ("executed" in lastStatus) {
            return "Executed";
        } else if ("executing" in lastStatus) {
            return "Executing";
        } else if ("rejected" in lastStatus) {
            return "Rejected";
        } else if ("failedToExecute" in lastStatus) {
            return "Failed to Execute";
        }
        return "Unknown";
    };
</script>

<div class="flex justify-center">
    <div class="text-3xl text-center flex-grow">Proposals</div>
</div>
{#if proposals.length === 0}
    <div class="flex justify-center">
        <div class="text-3xl text-center flex-grow">No proposals</div>
    </div>
{:else}
    <Accordion>
        {#each proposals as proposal}
            <AccordionItem>
                <span slot="header" class="w-full p-2">
                    <div class="flex justify-between">
                        <div>{proposal.title}</div>
                        <div>{getVotingStatus(proposal)}</div>
                        <div>{getProposalStatus(proposal)}</div>
                    </div>
                </span>
                <GenericProposal {proposal} {onVote}>
                    <slot proposalId={proposal.id} />
                </GenericProposal>
            </AccordionItem>
        {/each}
    </Accordion>
{/if}
