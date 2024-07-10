<script lang="ts">
    import { TeamOrUndetermined } from "../../models/Team";
    import TeamLogo from "../team/TeamLogo.svelte";

    export let team1: TeamOrUndetermined;
    export let team2: TeamOrUndetermined;
</script>

<div class="flex items-center justify-center text-center">
    <TeamLogo team={team1} size="xs" name="left" />
    <span class="text-gray-500 mx-1">vs</span>
    <TeamLogo team={team2} size="xs" name="right" />
</div>
