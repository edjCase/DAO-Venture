<script lang="ts">
    import GenericProposalList from "./GenericProposalList.svelte";
    import { proposalStore } from "../../stores/ProposalStore";
    import { onDestroy } from "svelte";
    import { leagueAgentFactory } from "../../ic-agent/League";
    import { ProposalType } from "./GenericProposal.svelte";
    import LeagueProposalDetails from "./LeagueProposalDetails.svelte";
    import { Proposal } from "../../ic-agent/declarations/league";

    let proposals: Proposal[] = [];
    let genericProposals: ProposalType[] = [];

    $: genericProposals = proposals.map((p) => {
        let title, description;
        if ("changeTeamName" in p.content) {
            title = "Change Team Name to " + p.content.changeTeamName.name;
            description =
                "Change the team name to " + p.content.changeTeamName.name;
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

    let unsubscribeToTeamProposals = proposalStore.subscribeToLeague(
        (updatedProposals) => {
            proposals = updatedProposals;
        },
    );
    onDestroy(() => {
        unsubscribeToTeamProposals();
    });

    let onVote = async (proposalId: bigint, vote: boolean) => {
        let leagueAgent = await leagueAgentFactory();
        let result = await leagueAgent.voteOnProposal({
            proposalId: proposalId,
            vote,
        });
        console.log("Vote Result: ", result);
        if ("ok" in result) {
            proposalStore.refetchLeagueProposal(proposalId);
        }
    };
    let getProposal = (proposalId: bigint): Proposal => {
        let proposal = proposals.find((p) => p.id == proposalId);
        if (proposal) {
            return proposal;
        }
        throw new Error("Proposal not found: " + proposalId);
    };
</script>

{proposals.length}

<GenericProposalList proposals={genericProposals} {onVote} let:proposalId>
    <slot context="details">
        <LeagueProposalDetails proposal={getProposal(proposalId)} />
    </slot>
</GenericProposalList>
