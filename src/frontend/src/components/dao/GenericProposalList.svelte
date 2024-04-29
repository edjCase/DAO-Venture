<script lang="ts">
    import { Accordion, AccordionItem } from "flowbite-svelte";
    import { identityStore } from "../../stores/IdentityStore";
    import GenericProposal, { ProposalType } from "./GenericProposal.svelte";
    import RefreshIcon from "../common/RefreshIcon.svelte";
    import LoadingButton from "../common/LoadingButton.svelte";

    export let proposals: ProposalType[];
    export let onVote: (proposalId: bigint, vote: boolean) => Promise<void>;
    export let onRefresh: () => Promise<void>;

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

    let getProposalStatusColor = (proposal: ProposalType) => {
        let lastStatus = proposal.statusLog[proposal.statusLog.length - 1];
        if (!lastStatus) {
            return "";
        } else if ("executed" in lastStatus) {
            return "text-green-600";
        } else if ("executing" in lastStatus) {
            return "text-green-600";
        } else if ("rejected" in lastStatus) {
            return "text-red-600";
        } else if ("failedToExecute" in lastStatus) {
            return "text-red-600";
        }
        return "";
    };
</script>

<div class="flex justify-between items-center mb-5">
    <div class="text-3xl text-center w-full">Latest Proposals</div>
    <div>
        <LoadingButton onClick={onRefresh}>
            <RefreshIcon />
        </LoadingButton>
    </div>
</div>
{#if proposals.length === 0}
    <div class="flex justify-center">
        <div class="text-3xl text-center flex-grow">-</div>
    </div>
{:else}
    <Accordion>
        {#each proposals as proposal}
            <AccordionItem>
                <span
                    slot="header"
                    class="w-full flex justify-between items-center px-5"
                >
                    <div>
                        <div class="text-xl">
                            #{proposal.id} - {proposal.title}
                        </div>
                        <div class="text-sm">{getVotingStatus(proposal)}</div>
                    </div>
                    <div>
                        <div class={getProposalStatusColor(proposal)}>
                            {getProposalStatus(proposal)}
                        </div>
                    </div>
                </span>
                <GenericProposal {proposal} {onVote}>
                    <slot proposalId={proposal.id} />
                </GenericProposal>
            </AccordionItem>
        {/each}
    </Accordion>
{/if}
