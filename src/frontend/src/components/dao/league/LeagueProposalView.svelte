<script lang="ts">
    import { WorldProposal } from "../../../ic-agent/declarations/main";
    import ChangeTownColorView from "./proposal_views/ChangeTownColorView.svelte";
    import ChangeTownNameView from "./proposal_views/ChangeTownNameView.svelte";
    import ChangeTeamFlagView from "./proposal_views/ChangeTeamFlagView.svelte";
    import ChangeTownMottoView from "./proposal_views/ChangeTownMottoView.svelte";
    import ChangeTownDescriptionView from "./proposal_views/ChangeTownDescriptionView.svelte";
    import { toJsonString } from "../../../utils/StringUtil";
    import MotionView from "./proposal_views/MotionView.svelte";

    export let proposal: WorldProposal;

    const components: Record<string, any> = {
        motion: MotionView,
        changeName: ChangeTownNameView,
        changeColor: ChangeTownColorView,
        changeLogo: ChangeTeamFlagView,
        changeMotto: ChangeTownMottoView,
        changeDescription: ChangeTownDescriptionView,
    };

    const type = Object.keys(proposal.content as any)[0];
    const SelectedComponent = components[type];
    const content = (proposal.content as any)[type];
</script>

{#if !SelectedComponent}
    Not Implemented View: <pre>{toJsonString(proposal.content)}</pre>
{:else}
    <svelte:component this={SelectedComponent} {content} />
{/if}
