<script lang="ts">
  export let cards: { id: string; title: string; description: string }[];
  export let onSelect: (id: string) => void;
  let selectedId: string | undefined;
</script>

<div class="card-container">
  {#each cards as { id, title, description }, index}
    <div
      class="card"
      class:selected={selectedId === id}
      on:click={() => {
        selectedId = id;
        onSelect(id);
      }}
      on:keypress={() => {}}
      role="button"
      tabindex={index}
    >
      <div class="title">{title}</div>
      <div class="description">{description}</div>
    </div>
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
    background-color: var(--color-bg-dark);
    border-radius: 8px;
    flex: 1;
    cursor: pointer;
    text-align: left;
    width: 400px;
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
