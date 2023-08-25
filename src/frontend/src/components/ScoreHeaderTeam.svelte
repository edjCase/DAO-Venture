<script lang="ts">
  import { get } from "svelte/store";
  import type { MatchTeam } from "../ic-agent/Stadium";
  import { teamStore } from "../stores/TeamStore";

  export let team: MatchTeam;
  let teamDetails = get(teamStore).find(
    (t) => t.id.toString() == team.id.toString()
  );
</script>

<div class="team-info">
  <div>
    <div>{teamDetails.name}</div>
    <div class="standing">14-20</div>
  </div>
  <img src={teamDetails.logoUrl} alt="{teamDetails.name} Logo" />
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
