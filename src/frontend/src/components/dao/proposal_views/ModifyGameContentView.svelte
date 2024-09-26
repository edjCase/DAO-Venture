<script lang="ts">
  import { ModifyGameContent } from "../../../ic-agent/declarations/main";
  import ItemView from "./modify_game_content/ItemView.svelte";
  import CreatureView from "./modify_game_content/CreatureView.svelte";
  import ClassView from "./modify_game_content/ClassView.svelte";
  import RaceView from "./modify_game_content/RaceView.svelte";
  import ZoneView from "./modify_game_content/ZoneView.svelte";
  import WeaponView from "./modify_game_content/WeaponView.svelte";
  import AchievementView from "./modify_game_content/AchievementView.svelte";
  import ScenarioView from "./modify_game_content/ScenarioView.svelte";
  import { toJsonString } from "../../../utils/StringUtil";
  import ActionView from "./modify_game_content/ActionView.svelte";

  export let content: ModifyGameContent;
</script>

<div>
  {#if "item" in content}
    <ItemView item={content.item} />
  {:else if "creature" in content}
    <CreatureView creature={content.creature} />
  {:else if "class" in content}
    <ClassView class_={content.class} />
  {:else if "race" in content}
    <RaceView race={content.race} />
  {:else if "zone" in content}
    <ZoneView zone={content.zone} />
  {:else if "weapon" in content}
    <WeaponView weapon={content.weapon} />
  {:else if "achievement" in content}
    <AchievementView achievement={content.achievement} />
  {:else if "scenario" in content}
    <ScenarioView scenario={content.scenario} />
  {:else if "action" in content}
    <ActionView action={content.action} />
  {:else}
    <div>NOT IMPLEMENTED GAME CONTENT VIEW: {toJsonString(content)}</div>
  {/if}
</div>
