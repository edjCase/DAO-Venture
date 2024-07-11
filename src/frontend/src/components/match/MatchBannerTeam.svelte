<script lang="ts">
    import { TeamOrUndetermined } from "../../models/Team";
    import TeamLogo from "../team/TeamLogo.svelte";

    export let team: TeamOrUndetermined;
    export let score: bigint | undefined;
</script>

<div class="flex items-center jusity-center">
    <div class="mr-2">
        <TeamLogo {team} size="xxs" border={true} padding={false} />
    </div>
    <div>
        {score == undefined ? "-" : score.toString()}
    </div>
</div>
