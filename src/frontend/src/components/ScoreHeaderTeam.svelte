<script lang="ts">
  import { get } from "svelte/store";
  import type { MatchTeam } from "../ic-agent/Stadium";
  import { teamStore } from "../stores/TeamStore";
  import type { Principal } from "@dfinity/principal";

  export let teamId: Principal;
  let teamDetails = get(teamStore).find(
    (t) => t.id.toString() == teamId.toString()
  );
</script>

<div class="team-info">
  <div>
    <div>{teamDetails.name}</div>
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
    margin-left: 10px;
  }
</style>
