<script lang="ts">
  import { TabItem, Tabs } from "flowbite-svelte";
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

  $: items = $itemStore;
  $: weapons = $weaponStore;
  $: classes = $classStore;
  $: creatures = $creatureStore;
  $: races = $raceStore;
  $: zones = $zoneStore;
</script>

<Tabs>
  <TabItem open title="Items">
    <div class="flex flex-wrap gap-2 justify-between">
      {#each items as item}
        <div class="border">
          <Item {item} pixelSize={2} />
        </div>
      {/each}
    </div>
  </TabItem>
  <TabItem title="Weapons">
    <div class="flex flex-wrap gap-2 justify-between">
      {#each weapons as weapon}
        <div class="border">
          <Weapon {weapon} pixelSize={2} />
        </div>
      {/each}
    </div>
  </TabItem>
  <TabItem title="Classes">
    <div class="flex flex-wrap gap-2 justify-between">
      {#each classes as class_}
        <div class="border">
          <Class value={class_} pixelSize={2} />
        </div>
      {/each}
    </div>
  </TabItem>
  <TabItem title="Creatures">
    <div class="flex flex-wrap gap-2 justify-between">
      {#each creatures as creature}
        <div class="border">
          <Creature value={creature} pixelSize={2} />
        </div>
      {/each}
    </div>
  </TabItem>
  <TabItem title="Races">
    <div class="flex flex-wrap gap-2 justify-between">
      {#each races as race}
        <div class="border">
          <Race value={race} pixelSize={2} />
        </div>
      {/each}
    </div>
  </TabItem>
  <TabItem title="Zones">
    <div class="flex flex-wrap gap-2 justify-between">
      {#each zones as zone}
        <div class="border">
          <Zone value={zone} pixelSize={2} />
        </div>
      {/each}
    </div>
  </TabItem>
</Tabs>
