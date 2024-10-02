<script lang="ts">
  import { onMount } from "svelte";
  import { mainAgentFactory } from "../../ic-agent/Main";
  import { ModifyGameContent } from "../../ic-agent/declarations/main";
  import LoadingButton from "../common/LoadingButton.svelte";

  let initialize = async () => {
    let mainAgent = await mainAgentFactory();

    let addGameContent = async (content: ModifyGameContent) => {
      let result = await mainAgent.createWorldProposal({
        modifyGameContent: content,
      });
      if ("ok" in result) {
        console.log("Added content", content);
        let voteResult = await mainAgent.voteOnWorldProposal({
          proposalId: result.ok,
          vote: true,
        });
        if ("ok" in voteResult) {
        } else {
          console.error("Failed to vote on proposal", result.ok, voteResult);
        }
      } else {
        console.error("Failed to add content", content, result);
      }
    };

    let achievements = await import("../../initial_data/AchievementData").then(
      (module) => {
        return module.achievements;
      }
    );
    await Promise.all(
      achievements.map(async (achievement) => {
        await addGameContent({ achievement: achievement });
      })
    );

    let actions = await import("../../initial_data/ActionData").then(
      (module) => {
        return module.actions;
      }
    );
    await Promise.all(
      actions.map(async (action) => {
        await addGameContent({ action: action });
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

    const scenarioPromises = [
      import(`../../initial_data/scenarios/CorruptedTreant`).then(
        (module) => module.scenario
      ),
      import(`../../initial_data/scenarios/DarkElfAmbush`).then(
        (module) => module.scenario
      ),
      import(`../../initial_data/scenarios/DruidicSanctuary`).then(
        (module) => module.scenario
      ),
      import(`../../initial_data/scenarios/DwarvenWeaponsmith`).then(
        (module) => module.scenario
      ),
      import(`../../initial_data/scenarios/EnchantedGrove`).then(
        (module) => module.scenario
      ),
      import(`../../initial_data/scenarios/FaerieMarket`).then(
        (module) => module.scenario
      ),
      import(`../../initial_data/scenarios/GoblinRaidingParty`).then(
        (module) => module.scenario
      ),
      import(`../../initial_data/scenarios/KnowledgeNexus`).then(
        (module) => module.scenario
      ),
      import(`../../initial_data/scenarios/LostElfling`).then(
        (module) => module.scenario
      ),
      import(`../../initial_data/scenarios/MysteriousStructure`).then(
        (module) => module.scenario
      ),
      import(`../../initial_data/scenarios/MysticForge`).then(
        (module) => module.scenario
      ),
      import(`../../initial_data/scenarios/SinkingBoat`).then(
        (module) => module.scenario
      ),
      import(`../../initial_data/scenarios/TrappedDruid`).then(
        (module) => module.scenario
      ),
      import(`../../initial_data/scenarios/TravellingBard`).then(
        (module) => module.scenario
      ),
      import(`../../initial_data/scenarios/WanderingAlchemist`).then(
        (module) => module.scenario
      ),
    ];

    const scenarios = await Promise.all(scenarioPromises);

    await Promise.all(
      scenarios.map((scenario) => addGameContent({ scenario }))
    );

    let corruptedTreantScenario = await import(
      `../../initial_data/scenarios/CorruptedTreant`
    ).then((module) => {
      return module.scenario;
    });
    await addGameContent({ scenario: corruptedTreantScenario });

    let darkElfAmbushScenario = await import(
      `../../initial_data/scenarios/DarkElfAmbush`
    ).then((module) => {
      return module.scenario;
    });
    await addGameContent({ scenario: darkElfAmbushScenario });

    let druidicSanctuaryScenario = await import(
      `../../initial_data/scenarios/DruidicSanctuary`
    ).then((module) => {
      return module.scenario;
    });
    await addGameContent({ scenario: druidicSanctuaryScenario });

    let dwarvenWeaponsmithScenario = await import(
      `../../initial_data/scenarios/DwarvenWeaponsmith`
    ).then((module) => {
      return module.scenario;
    });
    await addGameContent({ scenario: dwarvenWeaponsmithScenario });

    let enchantedGroveScenario = await import(
      `../../initial_data/scenarios/EnchantedGrove`
    ).then((module) => {
      return module.scenario;
    });
    await addGameContent({ scenario: enchantedGroveScenario });

    let faerieMarketScenario = await import(
      `../../initial_data/scenarios/FaerieMarket`
    ).then((module) => {
      return module.scenario;
    });
    await addGameContent({ scenario: faerieMarketScenario });

    let goblinRaidingPartyScenario = await import(
      `../../initial_data/scenarios/GoblinRaidingParty`
    ).then((module) => {
      return module.scenario;
    });
    await addGameContent({ scenario: goblinRaidingPartyScenario });

    let knowledgeNexusScenario = await import(
      `../../initial_data/scenarios/KnowledgeNexus`
    ).then((module) => {
      return module.scenario;
    });
    await addGameContent({ scenario: knowledgeNexusScenario });

    let lostElflingScenario = await import(
      `../../initial_data/scenarios/LostElfling`
    ).then((module) => {
      return module.scenario;
    });
    await addGameContent({ scenario: lostElflingScenario });

    let mysteriousStructureScenario = await import(
      `../../initial_data/scenarios/MysteriousStructure`
    ).then((module) => {
      return module.scenario;
    });
    await addGameContent({ scenario: mysteriousStructureScenario });

    let mysticForgeScenario = await import(
      `../../initial_data/scenarios/MysticForge`
    ).then((module) => {
      return module.scenario;
    });
    await addGameContent({ scenario: mysticForgeScenario });

    let sinkingBoatScenario = await import(
      `../../initial_data/scenarios/SinkingBoat`
    ).then((module) => {
      return module.scenario;
    });
    await addGameContent({ scenario: sinkingBoatScenario });

    let trappedDruidScenario = await import(
      `../../initial_data/scenarios/TrappedDruid`
    ).then((module) => {
      return module.scenario;
    });
    await addGameContent({ scenario: trappedDruidScenario });

    let travellingBardScenario = await import(
      `../../initial_data/scenarios/TravellingBard`
    ).then((module) => {
      return module.scenario;
    });
    await addGameContent({ scenario: travellingBardScenario });

    let wanderingAlchemistScenario = await import(
      `../../initial_data/scenarios/WanderingAlchemist`
    ).then((module) => {
      return module.scenario;
    });
    await addGameContent({ scenario: wanderingAlchemistScenario });
  };

  let initialized: boolean | undefined;
  onMount(async () => {
    let mainAgent = await mainAgentFactory();
    let scenarios = await mainAgent.getScenarioMetaDataList();
    initialized = scenarios.length > 0;
  });
</script>

{#if initialized === false}
  <LoadingButton onClick={initialize}>Initialize Data</LoadingButton>
{/if}
