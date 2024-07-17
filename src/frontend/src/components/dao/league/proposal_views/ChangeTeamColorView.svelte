<script lang="ts">
    import { ChangeTeamColorContent__1 } from "../../../../ic-agent/declarations/main";
    import { teamStore } from "../../../../stores/TeamStore";
    import RgbColor from "../../../common/RgbColor.svelte";

    export let content: ChangeTeamColorContent__1;
    $: teams = $teamStore;

    let team = teams?.find((team) => team.id === content.teamId);
</script>

<div>Team Id: {content.teamId}</div>
<div>Current Name: {team?.name}</div>

<RgbColor value={content.color} disabled />
