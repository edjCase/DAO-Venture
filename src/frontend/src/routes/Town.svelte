<script lang="ts">
  import { townStore } from "../stores/TownStore";
  import TownPage from "../components/town/TownPage.svelte";
  import { Town } from "../ic-agent/declarations/main";

  export let townIdString: string;

  let town: Town | undefined;
  townStore.subscribe((towns) => {
    town = towns?.find((t) => t.id.toString() === townIdString);
  });
</script>

{#if town}
  <TownPage {town} />
{/if}
