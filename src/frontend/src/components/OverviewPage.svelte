<script lang="ts">
  import { Button, Card } from "flowbite-svelte";
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
      <h1 class="text-5xl font-semibold text-primary-500 my-4">DAOVenture</h1>
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
          <div>
            <LoadingButton onClick={createGame}
              >Play
              <ChevronRightOutline class="w-3 h-3 ml-1" />
            </LoadingButton>
          </div>
        </div>
      </div>

      <div class="space-y-4 flex flex-col items-center mt-8">
        <h1 class="text-primary-500 text-4xl font-semibold w-96">The DAO</h1>
        <Card class="bg-gray-800 border-green-400">
          <h3 class="text-xl font-semibold mb-2 text-primary-500">
            Contribute
          </h3>
          <p class="text-sm">
            Submit new content like characters, items, or scenarios to have it
            approved by the DAO and added into the game
          </p>
        </Card>
        <Card class="bg-gray-800 border-green-400">
          <h3 class="text-xl font-semibold mb-2 text-primary-500">Govern</h3>
          <p class="text-sm">
            Participate in DAO voting to decide on new features, content, and
            the future direction of DAOVenture.
          </p>
        </Card>
      </div>

      <Button class="mt-4" on:click={() => navigate("/game-info")}>
        Learn More
        <ChevronRightOutline class="w-3 h-3 ml-1" />
      </Button>
    </section>
  </main>
</div>
