<script lang="ts">
    import { townStore } from "../../stores/TownStore";
    import { userStore } from "../../stores/UserStore";
    import TeamFlag from "./TeamFlag.svelte";

    $: user = $userStore;
    $: towns = $townStore;

    $: town = towns?.find((t) => t.id === user?.membership[0]?.townId);
</script>

{#if town}
    <TeamFlag {town} size="xs" stats={true} />
{:else}
    <div class="w-10 h-10" />
{/if}
