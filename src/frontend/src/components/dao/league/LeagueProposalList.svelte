<script lang="ts">
    import GenericProposalList from "../GenericProposalList.svelte";
    import { proposalStore } from "../../../stores/ProposalStore";
    import { onDestroy } from "svelte";
    import { leagueAgentFactory } from "../../../ic-agent/League";
    import { ProposalType } from "../GenericProposal.svelte";
    import LeagueProposalDetails from "./LeagueProposalDetails.svelte";
    import { Proposal } from "../../../ic-agent/declarations/league";
    import { toJsonString } from "../../../utils/StringUtil";

    let proposals: Proposal[] = [];
    let genericProposals: ProposalType[] = [];

    $: genericProposals = proposals.map((p) => {
        let title;
        if ("changeTeamName" in p.content) {
            title = "Change Team Name ";
        } else if ("changeTeamColor" in p.content) {
            title = "Change Team Color";
        } else if ("changeTeamDescription" in p.content) {
            title = "Change Team Description";
        } else if ("changeTeamLogo" in p.content) {
            title = "Change Team Logo";
        } else if ("changeTeamMotto" in p.content) {
            title = "Change Team Motto";
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

    let onRefresh = async () => {
        await proposalStore.refetchLeagueProposals();
    };
</script>

<GenericProposalList
    proposals={genericProposals}
    {onVote}
    {onRefresh}
    let:proposalId
>
    <slot name="details">
        <LeagueProposalDetails proposal={getProposal(proposalId)} />
    </slot>
</GenericProposalList>
