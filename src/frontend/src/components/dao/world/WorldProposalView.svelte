<script lang="ts">
    import { WorldProposal } from "../../../ic-agent/declarations/main";
    import ChangeTownNameView from "./proposal_views/ChangeTownNameView.svelte";
    import ChangeTownFlagView from "./proposal_views/ChangeTownFlagView.svelte";
    import ChangeTownMottoView from "./proposal_views/ChangeTownMottoView.svelte";
    import { toJsonString } from "../../../utils/StringUtil";
    import MotionView from "./proposal_views/MotionView.svelte";

    export let proposal: WorldProposal;

    const components: Record<string, any> = {
        motion: MotionView,
        changeName: ChangeTownNameView,
        changeFlag: ChangeTownFlagView,
        changeMotto: ChangeTownMottoView,
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
