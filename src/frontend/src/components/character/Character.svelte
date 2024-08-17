<script lang="ts">
  import { CharacterState } from "../../ic-agent/declarations/main";
  import CharacterInventory from "./CharacterInventory.svelte";
  import CharacterTraits from "./CharacterTraits.svelte";

  export let character: CharacterState;
</script>

<div class="text-center text-3xl p-6">
  <div class="mb-5 w-full">
    <div>Items:</div>
    <CharacterInventory items={character.items} />
  </div>
  <div class="mb-5 w-full">
    <div>Traits:</div>
    <CharacterTraits traits={character.traits} />
  </div>
</div>
