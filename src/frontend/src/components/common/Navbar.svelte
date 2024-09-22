<script lang="ts">
  import { Navbar } from "flowbite-svelte";
  import { Link } from "svelte-routing";
  import UserMenu from "../user/UserMenu.svelte";
  import CharacterAvatarWithStats from "../character/CharacterAvatarWithStats.svelte";
  import { CharacterWithMetaData } from "../../ic-agent/declarations/main";
  import { currentGameStore } from "../../stores/CurrentGameStore";

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
  <div class="flex-1 justify-center">
    {#if character === undefined}
      <div></div>
    {:else}
      <CharacterAvatarWithStats pixelSize={1} {character} />
    {/if}
  </div>
</Navbar>
