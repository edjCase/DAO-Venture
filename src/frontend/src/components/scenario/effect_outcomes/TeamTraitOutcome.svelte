<script lang="ts">
    import { TeamTraitTeamEffectOutcome } from "../../../ic-agent/declarations/main";
    import { Team, Trait } from "../../../ic-agent/declarations/main";
    import { toJsonString } from "../../../utils/StringUtil";

    export let value: TeamTraitTeamEffectOutcome;
    export let traits: Trait[];
    export let teams: Team[];

    $: teamName = teams.find((team) => team.id === value.teamId)?.name ?? "";

    $: traitName = traits.find((t) => t.id == value.traitId)?.name ?? "";
</script>

Team {teamName}
{#if "add" in value.kind}
    +
{:else if "remove" in value.kind}
    -
{:else}
    NOT IMPLEMENTED TEAM TRAIT KIND: {toJsonString(value.kind)}
{/if}
{traitName}
