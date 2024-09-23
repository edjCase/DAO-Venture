<script lang="ts">
  import { Button, Card } from "flowbite-svelte";
  import { ChevronRightOutline } from "flowbite-svelte-icons";
</script>

<div class="text-primary-500">
  <header class="mb-8 text-center">
    <p class="text-2xl mt-2">A DAO-Powered Roguelite Adventure</p>
  </header>

  <main>
    <section class="mb-8">
      <h2 class="text-2xl font-semibold mb-4">How It Works</h2>
      <div class="space-y-4 flex flex-col items-center">
        <Card class="bg-gray-800 border-green-400">
          <h3 class="text-xl font-semibold mb-2">Play</h3>
          <p class="text-sm">
            Choose your character, navigate through scenarios, and battle
            creatures and see if you can make it to the end.
          </p>
        </Card>
        <Card class="bg-gray-800 border-green-400">
          <h3 class="text-xl font-semibold mb-2">Contribute</h3>
          <p class="text-sm">
            Submit new content like characters, items, or scenarios to have it
            approved by the DAO and added into the game
          </p>
        </Card>
        <Card class="bg-gray-800 border-green-400">
          <h3 class="text-xl font-semibold mb-2">Govern</h3>
          <p class="text-sm">
            Participate in DAO voting to decide on new features, content, and
            the future direction of DAOventure.
          </p>
        </Card>
      </div>
      <Button class="mt-4">
        Learn More
        <ChevronRightOutline class="w-5 h-5 ml-2" />
      </Button>
    </section>
  </main>
</div>
