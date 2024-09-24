<script lang="ts">
  import { Navbar } from "flowbite-svelte";
  import { Link } from "svelte-routing";
  import UserMenu from "../user/UserMenu.svelte";
  import CharacterAvatarWithStats from "../character/CharacterAvatarWithStats.svelte";
  import { CharacterWithMetaData } from "../../ic-agent/declarations/main";
  import { currentGameStore } from "../../stores/CurrentGameStore";
  import LoadingButton from "./LoadingButton.svelte";
  import { userStore } from "../../stores/UserStore";
  import { mainAgentFactory } from "../../ic-agent/Main";

  $: currentGame = $currentGameStore;

  let character: CharacterWithMetaData | undefined;
  $: {
    if (currentGame !== undefined) {
      if ("starting" in currentGame.state) {
        character = undefined;
      } else if ("inProgress" in currentGame.state) {
        character = currentGame.state.inProgress.character;
      } else {
        character = currentGame.state.completed.character;
      }
    }
  }

  $: user = $userStore;

  let createGame = async () => {
    let mainAgent = await mainAgentFactory();
    let result = await mainAgent.createGame({});
    if ("ok" in result) {
      currentGameStore.refetch();
    } else {
      console.error("Failed to create game", result);
    }
  };
  let login = async () => {
    await userStore.login();
  };
</script>

<Navbar rounded color="form" class="mb-2">
  <div class="flex-1">
    <UserMenu />
  </div>
  <div class="flex-1">
    <Link to="/">
      <div class="text-center text-4xl text-primary-500">DAO Venture</div>
    </Link>
  </div>
  <div class="flex-1 flex justify-center">
    {#if user !== undefined}
      {#if currentGame === undefined}
        <LoadingButton onClick={createGame}>Play</LoadingButton>
      {:else if character !== undefined}
        <CharacterAvatarWithStats pixelSize={1} {character} />
      {/if}
    {:else}
      <LoadingButton onClick={login}>Login</LoadingButton>
    {/if}
  </div>
</Navbar>
