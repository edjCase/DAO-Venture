<script lang="ts">
    import { Button } from "flowbite-svelte";
    import { navigate } from "svelte-routing";
    import { teamStore } from "../../stores/TeamStore";
    import { TeamWithId } from "../../ic-agent/declarations/league";
    import TeamLogo from "../team/TeamLogo.svelte";
    interface TopTeams {
        mostWins: {
            team: TeamWithId;
            wins: number;
        };
        mostEnergy: {
            team: TeamWithId;
            energy: bigint;
        };
        leastEntropy: {
            team: TeamWithId;
            entropy: bigint;
        };
    }

    let topTeams: TopTeams | undefined;
    teamStore.subscribe((teams) => {
        if (!teams || teams.length < 3) {
            return;
        }
        // TODO
        topTeams = {
            mostWins: {
                team: teams[0],
                wins: 1,
            },
            mostEnergy: {
                team: teams[1],
                energy: teams[1].energy,
            },
            leastEntropy: {
                team: teams[2],
                entropy: teams[2].entropy,
            },
        };
    });
</script>

{#if topTeams !== undefined}
    <div>
        <div class="text-3xl text-center p-5">Top Teams</div>
        <div class="flex items-center">
            <div class="flex-1">
                <div class="text-lg text-center">Most Wins</div>
                <TeamLogo team={topTeams.mostWins.team} size="md" />
                <div class="text-lg text-center">
                    {topTeams.mostWins.team.name}
                </div>
            </div>
            <div class="flex-1">
                <div class="text-lg text-center">Most Energy</div>
                <TeamLogo team={topTeams.mostEnergy.team} size="md" />
                <div class="text-lg text-center">
                    {topTeams.mostEnergy.team.name}
                </div>
            </div>
            <div class="flex-1">
                <div class="text-lg text-center">Least Entropy</div>
                <TeamLogo team={topTeams.leastEntropy.team} size="md" />
                <div class="text-lg text-center">
                    {topTeams.leastEntropy.team.name}
                </div>
            </div>
        </div>
        <div class="flex justify-center m-5">
            <Button on:click={() => navigate("/teams")}>View All Teams</Button>
        </div>
    </div>
{/if}
