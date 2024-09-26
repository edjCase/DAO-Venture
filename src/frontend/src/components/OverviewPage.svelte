<script lang="ts">
  import { Button } from "flowbite-svelte";
  import { ChevronRightOutline } from "flowbite-svelte-icons";
  import { navigate } from "svelte-routing";
  import { currentGameStore } from "../stores/CurrentGameStore";
  import { mainAgentFactory } from "../ic-agent/Main";
  import LoadingButton from "./common/LoadingButton.svelte";

  let createGame = async () => {
    let mainAgent = await mainAgentFactory();
    let result = await mainAgent.createGame({});
    if ("ok" in result) {
      currentGameStore.refetch();
    } else {
      console.error("Failed to create game", result);
    }
  };
</script>

<div>
  <main>
    <section class="relative">
      <h1 class="text-5xl font-semibold text-primary-500 mb-4">DAO-Venture</h1>
      <div class="text-xl mb-4">An experiment with a DAO run game</div>
      <div class="relative h-[400px] overflow-hidden">
        <img
          src="/images/landscape.png"
          alt="DAOVenture"
          class="w-full h-full object-cover"
        />
        <div
          class="absolute inset-0 bg-black bg-opacity-60 flex flex-col items-center justify-center text-white p-4"
        >
          <h1 class="text-4xl font-semibold text-primary-500 mb-2">The Game</h1>
          <h2 class="text-xl mb-4 max-w-96 text-center">
            Choose your character, navigate through scenarios, and battle
            creatures to see if you can make it to the end.
          </h2>
          <LoadingButton onClick={createGame}
            >Play
            <ChevronRightOutline class="w-3 h-3 ml-1" />
          </LoadingButton>
        </div>
      </div>
      <div class="relative h-[400px] overflow-hidden">
        <img
          src="/images/nodes.png"
          alt="The DAO"
          class="w-full h-full object-cover"
        />
        <div
          class="absolute inset-0 bg-black bg-opacity-60 flex flex-col items-center justify-center text-white p-4"
        >
          <h1 class="text-4xl font-semibold text-primary-500 mb-2">The DAO</h1>
          <h2 class="text-xl max-w-96 text-center text-primary-500">
            Contribute
          </h2>
          <div>Submit new game content</div>
          <h2 class="text-xl max-w-96 text-center text-primary-500">Govern</h2>
          <div class="w-72 text-pretty">
            Vote on the best content, features, and game direction
          </div>
          <Button class="mt-4" on:click={() => navigate("/game-info")}>
            Learn More
            <ChevronRightOutline class="w-3 h-3 ml-1" />
          </Button>
        </div>
      </div>
    </section>
  </main>
</div>
