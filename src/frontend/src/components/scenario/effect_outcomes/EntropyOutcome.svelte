<script lang="ts">
    import { EntropyTeamEffectOutcome } from "../../../ic-agent/declarations/league";
    import { Team } from "../../../ic-agent/declarations/teams";

    export let value: EntropyTeamEffectOutcome;
    export let teams: Team[];

    let absDelta = Math.abs(Number(value.delta));
    let gainOrLoss = value.delta >= 0 ? "+" : "-";

    $: teamName = teams.find((team) => team.id === value.teamId)?.name ?? "";
</script>

<div>
    Team {teamName}
    {gainOrLoss}{absDelta} 🔥
</div>
