<script lang="ts">
    import { scheduleStore } from "../../stores/ScheduleStore";
    import TeamStandings from "../team/TeamStandings.svelte";
    import SeasonWinners from "./SeasonWinners.svelte";
    import MatchGroup from "../match/MatchGroup.svelte";
    import {
        CompletedMatchGroup,
        InProgressMatchGroup,
        InProgressSeasonMatchGroupVariant,
        ScheduledMatchGroup,
        SeasonStatus,
    } from "../../ic-agent/declarations/main";
    import { onDestroy } from "svelte";
    import { toJsonString } from "../../utils/StringUtil";
    import SectionWithOverview from "../common/SectionWithOverview.svelte";

    let seasonStatus: SeasonStatus | undefined;
    let lastMatchGroup: CompletedMatchGroup | undefined;
    let nextOrCurrentMatchGroup:
        | { scheduled: ScheduledMatchGroup }
        | { inProgress: InProgressMatchGroup }
        | undefined;
    let nextOrCurrentMatchGroupIndex: number | undefined;

    scheduleStore.subscribeStatus((status) => {
        seasonStatus = status;
    });

    scheduleStore.subscribeMatchGroups(
        (matchGroups: InProgressSeasonMatchGroupVariant[]) => {
            lastMatchGroup = matchGroups.findLast(
                (mg) => "completed" in mg,
            )?.completed;
            nextOrCurrentMatchGroup = matchGroups.find(
                (mg) => "scheduled" in mg || "inProgress" in mg,
            );
            nextOrCurrentMatchGroupIndex = matchGroups.findIndex(
                (mg) => mg === nextOrCurrentMatchGroup,
            );
        },
    );
    // TODO handle this better?
    const interval = setInterval(() => {
        scheduleStore.refetch();
    }, 5000);
    onDestroy(() => {
        clearInterval(interval);
    });
</script>

{#if seasonStatus}
    {#if "notStarted" in seasonStatus}
        <div class="text-center text-3xl font-bold my-4">
            Season Not Started
        </div>
    {:else if "completed" in seasonStatus}
        {#if "success" in seasonStatus.completed.outcome}
            <SeasonWinners
                championTeamId={seasonStatus.completed.outcome.success
                    .championTeamId}
                runnerUpTeamId={seasonStatus.completed.outcome.success
                    .runnerUpTeamId}
            />

            <div class="flex flex-wrap justify-evenly gap-2">
                <div class="teams">
                    <TeamStandings completedSeason={seasonStatus.completed} />
                </div>
            </div>
        {:else}
            Season failed
        {/if}
    {:else if "inProgress" in seasonStatus}
        {#if nextOrCurrentMatchGroup}
            <SectionWithOverview title="Matches">
                <div slot="details">
                    <section class="p-2">
                        <div class="bg-gray-700 p-4 rounded-lg shadow mb-2">
                            {#if "scheduled" in nextOrCurrentMatchGroup}
                                <h3 class="text-xl font-semibold mb-2">
                                    Predictions
                                </h3>
                                <ul
                                    class="list-disc list-inside text-sm space-y-1"
                                >
                                    <li>
                                        Make your mark by <strong
                                            >predicting match outcomes</strong
                                        >, competing with the community for
                                        points and prestige
                                    </li>
                                </ul>
                            {:else if "inProgress" in nextOrCurrentMatchGroup}
                                <h3 class="text-xl font-semibold mb-2">
                                    Live matches
                                </h3>
                                <ul
                                    class="list-disc list-inside text-sm space-y-1"
                                >
                                    <li>TODO</li>
                                </ul>
                            {/if}
                        </div>
                    </section>
                </div>
                {#if nextOrCurrentMatchGroup && nextOrCurrentMatchGroupIndex !== undefined}
                    <MatchGroup
                        matchGroupId={nextOrCurrentMatchGroupIndex}
                        matchGroup={nextOrCurrentMatchGroup}
                        {lastMatchGroup}
                    />
                {/if}
            </SectionWithOverview>
        {:else}
            Season in progress, but there is no upcoming match... <pre>{toJsonString(
                    seasonStatus.inProgress,
                )}</pre>
        {/if}
    {:else}
        Season Starting...
    {/if}
{/if}

<style>
    .teams {
        max-width: 400px;
    }
</style>
