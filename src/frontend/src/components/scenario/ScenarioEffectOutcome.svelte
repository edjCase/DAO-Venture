<script lang="ts">
    import { EffectOutcome } from "../../ic-agent/declarations/main";
    import { Town } from "../../ic-agent/declarations/main";
    import { toJsonString } from "../../utils/StringUtil";
    import CurrencyOutcome from "./effect_outcomes/CurrencyOutcome.svelte";
    import EntropyOutcome from "./effect_outcomes/EntropyOutcome.svelte";

    export let outcome: EffectOutcome;
    export let towns: Town[];
</script>

<div>
    {#if "currency" in outcome}
        <CurrencyOutcome value={outcome.currency} {towns} />
    {:else if "entropy" in outcome}
        <EntropyOutcome value={outcome.entropy} {towns} />
    {:else}
        NOT IMPLEMENTED: {toJsonString(outcome)}
    {/if}
</div>
