<script lang="ts">
    import { worldStore } from "../../stores/WorldStore";
    import { townStore } from "../../stores/TownStore";
    import HexGrid from "../common/HexGrid.svelte";

    $: towns = $townStore;
    $: world = $worldStore;
</script>

<HexGrid
    gridData={[
        { coord: { q: 0, r: 0 }, value: 0 },
        { coord: { q: 0, r: -1 }, value: 1 },
        { coord: { q: 1, r: -1 }, value: 2 },
        { coord: { q: 1, r: 0 }, value: 3 },
        { coord: { q: 0, r: 1 }, value: 4 },
        { coord: { q: -1, r: 1 }, value: 5 },
        { coord: { q: -1, r: 0 }, value: 6 },

        { coord: { q: 0, r: -2 }, value: 7 },
        { coord: { q: 1, r: -2 }, value: 8 },
        { coord: { q: 2, r: -2 }, value: 9 },
        { coord: { q: 2, r: -1 }, value: 10 },
        { coord: { q: 2, r: 0 }, value: 11 },
        { coord: { q: 1, r: 1 }, value: 12 },
        { coord: { q: 0, r: 2 }, value: 13 },
        { coord: { q: -1, r: 2 }, value: 14 },
        { coord: { q: -2, r: 2 }, value: 15 },
        { coord: { q: -2, r: 1 }, value: 16 },
        { coord: { q: -2, r: 0 }, value: 17 },
        { coord: { q: -1, r: -1 }, value: 18 },
        { coord: { q: 0, r: -3 }, value: 19 },

        { coord: { q: 1, r: -3 }, value: 20 },
        { coord: { q: 2, r: -3 }, value: 21 },
        { coord: { q: 3, r: -3 }, value: 22 },
        { coord: { q: 3, r: -2 }, value: 23 },
        { coord: { q: 3, r: -1 }, value: 24 },
        { coord: { q: 3, r: 0 }, value: 25 },
        { coord: { q: 2, r: 1 }, value: 26 },
        { coord: { q: 1, r: 2 }, value: 27 },
        { coord: { q: 0, r: 3 }, value: 28 },
        { coord: { q: -1, r: 3 }, value: 29 },
        { coord: { q: -2, r: 3 }, value: 30 },
        { coord: { q: -3, r: 3 }, value: 31 },
        { coord: { q: -3, r: 2 }, value: 32 },
        { coord: { q: -3, r: 1 }, value: 33 },
        { coord: { q: -3, r: 0 }, value: 34 },
        { coord: { q: -2, r: -1 }, value: 35 },
        { coord: { q: -1, r: -2 }, value: 36 },

        { coord: { q: 0, r: -4 }, value: 37 },
        { coord: { q: 1, r: -4 }, value: 38 },
        { coord: { q: 2, r: -4 }, value: 39 },
        { coord: { q: 3, r: -4 }, value: 40 },
        { coord: { q: 4, r: -4 }, value: 41 },
        { coord: { q: 4, r: -3 }, value: 42 },
        { coord: { q: 4, r: -2 }, value: 43 },
        { coord: { q: 4, r: -1 }, value: 44 },
        { coord: { q: 4, r: 0 }, value: 45 },
        { coord: { q: 3, r: 1 }, value: 46 },
        { coord: { q: 2, r: 2 }, value: 47 },
        { coord: { q: 1, r: 3 }, value: 48 },
        { coord: { q: 0, r: 4 }, value: 49 },
        { coord: { q: -1, r: 4 }, value: 50 },
        { coord: { q: -2, r: 4 }, value: 51 },
        { coord: { q: -3, r: 4 }, value: 52 },
        { coord: { q: -4, r: 4 }, value: 53 },
        { coord: { q: -4, r: 3 }, value: 54 },
        { coord: { q: -4, r: 2 }, value: 55 },
        { coord: { q: -4, r: 1 }, value: 56 },
        { coord: { q: -4, r: 0 }, value: 57 },
        { coord: { q: -3, r: -1 }, value: 58 },
        { coord: { q: -2, r: -2 }, value: 59 },
        { coord: { q: -1, r: -3 }, value: 60 },
    ]}
/>
