<script lang="ts">
    import { teamStore } from "../../stores/TeamStore";

    export let teamId: bigint;

    let wins: bigint | undefined;
    let losses: bigint | undefined;
    let entropy: bigint | undefined;
    let energy: bigint | undefined;

    teamStore.subscribe((teams) => {
        const team = teams?.find((t) => t.id == teamId);
        if (team) {
            entropy = team.entropy;
        } else {
            entropy = undefined;
        }
    });
    teamStore.subscribeTeamStandings((standings) => {
        const standing = standings?.find((s) => s.id == teamId);
        if (standing) {
            wins = standing.wins;
            losses = standing.losses;
        } else {
            wins = undefined;
            losses = undefined;
        }
    });

    let emptyOrValue = (value: number | bigint | undefined) => {
        return value === undefined ? "" : value;
    };
</script>

<div>
    <div>Win/Loss: {emptyOrValue(wins)}/{emptyOrValue(losses)}</div>
    <div>Energy: {emptyOrValue(energy)}</div>
    <div>Entropy: {emptyOrValue(entropy)}</div>
</div>
