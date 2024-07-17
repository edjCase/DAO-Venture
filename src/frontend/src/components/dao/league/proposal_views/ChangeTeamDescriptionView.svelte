<script lang="ts">
    import { ChangeTeamDescriptionContent__1 } from "../../../../ic-agent/declarations/main";
    import { teamStore } from "../../../../stores/TeamStore";

    export let content: ChangeTeamDescriptionContent__1;
    $: teams = $teamStore;

    let team = teams?.find((team) => team.id === content.teamId);
</script>

<div>Team Id: {content.teamId}</div>
<div>Current Name: {team?.name}</div>

<div>New Description: {content.description}</div>
