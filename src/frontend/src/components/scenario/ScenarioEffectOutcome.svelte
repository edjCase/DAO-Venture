<script lang="ts">
    import { EffectOutcome } from "../../ic-agent/declarations/main";
    import { Town } from "../../ic-agent/declarations/main";
    import { toJsonString } from "../../utils/StringUtil";
    import ResourceOutcome from "./effect_outcomes/ResourceOutcome.svelte";
    import EntropyOutcome from "./effect_outcomes/EntropyOutcome.svelte";

    export let outcome: EffectOutcome;
    export let towns: Town[];
</script>

<div>
    {#if "resource" in outcome}
        <ResourceOutcome value={outcome.resource} {towns} />
    {:else if "entropy" in outcome}
        <EntropyOutcome value={outcome.entropy} {towns} />
    {:else}
        NOT IMPLEMENTED: {toJsonString(outcome)}
    {/if}
</div>
