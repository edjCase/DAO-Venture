<script lang="ts">
    import { Proposal } from "../../../ic-agent/declarations/teams";
    import { toJsonString } from "../../../utils/StringUtil";
    import RgbColor from "../../common/RgbColor.svelte";

    export let proposal: Proposal;
</script>

{#if "train" in proposal.content}
    <div class="text-xl">Type: Train Player</div>
    <div>Position: {proposal.content.train.position}</div>
    <div>Skill: {toJsonString(proposal.content.train.skill)}</div>
{:else if "changeName" in proposal.content}
    <div class="text-xl">Type: Change Name</div>
    <div>New Name: {proposal.content.changeName.name}</div>
{:else if "changeColor" in proposal.content}
    <div class="text-xl">Type: Change Color</div>
    <RgbColor
        red={proposal.content.changeColor.color[0]}
        green={proposal.content.changeColor.color[1]}
        blue={proposal.content.changeColor.color[2]}
    />
{:else}
    Proposal Type Not Implemented {toJsonString(proposal.content)}
{/if}
