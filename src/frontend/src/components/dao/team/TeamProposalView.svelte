<script lang="ts">
    import { Proposal } from "../../../ic-agent/declarations/teams";
    import ChangeColorView from "./proposal_views/ChangeColorView.svelte";
    import ChangeNameView from "./proposal_views/ChangeNameView.svelte";
    import ChangeLogoView from "./proposal_views/ChangeLogoView.svelte";
    import TrainPositionView from "./proposal_views/TrainPositionView.svelte";
    import { toJsonString } from "../../../utils/StringUtil";

    export let proposal: Proposal;

    const components: Record<string, any> = {
        train: TrainPositionView,
        changeName: ChangeNameView,
        changeColor: ChangeColorView,
        changeLogo: ChangeLogoView,
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
