<script lang="ts">
    import { EffectOutcome } from "../../ic-agent/declarations/main";
    import { Town, Trait } from "../../ic-agent/declarations/main";
    import { toJsonString } from "../../utils/StringUtil";
    import CurrencyOutcome from "./effect_outcomes/CurrencyOutcome.svelte";
    import EntropyOutcome from "./effect_outcomes/EntropyOutcome.svelte";
    import SkillOutcome from "./effect_outcomes/SkillOutcome.svelte";
    import TownTraitOutcome from "./effect_outcomes/TownTraitOutcome.svelte";

    export let outcome: EffectOutcome;
    export let towns: Town[];
    export let traits: Trait[];
</script>

<div>
    {#if "currency" in outcome}
        <CurrencyOutcome value={outcome.currency} {towns} />
    {:else if "entropy" in outcome}
        <EntropyOutcome value={outcome.entropy} {towns} />
    {:else if "skill" in outcome}
        <SkillOutcome value={outcome.skill} {towns} />
    {:else if "townTrait" in outcome}
        <TownTraitOutcome value={outcome.townTrait} {traits} {towns} />
    {:else}
        NOT IMPLEMENTED: {toJsonString(outcome)}
    {/if}
</div>
