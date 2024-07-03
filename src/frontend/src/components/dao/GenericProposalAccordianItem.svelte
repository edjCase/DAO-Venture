<script lang="ts">
    import { AccordionItem } from "flowbite-svelte";
    import GenericProposal, { ProposalType } from "./GenericProposal.svelte";
    import { identityStore } from "../../stores/IdentityStore";

    export let proposal: ProposalType;
    export let onVote: (proposalId: bigint, vote: boolean) => Promise<void>;

    $: identity = $identityStore;
    $: votingStatus = (() => {
        if (identity) {
            const vote = proposal.votes.find(
                (v) => v[0].toString() === identity.getPrincipal().toString(),
            );
            if (vote) {
                const voteValue = vote[1].value[0];
                if (voteValue === undefined) {
                    return "Not voted";
                } else if (voteValue) {
                    return "Voted to Adopt";
                } else {
                    return "Voted to Reject";
                }
            }
        }
        return "Ineligible to vote";
    })();

    $: proposalStatus = (() => {
        const lastStatus = proposal.statusLog[proposal.statusLog.length - 1];
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
    })();

    $: proposalStatusColor = (() => {
        const lastStatus = proposal.statusLog[proposal.statusLog.length - 1];
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
    })();
</script>

<AccordionItem>
    <span slot="header" class="w-full flex justify-between items-center px-5">
        <div>
            <div class="text-xl">
                #{proposal.id} - {proposal.title}
            </div>
            <div class="text-sm">{votingStatus}</div>
        </div>
        <div>
            <div class={proposalStatusColor}>
                {proposalStatus}
            </div>
        </div>
    </span>
    <GenericProposal {proposal} {onVote}>
        <slot proposalId={proposal.id} />
    </GenericProposal>
</AccordionItem>
