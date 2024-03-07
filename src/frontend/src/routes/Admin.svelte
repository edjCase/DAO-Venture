<script lang="ts">
  import DaoAdmin from "../components/DaoAdmin.svelte";
  import ScheduleSeason from "../components/season/ScheduleSeason.svelte";
  import TempInitialize from "../components/TempInitialize.svelte";
  import UpdateLeagueCanistersButton from "../components/UpdateLeagueCanistersButton.svelte";
</script>

<div>
  <UpdateLeagueCanistersButton />
</div>
---
<div>
  <ScheduleSeason />
</div>
---
<div>
  <DaoAdmin />
</div>
---
<div>
  <TempInitialize />
</div>
