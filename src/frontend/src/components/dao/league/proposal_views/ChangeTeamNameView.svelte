<script lang="ts">
    import { ChangeTeamNameContent__1 } from "../../../../ic-agent/declarations/main";
    import { teamStore } from "../../../../stores/TeamStore";

    export let content: ChangeTeamNameContent__1;

    $: teams = $teamStore;

    let team = teams?.find((team) => team.id === content.teamId);
</script>

<div>Team Id: {content.teamId}</div>
<div>Current Name: {team?.name}</div>
<div>New Name: {content.name}</div>
