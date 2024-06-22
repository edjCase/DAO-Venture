<script lang="ts">
    import { SkillPlayerEffectOutcome } from "../../../ic-agent/declarations/league";
    import { Team } from "../../../ic-agent/declarations/teams";
    import { fieldPositionToString } from "../../../models/FieldPosition";
    import { skillToString } from "../../../models/Skill";
    import { toJsonString } from "../../../utils/StringUtil";

    export let value: SkillPlayerEffectOutcome;
    export let teams: Team[];

    let absDelta = Math.abs(Number(value.delta));
    let gainOrLoss = value.delta >= 0 ? "+" : "-";

    $: teamName =
        teams.find((team) => team.id === value.target.teamId)?.name ?? "";

    $: positionText = fieldPositionToString(value.target.position);
</script>

<div>
    {positionText} for Team {teamName} position {positionText}
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
