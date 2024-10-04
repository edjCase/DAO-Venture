<script lang="ts">
  import { itemStore } from "../stores/ItemStore";
  import Item from "./content/Item.svelte";
  import { weaponStore } from "../stores/WeaponStore";
  import Weapon from "./content/Weapon.svelte";
  import { classStore } from "../stores/ClassStore";
  import Class from "./content/Class.svelte";
  import { creatureStore } from "../stores/CreatureStore";
  import Creature from "./content/Creature.svelte";
  import { raceStore } from "../stores/RaceStore";
  import Race from "./content/Race.svelte";
  import Zone from "./content/Zone.svelte";
  import { zoneStore } from "../stores/ZoneStore";
  import ContentGrid from "./content/ContentGrid.svelte";
  import { achievementStore } from "../stores/AchievementStore";
  import Achievement from "./content/Achievement.svelte";
  import { Button } from "flowbite-svelte";

  const contentOptions = [
    { value: "Items", store: itemStore, Component: Item },
    { value: "Weapons", store: weaponStore, Component: Weapon },
    { value: "Classes", store: classStore, Component: Class },
    { value: "Creatures", store: creatureStore, Component: Creature },
    { value: "Races", store: raceStore, Component: Race },
    { value: "Zones", store: zoneStore, Component: Zone },
    { value: "Achievements", store: achievementStore, Component: Achievement },
  ];
  let selectedContent = contentOptions[0];
</script>

<h1 class="text-5xl font-semibold text-primary-500 my-4 text-center">
  Game Content
</h1>

<div class="mb-4 flex justify-center gap-2 flex-wrap">
  {#each contentOptions as option}
    <Button
      class="px-4 py-2 rounded-md transition-colors duration-200 ease-in-out {selectedContent ===
      option
        ? 'bg-primary-500 text-white'
        : 'bg-gray-200'}"
      on:click={() => (selectedContent = option)}
    >
      {option.value}
    </Button>
  {/each}
</div>
<ContentGrid
  label={selectedContent.value}
  store={selectedContent.store}
  Component={selectedContent.Component}
/>
