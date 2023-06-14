<script>
  import { onMount } from "svelte";
  export let id;

  let game;

  onMount(async () => {
    // const res = await fetch(`/api/games/${id}`);
    // game = await res.json();
    game = {
      title: "Game: " + id,
      description: "Game Description",
    };
  });
</script>

{#if game}
  <h1>{game.title}</h1>
  <p>{game.description}</p>
{/if}
