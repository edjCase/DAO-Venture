<script lang="ts">
  import { CreatePlayerFluffResult } from "../ic-agent/declarations/main";
  import { teamStore } from "../stores/TeamStore";
  import { playerStore } from "../stores/PlayerStore";
  import { teams as teamData } from "../data/TeamData";
  import { players as playerData } from "../data/PlayerData";
  import { teamTraits as traitData } from "../data/TeamTraitData";
  import { mainAgentFactory } from "../ic-agent/Main";
  import LoadingButton from "./common/LoadingButton.svelte";
  import { traitStore } from "../stores/TraitStore";
  import BigIntInput from "./scenario/editors/BigIntInput.svelte";
  import { Label } from "flowbite-svelte";

  $: teams = $teamStore;
  $: players = $playerStore;

  let initialCurrency = BigInt(10);
  let initialEntropy = BigInt(7);

  let createTeams = async function (): Promise<void> {
    let mainAgent = await mainAgentFactory();
    let promises = [];
    for (let i = 0; i < teamData.length; i++) {
      let team = teamData[i];

      let promise = mainAgent
        .createTeam({
          ...team,
          entropy: initialEntropy,
          currency: initialCurrency,
        })
        .then(async (result) => {
          if ("ok" in result) {
            let teamId = result.ok;
            console.log("Created team: ", teamId);
          } else {
            console.log("Failed to make team: ", result);
          }
        });
      promises.push(promise);
    }
    await Promise.all(promises);
    await teamStore.refetch();
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

  let createTeamTraits = async function () {
    let mainAgent = await mainAgentFactory();
    let promises = [];
    for (let trait of traitData) {
      let promise = mainAgent.createTeamTrait(trait).then(async (result) => {
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
    await createTeams();
    await createTeamTraits();
  };
</script>

{#if !teams || !players || players.length + teams.length <= 0}
  <Label>Initial Team Currency</Label>
  <BigIntInput bind:value={initialCurrency} />
  <Label>Initial Team Entropy</Label>
  <BigIntInput bind:value={initialEntropy} />
  <LoadingButton onClick={initialize}>
    Initialize With Default Data
  </LoadingButton>
{/if}
