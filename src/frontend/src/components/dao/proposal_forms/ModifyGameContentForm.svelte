<script lang="ts">
  import { Select } from "flowbite-svelte";
  import ItemForm from "./modify_game_content/ItemForm.svelte";
  import CreatureForm from "./modify_game_content/CreatureForm.svelte";
  import ImageForm from "./modify_game_content/ImageForm.svelte";
  import ClassForm from "./modify_game_content/ClassForm.svelte";
  import RaceForm from "./modify_game_content/RaceForm.svelte";
  import ZoneForm from "./modify_game_content/ZoneForm.svelte";
  import WeaponForm from "./modify_game_content/WeaponForm.svelte";
  import AchievementForm from "./modify_game_content/AchievementForm.svelte";
  import ScenarioForm from "./modify_game_content/ScenarioForm.svelte";
  import ActionForm from "./modify_game_content/ActionForm.svelte";

  let gameContentTypes = [
    { value: "item", name: "Item" },
    { value: "image", name: "Image" },
    { value: "creature", name: "Creature" },
    { value: "class", name: "Class" },
    { value: "race", name: "Race" },
    { value: "zone", name: "Zone" },
    { value: "weapon", name: "Weapon" },
    { value: "achievement", name: "Achievement" },
    { value: "scenario", name: "Scenario" },
    { value: "action", name: "Action" },
  ];
  let selectedGameContentType: string = gameContentTypes[0].value;
</script>

<Select items={gameContentTypes} bind:value={selectedGameContentType} />
<div>
  {#if selectedGameContentType === "item"}
    <ItemForm />
  {:else if selectedGameContentType === "image"}
    <ImageForm />
  {:else if selectedGameContentType === "creature"}
    <CreatureForm />
  {:else if selectedGameContentType === "class"}
    <ClassForm />
  {:else if selectedGameContentType === "race"}
    <RaceForm />
  {:else if selectedGameContentType === "zone"}
    <ZoneForm />
  {:else if selectedGameContentType === "weapon"}
    <WeaponForm />
  {:else if selectedGameContentType === "achievement"}
    <AchievementForm />
  {:else if selectedGameContentType === "scenario"}
    <ScenarioForm />
  {:else if selectedGameContentType === "action"}
    <ActionForm />
  {:else}
    NOT IMPLEMENTED GAME CONTENT FORM: <pre>{selectedGameContentType}</pre>
  {/if}
</div>
