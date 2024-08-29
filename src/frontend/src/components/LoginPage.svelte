<script lang="ts">
  import { Button } from "flowbite-svelte";
  import { userStore } from "../stores/UserStore";

  let login = async () => {
    await userStore.login();
  };
</script>

<section class="py-8">
  <h2 class="text-xl font-bold mb-4">Welcome, Adventurer!</h2>
  <p class="mb-4">
    Embark on a DAO-controlled journey through pixelated realms of fantasy and
    peril.
  </p>
</section>

<section class="py-8">
  <h2 class="text-xl font-bold mb-4">Game Overview</h2>
  <div class="flex flex-col items-center mb-8">
    <img
      src="/api/placeholder/300/200"
      alt="Retro game screenshot"
      class="mb-4 rounded"
    />
    <p>
      Experience a unique blend of community-driven gameplay and classic RPG
      elements.
    </p>
  </div>
  <div class="flex flex-col items-center mb-8">
    <p class="mb-4">Explore treacherous dungeons and mystical forests.</p>
    <img
      src="/api/placeholder/300/200"
      alt="Pixel art dungeon"
      class="rounded"
    />
  </div>
  <div class="flex flex-col items-center">
    <img
      src="/api/placeholder/300/200"
      alt="Pixel art character"
      class="mb-4 rounded"
    />
    <p>Customize your hero and forge your legend in the crypto realm.</p>
  </div>
</section>

<section class="py-8">
  <h2 class="text-xl font-bold mb-4">Key Features</h2>
  <ul class="list-disc list-inside">
    <li>DAO-controlled gameplay decisions</li>
    <li>Retro-style graphics with modern blockchain technology</li>
    <li>Community-driven storylines and quests</li>
    <li>Earn tokens and NFTs as you play</li>
  </ul>
</section>

<section class="py-8">
  <h2 class="text-xl font-bold mb-4">Join the Quest</h2>
  <p class="mb-4">
    Ready to start your adventure? Login now and become part of the legend!
  </p>
  <Button on:click={login}>Play Now</Button>
</section>
