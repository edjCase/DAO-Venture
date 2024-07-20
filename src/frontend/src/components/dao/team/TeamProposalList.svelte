<script lang="ts">
    import { proposalStore } from "../../../stores/ProposalStore";
    import { onDestroy } from "svelte";
    import {
        Proposal,
        TownProposal,
    } from "../../../ic-agent/declarations/main";
    import { mainAgentFactory } from "../../../ic-agent/Main";
    import GenericProposalList from "../GenericProposalList.svelte";
    import { ProposalType } from "../GenericProposal.svelte";
    import TownProposalView from "./TownProposalView.svelte";
    import { toJsonString } from "../../../utils/StringUtil";

    export let townId: bigint;

    let proposals: Proposal[] = [];
    let genericProposals: ProposalType[] = [];

    $: genericProposals = proposals.map((p) => {
        let title;
        if ("changeName" in p.content) {
            title = "Change Town Name";
        } else if ("train" in p.content) {
            title = "Train Position ";
        } else if ("swapPlayerPositions" in p.content) {
            title = "Swap Player Positions";
        } else if ("changeColor" in p.content) {
            title = "Change Town Color";
        } else if ("changeLogo" in p.content) {
            title = "Change Town Logo";
        } else if ("changeMotto" in p.content) {
            title = "Change Town Motto";
        } else if ("changeDescription" in p.content) {
            title = "Change Town Description";
        } else if ("modifyLink" in p.content) {
            title = "Modify Town Link";
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

    let unsubscribeToTownProposals = proposalStore.subscribeToTown(
        townId,
        (updatedProposals) => {
            proposals = updatedProposals;
        },
    );
    onDestroy(() => {
        unsubscribeToTownProposals();
    });

    let getProposal = (proposalId: bigint): TownProposal => {
        let proposal = proposals.find((p) => p.id == proposalId);
        if (proposal) {
            return proposal;
        }
        throw new Error("Proposal not found");
    };

    let onVote = async (proposalId: bigint, vote: boolean) => {
        let mainAgent = await mainAgentFactory();
        let result = await mainAgent.voteOnTownProposal(townId, {
            proposalId: proposalId,
            vote,
        });
        console.log("Vote Result: ", result);
        if ("ok" in result) {
            proposalStore.refetchTownProposal(townId, proposalId);
        }
    };
    let onRefresh = async () => {
        await proposalStore.refetchTownProposals(townId);
    };
</script>

<GenericProposalList
    proposals={genericProposals}
    {onVote}
    {onRefresh}
    let:proposalId
>
    <slot name="details">
        <TownProposalView proposal={getProposal(proposalId)} {townId} />
    </slot>
</GenericProposalList>
