<script lang="ts">
  import { Select, SelectOptionType, Button, Label } from "flowbite-svelte";
  import ItemForm from "./modify_game_content/ItemForm.svelte";
  import CreatureForm from "./modify_game_content/CreatureForm.svelte";
  import ClassForm from "./modify_game_content/ClassForm.svelte";
  import RaceForm from "./modify_game_content/RaceForm.svelte";
  import ZoneForm from "./modify_game_content/ZoneForm.svelte";
  import WeaponForm from "./modify_game_content/WeaponForm.svelte";
  import AchievementForm from "./modify_game_content/AchievementForm.svelte";
  import ActionForm from "./modify_game_content/ActionForm.svelte";
  import ScenarioForm from "./modify_game_content/ScenarioForm.svelte";
  import { itemStore } from "../../../stores/ItemStore";
  import { classStore } from "../../../stores/ClassStore";
  import { creatureStore } from "../../../stores/CreatureStore";
  import { achievementStore } from "../../../stores/AchievementStore";
  import { actionStore } from "../../../stores/ActionStore";
  import { raceStore } from "../../../stores/RaceStore";
  import { weaponStore } from "../../../stores/WeaponStore";
  import { zoneStore } from "../../../stores/ZoneStore";
  import { scenarioMetaDataStore } from "../../../stores/ScenarioMetaDataStore";

  let gameContentTypes = [
    { value: "item", name: "Item", store: itemStore },
    { value: "creature", name: "Creature", store: creatureStore },
    { value: "class", name: "Class", store: classStore },
    { value: "race", name: "Race", store: raceStore },
    { value: "zone", name: "Zone", store: zoneStore },
    { value: "weapon", name: "Weapon", store: weaponStore },
    { value: "achievement", name: "Achievement", store: achievementStore },
    { value: "scenario", name: "Scenario", store: scenarioMetaDataStore },
    { value: "action", name: "Action", store: actionStore },
  ];
  let selectedGameContentType: string = gameContentTypes[0].value;

  $: contentStore = gameContentTypes.find(
    (contentType) => contentType.value === selectedGameContentType
  )!.store;

  let contentIds: SelectOptionType<string>[] = [];
  $: {
    let ids =
      $contentStore?.map((content) => ({
        value: content.id,
        name: content.name,
      })) ?? [];
    ids = ids.sort((a, b) => a.name.localeCompare(b.name));
    contentIds = ids;
  }

  let selectedContentId: string = "";

  let loadContent = () => {
    content = $contentStore?.find(
      (content) => content.id === selectedContentId
    );
  };
  let content: any | undefined;
</script>

<Select items={gameContentTypes} bind:value={selectedGameContentType} />
<div>
  <Label>Load Existing</Label>
  <div class="flex">
    <Select items={contentIds} bind:value={selectedContentId} />
    <Button on:click={loadContent}>Load</Button>
  </div>
  <!-- Rebuild if content changes -->
  {#key content}
    {#if selectedGameContentType === "item"}
      <ItemForm value={content} />
    {:else if selectedGameContentType === "creature"}
      <CreatureForm value={content} />
    {:else if selectedGameContentType === "class"}
      <ClassForm value={content} />
    {:else if selectedGameContentType === "race"}
      <RaceForm value={content} />
    {:else if selectedGameContentType === "zone"}
      <ZoneForm value={content} />
    {:else if selectedGameContentType === "weapon"}
      <WeaponForm value={content} />
    {:else if selectedGameContentType === "achievement"}
      <AchievementForm value={content} />
    {:else if selectedGameContentType === "scenario"}
      <ScenarioForm value={content} />
    {:else if selectedGameContentType === "action"}
      <ActionForm value={content} />
    {:else}
      NOT IMPLEMENTED GAME CONTENT FORM: <pre>{selectedGameContentType}</pre>
    {/if}
  {/key}
</div>
