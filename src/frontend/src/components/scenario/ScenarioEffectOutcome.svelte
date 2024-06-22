<script lang="ts">
    import { EffectOutcome } from "../../ic-agent/declarations/league";
    import { Team, Trait } from "../../ic-agent/declarations/teams";
    import { toJsonString } from "../../utils/StringUtil";
    import EnergyOutcome from "./effect_outcomes/EnergyOutcome.svelte";
    import EntropyOutcome from "./effect_outcomes/EntropyOutcome.svelte";
    import SkillOutcome from "./effect_outcomes/SkillOutcome.svelte";
    import TeamTraitOutcome from "./effect_outcomes/TeamTraitOutcome.svelte";

    export let outcome: EffectOutcome;
    export let teams: Team[];
    export let traits: Trait[];
</script>

<div>
    {#if "energy" in outcome}
        <EnergyOutcome value={outcome.energy} {teams} />
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
