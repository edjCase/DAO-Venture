<script lang="ts">
    import { townStore } from "../../stores/TownStore";
    import TownSkill from "./TownSkill.svelte";

    export let townId: bigint;
    $: towns = $townStore;
    $: town = towns?.find((t) => t.id == townId);
</script>

{#if town}
    <TownSkill name="Woodcutting" skill={town.skills.woodCutting} />
    <TownSkill name="Mining" skill={town.skills.mining} />
    <TownSkill name="Farming" skill={town.skills.farming} />
    <TownSkill name="Carpentry" skill={town.skills.carpentry} />
    <TownSkill name="Masonry" skill={town.skills.masonry} />
{/if}
