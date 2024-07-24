<script lang="ts">
    import { TownProposal } from "../../../ic-agent/declarations/main";
    import ChangeNameView from "./proposal_views/ChangeNameView.svelte";
    import ChangeFlagView from "./proposal_views/ChangeFlagView.svelte";
    import ChangeMottoView from "./proposal_views/ChangeMottoView.svelte";
    import { toJsonString } from "../../../utils/StringUtil";
    import MotionView from "./proposal_views/MotionView.svelte";
    import AddJobView from "./proposal_views/AddJobView.svelte";
    import UpdateJobView from "./proposal_views/UpdateJobView.svelte";
    import RemoveJobView from "./proposal_views/RemoveJobView.svelte";

    export let proposal: TownProposal;
    export let townId: bigint;

    const components: Record<string, any> = {
        motion: MotionView,
        changeName: ChangeNameView,
        changeFag: ChangeFlagView,
        changeMotto: ChangeMottoView,
        addJob: AddJobView,
        updateJob: UpdateJobView,
        removeJob: RemoveJobView,
    };

    const type = Object.keys(proposal.content as any)[0];
    const SelectedComponent = components[type];
    const content = (proposal.content as any)[type];
</script>

{#if !SelectedComponent}
    Not Implemented View: <pre>{toJsonString(proposal.content)}</pre>
{:else}
    <svelte:component this={SelectedComponent} {content} {townId} />
{/if}
