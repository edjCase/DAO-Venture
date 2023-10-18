<script lang="ts">
  export let cards: { id: number; title: string; description: string }[];
  export let onSelect: (id: number) => void;
  let selectedId = -1;
</script>

<div class="card-container">
  {#each cards as { id, title, description }}
    <button
      class="card"
      class:selected={selectedId === id}
      on:click={() => {
        selectedId = id;
        onSelect(id);
      }}
    >
      <div class="title">{title}</div>
      <div class="description">{description}</div>
    </button>
  {/each}
</div>

<style>
  .card-container {
    display: flex;
    gap: 16px;
  }
  .card {
    border: 1px solid #ddd;
    padding: 16px;
    background-color: var(--color-bg);
    border-radius: 8px;
    flex: 1;
    cursor: pointer;
    text-align: left;
    width: 100%;
    font-size: 1em;
    color: var(--color-text);
  }
  .card.selected {
    background-color: #e0f7fa;
    border-color: #00838f;
    color: black;
  }

  .title {
    font-weight: bold;
  }
</style>
