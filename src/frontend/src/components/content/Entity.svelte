<script lang="ts">
  import { Tooltip } from "flowbite-svelte";
  import PixelArtCanvas from "../common/PixelArtCanvas.svelte";
  import { decodeImageToPixels } from "../../utils/PixelUtil";
  import {
    PixelImage,
    UnlockRequirement,
  } from "../../ic-agent/declarations/main";
  import { userStore } from "../../stores/UserStore";
  import { LockSolid } from "flowbite-svelte-icons";

  type Entity = {
    id: string;
    name: string;
    description: string;
    image?: PixelImage;
    unlockRequirement?: UnlockRequirement;
  };
  export let entity: Entity | string;
  export let store: {
    subscribe: (run: (value: Entity[]) => void) => () => void;
  };
  export let entityType: string;
  export let pixelSize: number = 1;

  $: entities = $store;

  $: user = $userStore;

  $: if (typeof entity === "string") {
    let foundEntity = entities?.find((i) => i.id === entity);
    if (foundEntity) {
      entity = foundEntity;
    }
  }

  let isUnlocked = false;
  $: if (typeof entity !== "string") {
    if (
      entity.unlockRequirement === undefined ||
      "none" in entity.unlockRequirement
    ) {
      isUnlocked = true;
    } else if (user) {
      if ("achievementId" in entity.unlockRequirement) {
        isUnlocked = user.data.achievementIds.includes(
          entity.unlockRequirement.achievementId
        );
      }
    }
  }
</script>

<span>
  {#if typeof entity !== "string"}
    <span class="text-xl relative inline-block">
      {#if entity.image}
        <PixelArtCanvas
          layers={[decodeImageToPixels(entity.image, 32, 32)]}
          {pixelSize}
        />
      {:else}
        <span class="p-2">{entity.name}</span>
      {/if}
      {#if !isUnlocked}
        <span
          class="absolute inset-0 flex items-center justify-center bg-black bg-opacity-50"
        >
          <LockSolid size="lg" color="#ffffff" />
        </span>
      {/if}
    </span>
    <Tooltip>
      <div class="text-xl">
        <span class="text-primary-500"> {entity.name}</span> - {entityType}
      </div>
      {#if !isUnlocked}<span class="text-red-500">Not Unlocked</span>{/if}
      <div class="text-md">{entity.description}</div>
    </Tooltip>
  {/if}
</span>
