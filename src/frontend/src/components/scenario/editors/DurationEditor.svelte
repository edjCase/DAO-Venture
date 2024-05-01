<script lang="ts">
    import BigIntInput from "./BigIntInput.svelte";
    import { Duration } from "../../../ic-agent/declarations/league";

    export let value: Duration;
</script>

{#if "matches" in value}
    <BigIntInput bind:value={value.matches} />
{:else if "indefinite" in value}
    <div></div>
{:else}
    NOT IMPLEMENTED : {JSON.stringify(value)}
{/if}
