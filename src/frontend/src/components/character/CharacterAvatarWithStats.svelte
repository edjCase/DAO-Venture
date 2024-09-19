<script lang="ts">
  import { CharacterWithMetaData } from "../../ic-agent/declarations/main";
  import CharacterAvatar from "../character/CharacterAvatar.svelte";
  import CharacterAttributeIcon from "./CharacterAttributeIcon.svelte";
  import CharacterStatIcon from "./CharacterStatIcon.svelte";

  export let size: "xs" | "sm" | "md" | "lg" | "xl";
  export let character: CharacterWithMetaData;

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
    <CharacterAvatar {size} {character} />
  </div>
  <div class="flex justify-center m-2 border border-gray-300 rounded">
    <div>
      {character.attributes.strength}
      <CharacterAttributeIcon value={{ strength: null }} />
    </div>
    <div>
      {character.attributes.dexterity}
      <CharacterAttributeIcon value={{ dexterity: null }} />
    </div>
    <div>
      {character.attributes.wisdom}
      <CharacterAttributeIcon value={{ wisdom: null }} />
    </div>
    <div>
      {character.attributes.charisma}
      <CharacterAttributeIcon value={{ charisma: null }} />
    </div>
  </div>
</div>
