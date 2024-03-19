<script lang="ts">
    import { Button } from "flowbite-svelte";
    import Countdown from "../components/common/Countdown.svelte";
    import { scenarioStore } from "../stores/ScenarioStore";
    import { scheduleStore } from "../stores/ScheduleStore";
    import { nanosecondsToDate } from "../utils/DateUtils";
    import { navigate } from "svelte-routing";
    import { teamStore } from "../stores/TeamStore";
    import { Scenario, TeamWithId } from "../ic-agent/declarations/league";
    import TeamLogo from "../components/team/TeamLogo.svelte";

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

    let nextMatchGroupDate: Date | undefined;
    let matchGroupInProgress: bigint | undefined;
    let activeScenarios: Scenario[] = [];
    let topTeams: TopTeams | undefined;

    scheduleStore.subscribeMatchGroups((matchGroups) => {
        let now = new Date();
        nextMatchGroupDate = undefined;
        matchGroupInProgress = undefined;
        for (let matchGroup of matchGroups) {
            if (matchGroup.state == "InProgress") {
                matchGroupInProgress = matchGroup.id;
                break;
            }
            let date = nanosecondsToDate(matchGroup.time);
            if (date > now) {
                nextMatchGroupDate = date;
                break;
            }
        }
    });

    scenarioStore.subscribe((scenarios) => {
        activeScenarios = scenarios.filter(
            (scenario) => "inProgress" in scenario.state,
        );
    });
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

<div>
    <div class="text-3xl text-center">Season 0 - The Awakening</div>
    {#if matchGroupInProgress}
        <Button on:click={() => navigate("/season")}>Match LIVE! =></Button>
    {:else if nextMatchGroupDate}
        <div class="text-xl text-center">
            Next Matches in <Countdown date={nextMatchGroupDate} />
        </div>
        <div class="flex justify-center">
            <Button on:click={() => navigate("/season")}>
                Make your predictions
            </Button>
        </div>
    {:else}
        <div class="text-xl text-center">No upcoming matches</div>
    {/if}
    <hr class="my-5" />
    <div>
        <div class="text-3xl text-center mb-5">Scenarios</div>
        {#if activeScenarios.length == 0}
            <div class="text-xl text-center">Next scenario in ???</div>
        {:else}
            <div class="flex flex-col items-center">
                {#each activeScenarios as scenario}
                    <Button on:click={() => navigate("/scenarios")}>
                        {scenario.title}
                    </Button>
                {/each}
            </div>
        {/if}
        <div class="flex justify-center"></div>
    </div>
    {#if topTeams}
        <hr class="my-5" />
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
                <Button on:click={() => navigate("/teams")}
                    >View All Teams</Button
                >
            </div>
        </div>
    {/if}
</div>
