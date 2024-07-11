<script lang="ts">
    import { CurrencyTeamEffectOutcome } from "../../../ic-agent/declarations/main";
    import { Team } from "../../../ic-agent/declarations/main";

    export let value: CurrencyTeamEffectOutcome;
    export let teams: Team[];

    let absDelta = Math.abs(Number(value.delta));
    let gainOrLoss = value.delta >= 0 ? "+" : "-";

    $: teamName = teams?.find((team) => team.id === value.teamId)?.name ?? "";
</script>

<div>
    Team {teamName}
    {gainOrLoss}{absDelta} 💰
</div>
