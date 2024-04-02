<script lang="ts">
    import { Proposal } from "../../../ic-agent/declarations/teams";
    import { toJsonString } from "../../../utils/StringUtil";

    export let proposal: Proposal;
</script>

{#if "train" in proposal.content}
    <div class="text-xl">Type: Train Player</div>
    <div>Position: {proposal.content.train.position}</div>
    <div>Skill: {toJsonString(proposal.content.train.skill)}</div>
{:else if "changeName" in proposal.content}
    <div class="text-xl">Type: Change Name</div>
    <div>New Name: {proposal.content.changeName.name}</div>
{:else}
    Proposal Type Not Implemented {toJsonString(proposal.content)}
{/if}
