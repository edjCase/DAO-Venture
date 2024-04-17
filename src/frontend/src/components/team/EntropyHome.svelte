<script lang="ts">
    import { teamStore } from "../../stores/TeamStore";
    import { Team } from "../../ic-agent/declarations/league";
    import TeamLogo from "../team/TeamLogo.svelte";

    let teams: Team[] = [];
    let maxEntropy = 0;
    let totalEntropy = 0;
    const entropyMaxThreshold = 20; // TODO

    teamStore.subscribe((t) => {
        if (!t) {
            return;
        }
        teams = t;
        teams.sort((a, b) => Number(b.entropy) - Number(a.entropy));
        maxEntropy = Math.max(...teams.map((team) => Number(team.entropy)));
        totalEntropy = teams.reduce(
            (sum, team) => sum + Number(team.entropy),
            0,
        );
    });

    function getEntropyPercentage(entropy: number): number {
        if (entropy === 0) {
            return 0;
        }
        return (entropy / maxEntropy) * 100;
    }
    $: leagueEntropyPerecentage = (totalEntropy / entropyMaxThreshold) * 100;
</script>

<div class="text-3xl text-center">Entropy</div>
<div>League Entropy: {totalEntropy}</div>
<div>Collapse Threshold: {entropyMaxThreshold}</div>
<div class="total-entropy-bar">
    <div
        class="total-entropy-fill"
        style="width: {leagueEntropyPerecentage}%;"
    ></div>
</div>

{#each teams as team}
    <div class="flex justify-center items-center">
        <div>
            <TeamLogo {team} size="md" />
            <div class="text-lg text-center">
                {team.name}
            </div>
        </div>
        <div class="flex-grow mx-5">
            <div class="entropy-bar">
                <div
                    class="entropy-fill"
                    style="width: {getEntropyPercentage(
                        Number(team.entropy),
                    )}%;"
                ></div>
            </div>
            <div class="text-sm text-center">
                Entropy: {team.entropy}
            </div>
        </div>
    </div>
{/each}

<style>
    .total-entropy-bar {
        width: 100%;
        height: 20px;
        background-color: #f0f0f0;
        border-radius: 10px;
        position: relative;
        margin-bottom: 20px;
    }

    .total-entropy-fill {
        height: 100%;
        background-color: #ff3300;
        border-radius: 10px;
    }

    .loss-threshold {
        position: absolute;
        top: 0;
        bottom: 0;
        width: 2px;
        background-color: #000;
    }

    .entropy-bar {
        width: 100%;
        height: 10px;
        background-color: rgb(0, 119, 255);
        border-radius: 5px;
    }

    .entropy-fill {
        height: 100%;
        background-color: #ff3300;
        border-radius: 5px;
    }
</style>
