<script lang="ts">
    import { Proposal } from "../../ic-agent/declarations/teams";
    import { toJsonString } from "../../utils/StringUtil";

    export let proposal: Proposal;
</script>

{#if "trainPlayer" in proposal.content}
    <div class="text-xl">Type: Train Player</div>
    <div>PlayerId: {proposal.content.trainPlayer.playerId}</div>
    <div>Skill: {toJsonString(proposal.content.trainPlayer.skill)}</div>
{:else if "changeName" in proposal.content}
    <div class="text-xl">Type: Change Name</div>
    <div>New Name: {proposal.content.changeName.name}</div>
{:else}
    Proposal Type Not Implemented {toJsonString(proposal.content)}
{/if}
