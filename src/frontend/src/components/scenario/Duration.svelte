<script lang="ts">
    import { Duration } from "../../ic-agent/declarations/league";

    export let duration: Duration;
</script>

{#if "indefinite" in duration}
    indefinitely
{:else if "matches" in duration}
    for {duration.matches}
    {duration.matches === BigInt(1) ? "match" : "matches"}
{/if}
