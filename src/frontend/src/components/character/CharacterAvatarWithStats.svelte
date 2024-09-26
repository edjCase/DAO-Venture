<script lang="ts">
  import { CharacterWithMetaData } from "../../ic-agent/declarations/main";
  import CharacterAvatar from "../character/CharacterAvatar.svelte";
  import CharacterAttributeIcon from "./CharacterAttributeIcon.svelte";
  import CharacterStatIcon from "./CharacterStatIcon.svelte";

  export let character: CharacterWithMetaData;
  export let pixelSize: number;
  export let tooltips: boolean = false;

  const getValue = (value: bigint | undefined): string =>
    value === undefined ? "" : value.toString();

  $: goldStat = getValue(character.gold);
  $: healthStat = getValue(character.health);
  $: maxHealthStat = getValue(character.maxHealth);
</script>

<div>
  <div class="flex justify-around mb-2">
    <div>
      <CharacterStatIcon kind={{ health: null }} />
      {healthStat}/{maxHealthStat}
    </div>
    <div><CharacterStatIcon kind={{ gold: null }} /> {goldStat}</div>
  </div>
  <div class="flex items-center text-lg">
    <div class="flex flex-col justify-center">
      <CharacterAvatar {pixelSize} {character} {tooltips} />
    </div>
    <div class="flex flex-col justify-center text-xl mr-2">
      <div class="flex items-center">
        <CharacterAttributeIcon value={{ strength: null }} />
        <span>{character.attributes.strength}</span>
      </div>
      <div class="flex items-center">
        <CharacterAttributeIcon value={{ dexterity: null }} />
        <span>{character.attributes.dexterity}</span>
      </div>
    </div>
    <div class="flex flex-col justify-center text-xl">
      <div class="flexl items-center">
        <CharacterAttributeIcon value={{ wisdom: null }} />
        <span>{character.attributes.wisdom}</span>
      </div>
      <div class="flex items-center">
        <CharacterAttributeIcon value={{ charisma: null }} />
        <span>{character.attributes.charisma}</span>
      </div>
    </div>
  </div>
</div>
