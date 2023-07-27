<script lang="ts">
    import type { Team } from "../types/Game";
    export let team: Team;
</script>

<div class="team-info">
    <div>
        <div>{team.name}</div>
        <div class="standing">14-20</div>
    </div>
    <img src={team.logo} alt="{team.name} Logo" />
</div>

<style>
    
    .team-info {
        display: flex;
        align-items: center;
    }
    .team-info img {
        width: 50px;
        height: 50px;
        margin-right: 10px;
    }
    .team-info .standing {
        font-size: 0.8em;
    }
</style>