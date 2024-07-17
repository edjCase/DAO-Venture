<script lang="ts">
    import { LeagueProposal } from "../../../ic-agent/declarations/main";
    import ChangeTeamColorView from "./proposal_views/ChangeTeamColorView.svelte";
    import ChangeTeamNameView from "./proposal_views/ChangeTeamNameView.svelte";
    import ChangeTeamLogoView from "./proposal_views/ChangeTeamLogoView.svelte";
    import ChangeTeamMottoView from "./proposal_views/ChangeTeamMottoView.svelte";
    import ChangeTeamDescriptionView from "./proposal_views/ChangeTeamDescriptionView.svelte";
    import { toJsonString } from "../../../utils/StringUtil";
    import MotionView from "./proposal_views/MotionView.svelte";

    export let proposal: LeagueProposal;

    const components: Record<string, any> = {
        motion: MotionView,
        changeName: ChangeTeamNameView,
        changeColor: ChangeTeamColorView,
        changeLogo: ChangeTeamLogoView,
        changeMotto: ChangeTeamMottoView,
        changeDescription: ChangeTeamDescriptionView,
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
