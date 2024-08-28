<script lang="ts">
  import { onMount } from "svelte";
  import { mainAgentFactory } from "../../ic-agent/Main";
  import {
    AddGameContentRequest,
    Trait,
  } from "../../ic-agent/declarations/main";
  import LoadingButton from "../common/LoadingButton.svelte";

  interface ImageModule {
    default: string;
  }
  let initialize = async () => {
    let mainAgent = await mainAgentFactory();

    let addGameContent = async (content: AddGameContentRequest) => {
      let result = await mainAgent.addGameContent(content);
      if ("ok" in result) {
        console.log("Added content", content);
      } else {
        console.error("Failed to add content", content, result);
      }
    };

    let imageModules = import.meta.glob("../../initial_data/images/*.png");

    await Promise.all(
      Object.keys(imageModules).map(async (path) => {
        const module = (await imageModules[path]()) as ImageModule;
        const response = await fetch(module.default);
        const data = await response.arrayBuffer();
        const id = path.split("/").pop()?.split(".").shift() || "";
        await addGameContent({
          image: { id: id, data: new Uint8Array(data), kind: { png: null } },
        });
      })
    );

    let traits = await import("../../initial_data/TraitData").then((module) => {
      return module.traits;
    });
    await Promise.all(
      traits.map(async (trait: Trait) => {
        await addGameContent({ trait: trait });
      })
    );

    let items = await import("../../initial_data/ItemData").then((module) => {
      return module.items;
    });
    await Promise.all(
      items.map(async (item) => {
        await addGameContent({ item: item });
      })
    );

    let weapons = await import("../../initial_data/WeaponData").then(
      (module) => {
        return module.weapons;
      }
    );
    await Promise.all(
      weapons.map(async (weapon) => {
        await addGameContent({ weapon: weapon });
      })
    );

    let classes = await import("../../initial_data/ClassData").then(
      (module) => {
        return module.classes;
      }
    );
    await Promise.all(
      classes.map(async (classData) => {
        await addGameContent({ class: classData });
      })
    );

    let races = await import("../../initial_data/RaceData").then((module) => {
      return module.races;
    });
    await Promise.all(
      races.map(async (race) => {
        await addGameContent({ race: race });
      })
    );

    let zones = await import("../../initial_data/ZoneData").then((module) => {
      return module.zones;
    });
    await Promise.all(
      zones.map(async (zone) => {
        await addGameContent({ zone: zone });
      })
    );

    let creatures = await import("../../initial_data/CreatureData").then(
      (module) => {
        return module.creatures;
      }
    );
    await Promise.all(
      creatures.map(async (creature) => {
        await addGameContent({ creature: creature });
      })
    );

    let scenarios = await import("../../initial_data/ScenarioData").then(
      (module) => {
        return module.scenarios;
      }
    );
    await Promise.all(
      scenarios.map(async (scenario) => {
        await addGameContent({ scenario: scenario });
      })
    );
  };

  let initialized = true;
  onMount(async () => {
    let mainAgent = await mainAgentFactory();
    let scenarios = await mainAgent.getScenarioMetaDataList();
    initialized = scenarios.length > 0;
  });
</script>

{#if !initialized}
  <LoadingButton onClick={initialize}>Initialize Data</LoadingButton>
{/if}
