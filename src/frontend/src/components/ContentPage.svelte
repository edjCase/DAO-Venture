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
  import ContentGrid from "./content/ContentGrid.svelte";

  $: items = $itemStore;
  $: weapons = $weaponStore;
  $: classes = $classStore;
  $: creatures = $creatureStore;
  $: races = $raceStore;
  $: zones = $zoneStore;
</script>

<Tabs>
  <TabItem open title="Items">
    <ContentGrid {items} Component={Item} propName="item" />
  </TabItem>
  <TabItem title="Weapons">
    <ContentGrid items={weapons} Component={Weapon} propName="weapon" />
  </TabItem>
  <TabItem title="Classes">
    <ContentGrid items={classes} Component={Class} />
  </TabItem>
  <TabItem title="Creatures">
    <ContentGrid items={creatures} Component={Creature} />
  </TabItem>
  <TabItem title="Races">
    <ContentGrid items={races} Component={Race} />
  </TabItem>
  <TabItem title="Zones">
    <ContentGrid items={zones} Component={Zone} />
  </TabItem>
</Tabs>
