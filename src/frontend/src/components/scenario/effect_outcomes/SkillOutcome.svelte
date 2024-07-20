<script lang="ts">
    import { SkillPlayerEffectOutcome } from "../../../ic-agent/declarations/main";
    import { Town } from "../../../ic-agent/declarations/main";
    import { fieldPositionToString } from "../../../models/FieldPosition";
    import { skillToString } from "../../../models/Skill";
    import { toJsonString } from "../../../utils/StringUtil";

    export let value: SkillPlayerEffectOutcome;
    export let towns: Town[];

    let absDelta = Math.abs(Number(value.delta));
    let gainOrLoss = value.delta >= 0 ? "+" : "-";

    $: townName =
        towns.find((town) => town.id === value.position.townId)?.name ?? "";

    $: positionText = fieldPositionToString(value.position.position);
</script>

<div>
    {positionText} for Town {townName} position {positionText}
    {gainOrLoss}{absDelta}
    {skillToString(value.skill)}
    {#if "indefinite" in value.duration}
        indefinitely
    {:else if "matches" in value.duration}
        for {value.duration.matches}
        {value.duration.matches === BigInt(1) ? "match" : "matches"}
    {:else}
        NOT IMPLEMENTED DURATION: {toJsonString(value.duration)}
    {/if}
</div>
