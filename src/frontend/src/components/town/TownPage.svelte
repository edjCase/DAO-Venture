<script lang="ts">
  import { TabItem, Tabs } from "flowbite-svelte";
  import TownFlag from "./TownFlag.svelte";
  import { Town } from "../../ic-agent/declarations/main";
  export let town: Town;
</script>

<div class="text-center my-2 mx-auto p-1 border rounded">
  <div class="flex flex-col p-2 gap-2">
    <div class="flex-1 flex justify-center items-center gap-2">
      <TownFlag {town} size="md" />
      <div class="text-3xl">{town.name}</div>
    </div>
  </div>
  <Tabs>
    <TabItem title="Fluff">
      <div class="flex-1 flex flex-col justify-center text-left p-5 text-lg">
        <div class="town-info">
          <div class="town-info-title">Town Motto</div>
          <div class="town-info-text">{town.motto}</div>
        </div>
        <div class="town-info inline">
          <div class="town-info-title">Managers:</div>
          <div class="town-info-text">0</div>
        </div>
        <div class="town-info inline">
          <div class="town-info-title">Championship Seasons:</div>
          <div class="town-info-text"></div>
        </div>
      </div>
    </TabItem>
  </Tabs>
</div>

<style>
  .town-info.inline div {
    display: inline;
  }
  .town-info-title {
    font-weight: bold;
    font-size: larger;
  }
</style>
