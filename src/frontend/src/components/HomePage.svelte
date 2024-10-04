<script lang="ts">
  import InitialDataLoad from "./game/InitialDataLoad.svelte";
  import { Button } from "flowbite-svelte";
  import {
    ChevronRightOutline,
    GithubSolid,
    TwitterSolid,
    MessagesSolid,
    ArrowUpRightFromSquareOutline,
    PlaySolid,
  } from "flowbite-svelte-icons";
  import { navigate } from "svelte-routing";
</script>

<InitialDataLoad />

<div class="text-center">
  <h1 class="text-5xl font-semibold text-primary-500 mb-4">DAO-Venture</h1>
  <div class="text-xl mb-4">An experiment with a DAO run game</div>
  <div class="text-2xl text-red-500 font-semibold mb-4 max-w-96 mx-auto">
    Game is in ALPHA state and is not yet fully functional. Game state will be
    wiped periodically. Report any issues on
    <Button
      href="https://oc.app/community/cghnf-2qaaa-aaaar-baa6a-cai/channel/96392963121583024737943677773512869402/?ref=nlzgz-paaaa-aaaaf-acwna-cai"
      target="_blank"
      style="text-shadow: none;"
    >
      Open Chat <ArrowUpRightFromSquareOutline size="xs" class="ml-1" />
    </Button>
  </div>
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
        Choose your character, navigate through scenarios, and battle creatures
        to see if you can make it to the end.
      </h2>
      <Button
        on:click={() => navigate("/game")}
        class="rounded-full border-2 border-primary-500 p-6 flex items-center gap-2"
      >
        <span class="text-2xl">Play</span>
        <PlaySolid class="w-5 h-5 mb-1" />
      </Button>
      <Button class="mt-4" on:click={() => navigate("/game-overview")}>
        Learn More
        <ChevronRightOutline class="w-3 h-3 ml-1" />
      </Button>
    </div>
  </div>
  <div class="relative h-[400px] overflow-hidden mt-2">
    <img
      src="/images/nodes.png"
      alt="The DAO"
      class="w-full h-full object-cover"
    />
    <div
      class="absolute inset-0 bg-black bg-opacity-60 flex flex-col items-center justify-center text-white p-4"
    >
      <h1 class="text-4xl font-semibold text-primary-500 mb-2">The DAO</h1>
      <h2 class="text-xl max-w-96 text-center text-primary-500">Contribute</h2>
      <div>Submit new game content</div>
      <h2 class="text-xl max-w-96 text-center text-primary-500">Govern</h2>
      <div class="w-72 text-pretty">
        Vote on the best content, features, and game direction
      </div>
      <Button class="mt-4" on:click={() => navigate("/dao")}>
        View
        <ChevronRightOutline class="w-3 h-3 ml-1" />
      </Button>
      <Button class="mt-4" on:click={() => navigate("/dao-overview")}>
        Learn More
        <ChevronRightOutline class="w-3 h-3 ml-1" />
      </Button>
    </div>
  </div>
  <div class="text-white p-4 max-w-96 mx-auto">
    <h1 class="text-4xl font-semibold text-primary-500 mb-2">Roadmap</h1>
    <h2 class="text-xl max-w-96 text-center text-primary-500">
      Phase 1 - Foundation
    </h2>
    <div>Build game framework</div>
    <div>Add basic game content</div>
    <div>App is owned by creator</div>
    <h2 class="text-xl max-w-96 text-center text-primary-500 mt-4">
      Phase 2 - DAO
    </h2>
    <div>Game is DAO controlled, but creator has majority of voting power</div>
    <div>Accept proposals from the community</div>
    <div>Add more game content and polish from feedback</div>
    <h2 class="text-xl max-w-96 text-center text-primary-500 mt-4">
      Phase 3 - Decentralization
    </h2>
    <div>Creator is contributor, not controller</div>
    <div>Tokenomics to incentivize contributions and good behavior</div>
  </div>
  <div class="text-white p-4 max-w-96 mx-auto">
    <h1 class="text-4xl font-semibold text-primary-500 mb-2">Links</h1>
    <ul class="text-center text-2xl">
      <li class="mb-2">
        <a
          href="https://oc.app/community/cghnf-2qaaa-aaaar-baa6a-cai/?ref=nlzgz-paaaa-aaaaf-acwna-cai"
          target="_blank"
        >
          <MessagesSolid class="inline-block" /> Open Chat
        </a>
      </li>
      <li class="mb-2">
        <a href="https://github.com/edjcase/daoball" target="_blank">
          <GithubSolid class="inline-block" /> Github
        </a>
      </li>
      <li class="mb-2">
        <a href="https://twitter.com/daoventure_game" target="_blank">
          <TwitterSolid class="inline-block" /> Twitter
        </a>
      </li>
    </ul>
  </div>
</div>
