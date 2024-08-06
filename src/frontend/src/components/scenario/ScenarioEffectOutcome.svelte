<script lang="ts">
    import { EffectOutcome } from "../../ic-agent/declarations/main";
    import { Town } from "../../ic-agent/declarations/main";
    import { toJsonString } from "../../utils/StringUtil";
    import ResourceOutcome from "./effect_outcomes/ResourceOutcome.svelte";

    export let outcome: EffectOutcome;
    export let towns: Town[];
</script>

<div>
    {#if "resource" in outcome}
        <ResourceOutcome value={outcome.resource} {towns} />
    {:else}
        NOT IMPLEMENTED: {toJsonString(outcome)}
    {/if}
</div>
