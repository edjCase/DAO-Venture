<script lang="ts">
  import { ModifyGameContent } from "../../../ic-agent/declarations/main";
  import { decodeImageToPixels } from "../../../utils/PixelUtil";
  import { toJsonString } from "../../../utils/StringUtil";
  import PixelArtCanvas from "../../common/PixelArtCanvas.svelte";
  import EntityView from "./modify_game_content/EntityView.svelte";
  import ModifiersView from "./modify_game_content/ModifiersView.svelte";
  import StatView from "./modify_game_content/StatView.svelte";
  import UnlockRequirementView from "./modify_game_content/UnlockRequirementView.svelte";
  import WeaponView from "./modify_game_content/WeaponView.svelte";

  export let content: ModifyGameContent;
</script>

<div>
  {#if "item" in content}
    <div>Item</div>
    <EntityView entity={content.item} />
    <div>
      <PixelArtCanvas
        pixels={decodeImageToPixels(content.item.image, 16, 16)}
      />
    </div>
    <UnlockRequirementView value={content.item.unlockRequirement} />
  {:else if "trait" in content}
    <div>Trait</div>
    <EntityView entity={content.trait} />
    <div>
      <PixelArtCanvas
        pixels={decodeImageToPixels(content.trait.image, 16, 16)}
      />
    </div>
    <UnlockRequirementView value={content.trait.unlockRequirement} />
  {:else if "image" in content}
    {@const base64 = btoa(
      String.fromCharCode(...new Uint8Array(content.image.data))
    )}
    <!-- TODO support more formats? -->
    {@const mimeType = "image/png"}
    <div>Image</div>
    <div>Id: {content.image.id}</div>
    <div>Kind: PNG</div>
    <div>
      <img src="data:{mimeType};base64,{base64}" alt="to upload" />
    </div>
  {:else if "creature" in content}
    <div>Creature</div>
    <EntityView entity={content.creature} />
    <StatView stats={content.creature} />
    <div>
      Kind:
      {#if "normal" in content.creature.kind}
        Normal
      {:else if "elite" in content.creature.kind}
        Elite
      {:else if "boss" in content.creature.kind}
        Boss
      {:else}
        NOT IMPLEMENTED CREATURE KIND: <pre>{toJsonString(
            content.creature.kind
          )}</pre>
      {/if}
    </div>
    <div>
      Location:
      {#if "common" in content.creature.location}
        Everywhere
      {:else if "zoneIds" in content.creature.location}
        Zones:
        {#each content.creature.location.zoneIds as zoneId}
          {zoneId}
        {/each}
      {:else}
        NOT IMPLEMENTED CREATURE LOCATION: <pre>{toJsonString(
            content.creature.location
          )}</pre>
      {/if}
      <UnlockRequirementView value={content.creature.unlockRequirement} />
    </div>
  {:else if "class" in content}
    <div>Class</div>
    <EntityView entity={content.class} />
    <WeaponView id={content.class.weaponId} />
    <ModifiersView value={content.class.modifiers} />
    <UnlockRequirementView value={content.class.unlockRequirement} />
  {:else if "race" in content}
    <div>Race</div>
    <EntityView entity={content.race} />
    <ModifiersView value={content.race.modifiers} />
    <UnlockRequirementView value={content.race.unlockRequirement} />
  {:else if "zone" in content}
    <div>Zone</div>
    <EntityView entity={content.zone} />
    <UnlockRequirementView value={content.zone.unlockRequirement} />
  {:else if "weapon" in content}
    <div>Weapon</div>
    <EntityView entity={content.weapon} />
    <UnlockRequirementView value={content.weapon.unlockRequirement} />
    <div>Accuracy: {content.weapon.baseStats.accuracy}</div>
    <div>Attacks: {content.weapon.baseStats.attacks}</div>
    <div>Min Damage: {content.weapon.baseStats.minDamage}</div>
    <div>Max Damage: {content.weapon.baseStats.maxDamage}</div>
    <div>Crit Chance: {content.weapon.baseStats.criticalChance}</div>
    <div>Crit Multiplier: {content.weapon.baseStats.criticalMultiplier}</div>
    <div>
      Modifiers:
      {#each content.weapon.baseStats.statModifiers as modifier}
        <div>
          Attribute:
          {#if "attacks" in modifier.attribute}
            Attacks
          {:else if "accuracy" in modifier.attribute}
            Accuracy
          {:else if "damage" in modifier.attribute}
            Damage
          {:else if "minDamage" in modifier.attribute}
            Min Damage
          {:else if "maxDamage" in modifier.attribute}
            Max Damage
          {:else if "criticalChance" in modifier.attribute}
            Crit Chance
          {:else if "criticalMultiplier" in modifier.attribute}
            Crit Multiplier
          {:else}
            NOT IMPLEMENTED WEAPON MODIFIER ATTRIBUTE: <pre>{toJsonString(
                modifier.attribute
              )}</pre>
          {/if}
        </div>
        <div>
          Stat:
          {#if "attack" in modifier.characterStat}
            Attack
          {:else if "defense" in modifier.characterStat}
            Defense
          {:else if "health" in modifier.characterStat}
            Health
          {:else if "magic" in modifier.characterStat}
            Magic
          {:else if "speed" in modifier.characterStat}
            Speed
          {:else if "gold" in modifier.characterStat}
            Gold
          {:else}
            NOT IMPLEMENTED WEAPON MODIFIER CHARACTER STAT: <pre>{toJsonString(
                modifier.characterStat
              )}</pre>
          {/if}
        </div>
        <div>Factor: {modifier.factor}</div>
      {/each}
    </div>
    <div>
      Requirements:
      {#each content.weapon.requirements as requirement}
        <div>{requirement}</div>
      {/each}
    </div>
  {:else if "achievement" in content}
    <div>Achievement</div>
    <EntityView entity={content.achievement} />
  {:else if "scenario" in content}
    <div>Scenario</div>
    <EntityView entity={content.scenario} />
    <div>
      Data:
      {#each content.scenario.data as data}
        <div>{toJsonString(data)}</div>
      {/each}
    </div>
    <div>Category: {toJsonString(content.scenario.category)}</div>
    <div>Image Id: {content.scenario.imageId}</div>
    <div>Location: {toJsonString(content.scenario.location)}</div>
    <div>
      Paths:
      {#each content.scenario.paths as path}
        <div>{toJsonString(path)}</div>
      {/each}
    </div>
    <UnlockRequirementView value={content.scenario.unlockRequirement} />
  {:else}
    NOT IMPLEMENTED GAME CONTENT VIEW: <pre>{toJsonString(content)}</pre>
  {/if}
</div>
