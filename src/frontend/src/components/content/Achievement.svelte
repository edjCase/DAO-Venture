<script lang="ts">
  import { Achievement } from "../../ic-agent/declarations/main";
  import { achievementStore } from "../../stores/AchievementStore";
  import Entity from "./Entity.svelte";

  export let value: Achievement | string;
  export let pixelSize: number = 1;
</script>

<Entity
  entity={value}
  {pixelSize}
  store={achievementStore}
  entityType="Achievement"
/>
