<script lang="ts">
  import { Button, Card } from "flowbite-svelte";
  import { ChevronRightOutline } from "flowbite-svelte-icons";
  import { navigate } from "svelte-routing";
</script>

<div>
  <main>
    <section>
      <h1 class="text-3xl font-semibold mx-auto text-primary-500">
        DAOVenture
      </h1>
      <h2 class="text-xl mb-4 w-96 mx-auto">
        An experiment in evolving a game through its community using a DAO
      </h2>
      <div class="space-y-4 flex flex-col items-center">
        <Card class="bg-gray-800 border-green-400">
          <h3 class="text-xl font-semibold mb-2 text-primary-500">Play</h3>
          <p class="text-sm">
            Choose your character, navigate through scenarios, and battle
            creatures and see if you can make it to the end.
          </p>
        </Card>
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
        <ChevronRightOutline class="w-5 h-5 ml-2" />
      </Button>
    </section>
  </main>
</div>
