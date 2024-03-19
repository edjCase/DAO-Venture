<script lang="ts">
  import { TabItem, Tabs } from "flowbite-svelte";
  import SeasonHome from "../components/season/SeasonHome.svelte";
  import ScenarioHome from "../components/scenario/ScenarioHome.svelte";
</script>

<div class="content">
  <Tabs>
    <TabItem title="Scenarios" open={true}>
      <ScenarioHome />
    </TabItem>
    <TabItem title="Season">
      <SeasonHome />
    </TabItem>
  </Tabs>
</div>
