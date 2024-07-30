<script lang="ts">
    import { townStore } from "../../stores/TownStore";
    import { userStore } from "../../stores/UserStore";
    import TownFlag from "./TownFlag.svelte";

    $: user = $userStore;
    $: towns = $townStore;

    $: town = towns?.find((t) => t.id === user?.townId);
</script>

{#if town}
    <TownFlag {town} size="md" stats={true} />
{:else}
    <div class="w-10 h-10" />
{/if}
