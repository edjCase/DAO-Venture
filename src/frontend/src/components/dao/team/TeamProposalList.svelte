<script lang="ts">
    import { proposalStore } from "../../../stores/ProposalStore";
    import { onDestroy } from "svelte";
    import { Proposal } from "../../../ic-agent/declarations/main";
    import { mainAgentFactory } from "../../../ic-agent/Main";
    import GenericProposalList from "../GenericProposalList.svelte";
    import { ProposalType } from "../GenericProposal.svelte";
    import TeamProposalDetails from "./TeamProposalView.svelte";
    import { toJsonString } from "../../../utils/StringUtil";

    export let teamId: bigint;

    let proposals: Proposal[] = [];
    let genericProposals: ProposalType[] = [];

    $: genericProposals = proposals.map((p) => {
        let title;
        if ("changeName" in p.content) {
            title = "Change Team Name";
        } else if ("train" in p.content) {
            title = "Train Position ";
        } else if ("swapPlayerPositions" in p.content) {
            title = "Swap Player Positions";
        } else if ("changeColor" in p.content) {
            title = "Change Team Color";
        } else if ("changeLogo" in p.content) {
            title = "Change Team Logo";
        } else if ("changeMotto" in p.content) {
            title = "Change Team Motto";
        } else if ("changeDescription" in p.content) {
            title = "Change Team Description";
        } else if ("modifyLink" in p.content) {
            title = "Modify Team Link";
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

    let unsubscribeToTeamProposals = proposalStore.subscribeToTeam(
        teamId,
        (updatedProposals) => {
            proposals = updatedProposals;
        },
    );
    onDestroy(() => {
        unsubscribeToTeamProposals();
    });

    let getProposal = (proposalId: bigint): Proposal => {
        let proposal = proposals.find((p) => p.id == proposalId);
        if (proposal) {
            return proposal;
        }
        throw new Error("Proposal not found");
    };

    let onVote = async (proposalId: bigint, vote: boolean) => {
        let mainAgent = await mainAgentFactory();
        let result = await mainAgent.voteOnTeamProposal(teamId, {
            proposalId: proposalId,
            vote,
        });
        console.log("Vote Result: ", result);
        if ("ok" in result) {
            proposalStore.refetchTeamProposal(teamId, proposalId);
        }
    };
    let onRefresh = async () => {
        await proposalStore.refetchTeamProposals(teamId);
    };
</script>

<GenericProposalList
    proposals={genericProposals}
    {onVote}
    {onRefresh}
    let:proposalId
>
    <slot name="details">
        <TeamProposalDetails proposal={getProposal(proposalId)} />
    </slot>
</GenericProposalList>
