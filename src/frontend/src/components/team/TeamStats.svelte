<script lang="ts">
    import { TeamStandingInfo } from "../../ic-agent/declarations/league";
    import { Team } from "../../ic-agent/declarations/teams";
    import { teamStore } from "../../stores/TeamStore";

    export let teamId: bigint;

    let team: Team | undefined;
    let standing: TeamStandingInfo | undefined;

    teamStore.subscribe((teams) => {
        team = teams?.find((t) => t.id == teamId);
    });
    teamStore.subscribeTeamStandings((standings) => {
        standing = standings?.find((s) => s.id == teamId);
    });

    let emptyOrValue = (value: number | bigint | undefined) => {
        return value === undefined ? "" : value;
    };

    $: winLossRatio = standing ? `${standing.wins}/${standing.losses}` : "N/A";
</script>

<div>
    <div>Win/Loss: {winLossRatio}</div>
    <div>Energy: {emptyOrValue(team?.energy)}</div>
    <div>Entropy: {emptyOrValue(team?.entropy)}</div>
</div>
