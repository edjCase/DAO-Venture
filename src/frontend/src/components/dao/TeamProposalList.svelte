<script lang="ts">
    import { proposalStore } from "../../stores/ProposalStore";
    import { onDestroy } from "svelte";
    import { Proposal } from "../../ic-agent/declarations/teams";
    import { teamsAgentFactory } from "../../ic-agent/Teams";
    import GenericProposalList from "./GenericProposalList.svelte";
    import { ProposalType } from "./GenericProposal.svelte";
    import TeamProposalDetails from "./TeamProposalDetails.svelte";
    import { toJsonString } from "../../utils/StringUtil";

    export let teamId: bigint;

    let proposals: Proposal[] = [];
    let genericProposals: ProposalType[] = [];

    $: genericProposals = proposals.map((p) => {
        let title, description;
        if ("changeName" in p.content) {
            title = "Change Team Name to " + p.content.changeName.name;
            description =
                "Change the team name to " + p.content.changeName.name;
        } else if ("train" in p.content) {
            title = "Train Position " + p.content.train.position;
            description =
                "Train Position " +
                p.content.train.position +
                " in " +
                toJsonString(p.content.train.skill);
        } else if ("swapPlayerPositions" in p.content) {
            title = "Swap Player Positions";
            description =
                "Swap the positions of " +
                p.content.swapPlayerPositions.position1 +
                " and " +
                p.content.swapPlayerPositions.position2;
        } else {
            title = "Not Implemented Proposal Type";
            description = "Not Implemented Proposal Type";
        }
        return {
            id: p.id,
            title: title,
            timeStart: p.timeStart,
            timeEnd: p.timeEnd,
            description: description,
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
        let teamsAgent = await teamsAgentFactory();
        let result = await teamsAgent.voteOnProposal(teamId, {
            proposalId: proposalId,
            vote,
        });
        console.log("Vote Result: ", result);
        if ("ok" in result) {
            proposalStore.refetchTeamProposal(teamId, proposalId);
        }
    };
</script>

<GenericProposalList proposals={genericProposals} {onVote} let:proposalId>
    <slot context="details">
        <TeamProposalDetails proposal={getProposal(proposalId)} />
    </slot>
</GenericProposalList>
