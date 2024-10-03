<script lang="ts">
  import BottomNavigation from "./components/common/BottomNavigation.svelte";
</script>

<main class="max-w-xl mx-auto bg-gray-900 px-2 py-4">
  <slot />
  <BottomNavigation />
</main>

<style lang="postcss">
  main {
    height: calc(100vh - 4rem);
    background-color: #000000;
    background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='28' height='49' viewBox='0 0 28 49'%3E%3Cg fill-rule='evenodd'%3E%3Cg id='hexagons' fill='%2322c55e' fill-opacity='0.04' fill-rule='nonzero'%3E%3Cpath d='M13.99 9.25l13 7.5v15l-13 7.5L1 31.75v-15l12.99-7.5zM3 17.9v12.7l10.99 6.34 11-6.35V17.9l-11-6.34L3 17.9zM0 15l12.98-7.5V0h-2v6.35L0 12.69v2.3zm0 18.5L12.98 41v8h-2v-6.85L0 35.81v-2.3zM15 0v7.5L27.99 15H28v-2.31h-.01L17 6.35V0h-2zm0 49v-8l12.99-7.5H28v2.31h-.01L17 42.15V49h-2z'/%3E%3C/g%3E%3C/g%3E%3C/svg%3E");

    overflow-y: auto;

    /* Custom scrollbar */
    scrollbar-width: thin;
    scrollbar-color: #4ade80 #1f2937;
  }
</style>
