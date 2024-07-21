<script lang="ts">
    import GenericProposalList from "../GenericProposalList.svelte";
    import { proposalStore } from "../../../stores/ProposalStore";
    import { onDestroy } from "svelte";
    import { mainAgentFactory } from "../../../ic-agent/Main";
    import { ProposalType } from "../GenericProposal.svelte";
    import { WorldProposal } from "../../../ic-agent/declarations/main";
    import { toJsonString } from "../../../utils/StringUtil";
    import WorldProposalView from "./WorldProposalView.svelte";

    let proposals: WorldProposal[] = [];
    let genericProposals: ProposalType[] = [];

    $: genericProposals = proposals.map((p) => {
        let title;
        if ("changeTownName" in p.content) {
            title = "Change Town Name ";
        } else if ("changeTownColor" in p.content) {
            title = "Change Town Color";
        } else if ("changeTownDescription" in p.content) {
            title = "Change Town Description";
        } else if ("changeTeamFlag" in p.content) {
            title = "Change Town Logo";
        } else if ("changeTownMotto" in p.content) {
            title = "Change Town Motto";
        } else if ("motion" in p.content) {
            title = p.content.motion.title;
        } else {
            title = "Not Implemented Proposal Type: " + toJsonString(p.content);
        }
        return {
            id: p.id,
            title: title,
            timeStart: p.timeStart,
            timeEnd: p.timeEnd,
            votes: p.votes,
            statusLog: p.statusLog,
        };
    });

    let unsubscribeToTownProposals = proposalStore.subscribeToWorld(
        (updatedProposals) => {
            proposals = updatedProposals;
        },
    );
    onDestroy(() => {
        unsubscribeToTownProposals();
    });

    let onVote = async (proposalId: bigint, vote: boolean) => {
        let mainAgent = await mainAgentFactory();
        let result = await mainAgent.voteOnWorldProposal({
            proposalId: proposalId,
            vote,
        });
        console.log("Vote Result: ", result);
        if ("ok" in result) {
            proposalStore.refetchWorldProposal(proposalId);
        }
    };
    let getProposal = (proposalId: bigint): WorldProposal => {
        let proposal = proposals.find((p) => p.id == proposalId);
        if (proposal) {
            return proposal;
        }
        throw new Error("Proposal not found: " + proposalId);
    };

    let onRefresh = async () => {
        await proposalStore.refetchWorldProposals();
    };
</script>

<GenericProposalList
    proposals={genericProposals}
    {onVote}
    {onRefresh}
    let:proposalId
>
    <slot name="details">
        <WorldProposalView proposal={getProposal(proposalId)} />
    </slot>
</GenericProposalList>
