<script lang="ts">
    import { AccordionItem } from "flowbite-svelte";
    import { userStore } from "../../stores/UserStore";
    import { WorldProposal } from "../../ic-agent/declarations/main";
    import { toJsonString } from "../../utils/StringUtil";
    import Proposal from "./Proposal.svelte";

    export let proposal: WorldProposal;
    export let onVote: (proposalId: bigint, vote: boolean) => Promise<void>;

    $: user = $userStore;
    $: votingStatus = (() => {
        if (user) {
            const vote = proposal.votes.find(
                (v) => v[0].toString() === user.id.toString(),
            );
            if (vote) {
                const voteValue = vote[1].choice[0];
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
        if ("open" in proposal.status) {
            return "Open";
        } else if ("executed" in proposal.status) {
            return proposal.status.executed.choice[0] !== true
                ? "Rejected"
                : "Executed";
        } else if ("executing" in proposal.status) {
            return "Executing";
        } else if ("failedToExecute" in proposal.status) {
            return "Failed to Execute";
        }
        return "Unknown";
    })();

    $: proposalStatusColor = (() => {
        if ("open" in proposal.status) {
            return "";
        } else if ("executed" in proposal.status) {
            return proposal.status.executed.choice[0] !== true
                ? "text-red-600"
                : "text-green-600";
        } else if ("executing" in proposal.status) {
            return "text-green-600";
        } else if ("rejected" in proposal.status) {
        } else if ("failedToExecute" in proposal.status) {
            return "text-red-600";
        }
        return "";
    })();

    $: title = (() => {
        if ("motion" in proposal.content) {
            return proposal.content.motion.title;
        }
        return (
            "NOT IMPLEMENTED PROPOSAL TITLE " + toJsonString(proposal.content)
        );
    })();
</script>

<AccordionItem>
    <span slot="header" class="w-full flex justify-between items-center px-5">
        <div>
            <div class="text-xl">
                #{proposal.id} - {title}
            </div>
            <div class="text-sm">{votingStatus}</div>
        </div>
        <div>
            <div class={proposalStatusColor}>
                {proposalStatus}
            </div>
        </div>
    </span>
    <Proposal {proposal} {onVote} />
</AccordionItem>
