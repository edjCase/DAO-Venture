<script lang="ts">
    import { ChangeTeamLogoContent__1 } from "../../../../ic-agent/declarations/main";
    import { teamStore } from "../../../../stores/TeamStore";

    export let content: ChangeTeamLogoContent__1;
    $: teams = $teamStore;

    let team = teams?.find((team) => team.id === content.teamId);
</script>

<div>Team Id: {content.teamId}</div>
<div>Current Logo: {team?.name}</div>

<div class="flex justify-center">
    <img
        style="width: 100px; height: 100px"
        src={content.logoUrl}
        alt="New Logo"
    />
</div>
