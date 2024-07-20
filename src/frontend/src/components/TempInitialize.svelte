<script lang="ts">
  import { CreatePlayerFluffResult } from "../ic-agent/declarations/main";
  import { townStore } from "../stores/TownStore";
  import { playerStore } from "../stores/PlayerStore";
  import { towns as townData } from "../data/TownData";
  import { players as playerData } from "../data/PlayerData";
  import { townTraits as traitData } from "../data/TownTraitData";
  import { mainAgentFactory } from "../ic-agent/Main";
  import LoadingButton from "./common/LoadingButton.svelte";
  import { traitStore } from "../stores/TraitStore";
  import BigIntInput from "./scenario/editors/BigIntInput.svelte";
  import { Label } from "flowbite-svelte";

  $: towns = $townStore;
  $: players = $playerStore;

  let initialCurrency = BigInt(10);
  let initialEntropy = BigInt(7);

  let createTowns = async function (): Promise<void> {
    let mainAgent = await mainAgentFactory();
    let promises = [];
    for (let i = 0; i < townData.length; i++) {
      let town = townData[i];

      let promise = mainAgent
        .createTown({
          ...town,
          entropy: initialEntropy,
          currency: initialCurrency,
        })
        .then(async (result) => {
          if ("ok" in result) {
            let townId = result.ok;
            console.log("Created town: ", townId);
          } else {
            console.log("Failed to make town: ", result);
          }
        });
      promises.push(promise);
    }
    await Promise.all(promises);
    await townStore.refetch();
    await playerStore.refetch();
  };

  let createPlayers = async function () {
    let mainAgent = await mainAgentFactory();
    let promises = [];
    // loop over count
    for (let player of playerData) {
      let promise = mainAgent
        .addFluff({
          name: player.name,
          title: player.title,
          description: player.description,
          likes: player.likes,
          dislikes: player.dislikes,
          quirks: player.quirks,
        })
        .then((result: CreatePlayerFluffResult) => {
          if ("ok" in result) {
            console.log("Added player fluff: ", player.name);
          } else {
            console.error("Failed to add player fluff: ", player.name, result);
          }
        });
      promises.push(promise);
    }
    await Promise.all(promises);
  };

  let createTownTraits = async function () {
    let mainAgent = await mainAgentFactory();
    let promises = [];
    for (let trait of traitData) {
      let promise = mainAgent.createTownTrait(trait).then(async (result) => {
        if ("ok" in result) {
          let traitId = result.ok;
          console.log("Created trait: ", traitId);
        } else {
          console.log("Failed to make trait: ", result);
        }
      });
      promises.push(promise);
    }
    await Promise.all(promises);
    await traitStore.refetch();
  };

  let initialize = async function () {
    await createPlayers();
    await createTowns();
    await createTownTraits();
  };
</script>

{#if !towns || !players || players.length + towns.length <= 0}
  <Label>Initial Town Currency</Label>
  <BigIntInput bind:value={initialCurrency} />
  <Label>Initial Town Entropy</Label>
  <BigIntInput bind:value={initialEntropy} />
  <LoadingButton onClick={initialize}>
    Initialize With Default Data
  </LoadingButton>
{/if}
