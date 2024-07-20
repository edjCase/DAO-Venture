<script lang="ts">
  import { Link } from "svelte-routing";
  import { townStore } from "../../stores/TownStore";
  import { Button } from "flowbite-svelte";
  import TeamFlag from "./TeamFlag.svelte";
  import { StarSolid } from "flowbite-svelte-icons";
  import { userStore } from "../../stores/UserStore";
  import { Town } from "../../ic-agent/declarations/main";

  $: towns = $townStore;
  $: user = $userStore;

  let associatedTownId: bigint | undefined;
  $: {
    associatedTownId = user?.membership[0]?.townId;
  }

  let selectedTown: Town | undefined;
  $: selectedTown = towns && towns[0];
</script>

<div class="flex flex-col justify-between">
  <div class="pb-10">
    {#if selectedTown}
      <div class="flex justify-center items-center">
        <div class="text-3xl text-center m-5">{selectedTown.name}</div>
        <div>
          {#if user}
            {#if associatedTownId !== undefined}
              {#if associatedTownId == selectedTown.id}
                <StarSolid size="lg" />
              {/if}
            {/if}
          {/if}
        </div>
      </div>
      <TeamFlag town={selectedTown} size="lg" />
      <blockquote class="mx-auto mb-4 max-w-2xl">
        <div class="mt-5">
          <div class="text-lg town-info-text text-justify">
            {selectedTown.description}
          </div>
        </div>
      </blockquote>
      <div class="flex justify-center">
        <Link to={`/towns/${selectedTown.id.toString()}`}>
          <Button>View Town Page</Button>
        </Link>
      </div>
    {/if}
  </div>
  {#if towns !== undefined}
    <div class="flex flex-wrap justify-around">
      {#each towns as town}
        <div
          class="mb-5 {selectedTown === town ? 'opacity-50' : ''}"
          role="button"
          tabindex="0"
          on:keydown={() => {}}
          on:click={() => (selectedTown = town)}
        >
          <TeamFlag {town} size="md" />
        </div>
      {/each}
    </div>
  {/if}
</div>
