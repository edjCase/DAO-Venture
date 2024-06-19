<script lang="ts">
    import {
        Duration,
        EffectOutcome,
        TargetPositionInstance,
        TeamTraitTeamEffectOutcome,
    } from "../../ic-agent/declarations/league";
    import { Team, Trait } from "../../ic-agent/declarations/teams";
    import { fieldPositionToString } from "../../models/FieldPosition";
    import { skillToString } from "../../models/Skill";
    import { toJsonString } from "../../utils/StringUtil";

    export let outcome: EffectOutcome;
    export let teams: Team[];
    export let traits: Trait[];

    const getGainOrLossOutcomeText = (
        prefix: string,
        value: bigint | number,
        suffix: string,
    ) => {
        if (typeof value === "bigint") {
            value = Number(value);
        }
        let absValue = Math.abs(value);
        let gainOrLoss = value >= 0 ? "+" : "-";
        return `${prefix}: ${gainOrLoss}${absValue} ${suffix}`;
    };

    const getTeamName = (teamId: bigint) => {
        return teams.find((team) => team.id === teamId)?.name ?? "Unknown";
    };

    const getTraitName = (traitId: string) => {
        return traits.find((t) => t.id == traitId)?.name ?? "Unknown";
    };

    const getPositionText = (position: TargetPositionInstance) => {
        let positionText = fieldPositionToString(position.position);
        return positionText + " for Team " + getTeamName(position.teamId);
    };

    const getDurationText = (duration: Duration) => {
        if ("indefinite" in duration) {
            return "indefinitely";
        }
        if ("matches" in duration) {
            return `for ${duration.matches} ${duration.matches === BigInt(1) ? "match" : "matches"}`;
        }
    };

    const getTeamTrait = (teamTrait: TeamTraitTeamEffectOutcome) => {
        let teamName = getTeamName(teamTrait.teamId);
        let traitName = getTraitName(teamTrait.traitId);
        let prefix = "";
        if ("add" in teamTrait.kind) {
            prefix = "+";
        } else if ("remove" in teamTrait.kind) {
            prefix = "-";
        } else {
            prefix =
                "NOT IMPLEMENTED TEAM TRAIT KIND: " +
                toJsonString(teamTrait.kind);
        }
        return `${teamName} ${prefix}${traitName}`;
    };
</script>

<div>
    {#if "energy" in outcome}
        {getGainOrLossOutcomeText(
            getTeamName(outcome.energy.teamId),
            outcome.energy.delta,
            "💰",
        )}
    {:else if "entropy" in outcome}
        {getGainOrLossOutcomeText(
            getTeamName(outcome.entropy.teamId),
            outcome.entropy.delta,
            "🔥",
        )}
    {:else if "skill" in outcome}
        {getGainOrLossOutcomeText(
            getPositionText(outcome.skill.target),
            outcome.skill.delta,
            `'${skillToString(outcome.skill.skill)}' skill ${getDurationText(outcome.skill.duration)}`,
        )}
    {:else if "teamTrait" in outcome}
        {getTeamTrait(outcome.teamTrait)}
    {:else}
        NOT IMPLEMENTED: {toJsonString(outcome)}
    {/if}
</div>
