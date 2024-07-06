<script lang="ts">
    import { Label } from "flowbite-svelte";
    import { ProportionalBidScenario } from "../../../ic-agent/declarations/main";
    import { toJsonString } from "../../../utils/StringUtil";
    import { skillToString } from "../../../models/Skill";

    export let scenario: ProportionalBidScenario;
</script>

<Label>Prize</Label>
{scenario.prize.amount}
{#if "skill" in scenario.prize.kind}
    {#if "chosen" in scenario.prize.kind.skill.skill}
        {skillToString(scenario.prize.kind.skill.skill.chosen)}
    {:else if "random" in scenario.prize.kind.skill.skill}
        random skill
    {:else}
        NOT IMPLEMENTED PRIZE: {toJsonString(scenario.prize.kind)}
    {/if}
    for
    {#if "matches" in scenario.prize.kind.skill.duration}
        {scenario.prize.kind.skill.duration.matches}
        {scenario.prize.kind.skill.duration.matches === BigInt(1)
            ? "match"
            : "matches"}
    {:else if "indefinate" in scenario.prize.kind.skill.duration}
        <div></div>
    {:else}
        NOT IMPLEMENTED PRIZE: {toJsonString(scenario.prize.kind)}
    {/if}
{:else}
    NOT IMPLEMENTED PRIZE: {toJsonString(scenario.prize.kind)}
{/if}
