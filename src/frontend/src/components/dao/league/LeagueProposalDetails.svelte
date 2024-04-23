<script lang="ts">
    import { Proposal } from "../../../ic-agent/declarations/league";
    import { teamStore } from "../../../stores/TeamStore";
    import { toJsonString } from "../../../utils/StringUtil";
    import RgbColor from "../../common/RgbColor.svelte";

    export let proposal: Proposal;

    $: teams = $teamStore;

    const toTeamName = (teamId: bigint) => {
        return teams?.find((team) => team.id === teamId)?.name ?? "???";
    };
</script>

{#if "changeTeamName" in proposal.content}
    <div class="text-xl">Type: Change Team Name</div>
    <div>Team: {toTeamName(proposal.content.changeTeamName.teamId)}</div>
    <div>New Name: {proposal.content.changeTeamName.name}</div>
{:else if "changeTeamColor" in proposal.content}
    <div class="text-xl">Type: Change Team Color</div>
    <div>Team: {toTeamName(proposal.content.changeTeamColor.teamId)}</div>
    <RgbColor value={proposal.content.changeTeamColor.color} />
{:else if "changeTeamDescription" in proposal.content}
    <div class="text-xl">Type: Change Team Description</div>
    <div>Team: {toTeamName(proposal.content.changeTeamDescription.teamId)}</div>
    <div>
        New Description: {proposal.content.changeTeamDescription.description}
    </div>
{:else if "changeTeamLogo" in proposal.content}
    <div class="text-xl">Type: Change Team Logo</div>
    <div>Team: {toTeamName(proposal.content.changeTeamLogo.teamId)}</div>
    <div>
        New Logo: <img
            src={proposal.content.changeTeamLogo.logoUrl}
            alt="New Logo"
        />
    </div>
{:else if "changeTeamMotto" in proposal.content}
    <div class="text-xl">Type: Change Team Motto</div>
    <div>Team: {toTeamName(proposal.content.changeTeamMotto.teamId)}</div>
    <div>New Motto: {proposal.content.changeTeamMotto.motto}</div>
{:else}
    Proposal Type Not Implemented {toJsonString(proposal.content)}
{/if}
