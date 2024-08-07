<script lang="ts">
    import { townStore } from "../../stores/TownStore";
    import { toJsonString } from "../../utils/StringUtil";

    export let townId: bigint;

    $: towns = $townStore;
    $: town = towns?.find((t) => t.id == townId);
</script>

{#if town !== undefined}
    {#each town.jobs as job}
        <div>
            {#if "explore" in job}
                <div>Explore</div>
                <div>Location: {job.explore.locationId}</div>
            {:else}
                NOT IMPLEMENTED JOB: {toJsonString(job)}
            {/if}
        </div>
    {/each}
{/if}
