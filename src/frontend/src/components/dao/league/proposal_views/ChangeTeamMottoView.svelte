<script lang="ts">
    import { ChangeTeamMottoContent__1 } from "../../../../ic-agent/declarations/main";
    import { teamStore } from "../../../../stores/TeamStore";

    export let content: ChangeTeamMottoContent__1;
    $: teams = $teamStore;

    let team = teams?.find((team) => team.id === content.teamId);
</script>

<div>Team Id: {content.teamId}</div>
<div>Current Motto: {team?.name}</div>

<div>New Motto: {content.motto}</div>
