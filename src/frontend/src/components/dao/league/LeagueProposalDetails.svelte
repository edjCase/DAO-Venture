<script lang="ts">
    import { LeagueProposal } from "../../../ic-agent/declarations/main";
    import { teamStore } from "../../../stores/TeamStore";
    import { toJsonString } from "../../../utils/StringUtil";
    import RgbColor from "../../common/RgbColor.svelte";

    export let proposal: LeagueProposal;

    $: teams = $teamStore;

    const toTeamName = (teamId: bigint) => {
        return teams?.find((team) => team.id === teamId)?.name ?? "???";
    };
</script>

{#if "changeTeamName" in proposal.content}
    <div>Team: {toTeamName(proposal.content.changeTeamName.teamId)}</div>
    <div>New Name: {proposal.content.changeTeamName.name}</div>
{:else if "changeTeamColor" in proposal.content}
    <div>Team: {toTeamName(proposal.content.changeTeamColor.teamId)}</div>
    <RgbColor value={proposal.content.changeTeamColor.color} />
{:else if "changeTeamDescription" in proposal.content}
    <div>Team: {toTeamName(proposal.content.changeTeamDescription.teamId)}</div>
    <div>
        New Description: {proposal.content.changeTeamDescription.description}
    </div>
{:else if "changeTeamLogo" in proposal.content}
    <div>Team: {toTeamName(proposal.content.changeTeamLogo.teamId)}</div>
    <div>
        New Logo: <img
            style="width: 100px; height: 100px; margin: auto"
            src={proposal.content.changeTeamLogo.logoUrl}
            alt="New Logo"
        />
    </div>
{:else if "changeTeamMotto" in proposal.content}
    <div>Team: {toTeamName(proposal.content.changeTeamMotto.teamId)}</div>
    <div>New Motto: {proposal.content.changeTeamMotto.motto}</div>
{:else}
    Proposal Type Not Implemented {toJsonString(proposal.content)}
{/if}
