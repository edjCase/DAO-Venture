<script lang="ts">
  import { CharacterWithMetaData } from "../../ic-agent/declarations/main";
  import CharacterAvatar from "../character/CharacterAvatar.svelte";
  import CharacterAttributeIcon from "./CharacterAttributeIcon.svelte";
  import CharacterStatIcon from "./CharacterStatIcon.svelte";

  export let character: CharacterWithMetaData;
  export let pixelSize: number;

  const getValue = (value: bigint | undefined): string =>
    value === undefined ? "" : value.toString();

  $: goldStat = getValue(character.gold);
  $: healthStat = getValue(character.health);
  $: maxHealthStat = getValue(character.maxHealth);
</script>

<div>
  <div class="flex justify-around">
    <div><CharacterStatIcon kind={{ gold: null }} /> {goldStat}</div>
    <div>
      <CharacterStatIcon kind={{ health: null }} />
      {healthStat}/{maxHealthStat}
    </div>
  </div>
  <div class="flex justify-center m-2 border border-gray-300 rounded">
    <CharacterAvatar {pixelSize} {character} />
  </div>
  <div class="flex justify-center m-2 gap-2">
    <div class="flex flex-col items-center border border-gray-300 rounded">
      <CharacterAttributeIcon value={{ strength: null }} />
      <span class="text-sm">{character.attributes.strength}</span>
    </div>
    <div class="flex flex-col items-center border border-gray-300 rounded">
      <CharacterAttributeIcon value={{ dexterity: null }} />
      <span class="text-sm">{character.attributes.dexterity}</span>
    </div>
    <div class="flex flex-col items-center border border-gray-300 rounded">
      <CharacterAttributeIcon value={{ wisdom: null }} />
      <span class="text-sm">{character.attributes.wisdom}</span>
    </div>
    <div class="flex flex-col items-center border border-gray-300 rounded">
      <CharacterAttributeIcon value={{ charisma: null }} />
      <span class="text-sm">{character.attributes.charisma}</span>
    </div>
  </div>
</div>
