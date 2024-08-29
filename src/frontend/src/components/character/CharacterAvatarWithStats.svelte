<script lang="ts">
  import { CharacterWithMetaData } from "../../ic-agent/declarations/main";
  import CharacterAvatar from "../character/CharacterAvatar.svelte";
  import Icon from "./Icon.svelte";

  export let size: "xs" | "sm" | "md" | "lg" | "xl";
  export let character: CharacterWithMetaData;

  const getValue = (value: bigint | undefined): string =>
    value === undefined ? "" : value.toString();

  $: goldStat = getValue(character?.gold);
  $: healthStat = getValue(character?.health);
  $: maxHealthStat = getValue(character?.maxHealth);
  $: attackStat = getValue(character?.attack);
  $: defenseStat = getValue(character?.defense);
  $: speedStat = getValue(character?.speed);
  $: magicStat = getValue(character?.magic);
</script>

<div>
  <div class="flex justify-around">
    <div><Icon kind={{ gold: null }} /> {goldStat}</div>
    <div><Icon kind={{ health: null }} /> {healthStat}/{maxHealthStat}</div>
  </div>
  <div class="flex justify-center m-2 border border-gray-300 rounded">
    <CharacterAvatar {size} {character} />
  </div>
  <div class="flex justify-around">
    <div><Icon kind={{ attack: null }} /> {attackStat}</div>
    <div><Icon kind={{ defense: null }} /> {defenseStat}</div>
    <div><Icon kind={{ speed: null }} /> {speedStat}</div>
    <div><Icon kind={{ magic: null }} /> {magicStat}</div>
  </div>
</div>
