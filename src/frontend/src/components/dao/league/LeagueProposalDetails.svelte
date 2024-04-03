<script lang="ts">
    import { Proposal } from "../../../ic-agent/declarations/league";
    import { toJsonString } from "../../../utils/StringUtil";
    import RgbColor from "../../common/RgbColor.svelte";

    export let proposal: Proposal;
</script>

{#if "changeTeamName" in proposal.content}
    <div class="text-xl">Type: Change Team Name</div>
    <div>Team: {proposal.content.changeTeamName.teamId}</div>
    <div>New Name: {proposal.content.changeTeamName.name}</div>
{:else if "changeTeamColor" in proposal.content}
    <div class="text-xl">Type: Change Color</div>
    <div>Team: {proposal.content.changeTeamColor.teamId}</div>
    <RgbColor value={proposal.content.changeTeamColor.color} />
{:else}
    Proposal Type Not Implemented {toJsonString(proposal.content)}
{/if}
