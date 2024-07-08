<script lang="ts">
    import { Team } from "../../ic-agent/declarations/main";
    import { MatchDetails } from "../../models/Match";
    import { mapTeamOrUndetermined } from "../../models/Team";
    import TeamLogo from "../team/TeamLogo.svelte";

    export let match: MatchDetails;
    export let teams: Team[];

    let team1OrUndetermined = mapTeamOrUndetermined(match.team1, teams);
    let team2OrUndetermined = mapTeamOrUndetermined(match.team2, teams);
</script>

<div class="flex items-center justify-center text-center">
    <TeamLogo team={team1OrUndetermined} size="xs" name="left" />
    <span class="text-gray-500 mx-1">vs</span>
    <TeamLogo team={team2OrUndetermined} size="xs" name="right" />
</div>
