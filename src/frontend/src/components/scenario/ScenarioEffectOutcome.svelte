<script lang="ts">
    import { EffectOutcome } from "../../ic-agent/declarations/main";
    import { Team, Trait } from "../../ic-agent/declarations/main";
    import { toJsonString } from "../../utils/StringUtil";
    import CurrencyOutcome from "./effect_outcomes/CurrencyOutcome.svelte";
    import EntropyOutcome from "./effect_outcomes/EntropyOutcome.svelte";
    import SkillOutcome from "./effect_outcomes/SkillOutcome.svelte";
    import TeamTraitOutcome from "./effect_outcomes/TeamTraitOutcome.svelte";

    export let outcome: EffectOutcome;
    export let teams: Team[];
    export let traits: Trait[];
</script>

<div>
    {#if "currency" in outcome}
        <CurrencyOutcome value={outcome.currency} {teams} />
    {:else if "entropy" in outcome}
        <EntropyOutcome value={outcome.entropy} {teams} />
    {:else if "skill" in outcome}
        <SkillOutcome value={outcome.skill} {teams} />
    {:else if "teamTrait" in outcome}
        <TeamTraitOutcome value={outcome.teamTrait} {traits} {teams} />
    {:else}
        NOT IMPLEMENTED: {toJsonString(outcome)}
    {/if}
</div>
