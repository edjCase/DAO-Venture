<script lang="ts">
    import { scheduleStore } from "../../stores/ScheduleStore";
    import TeamStandings from "../team/TeamStandings.svelte";
    import PlayerAwards from "../player/PlayerAwards.svelte";
    import SeasonWinners from "./SeasonWinners.svelte";
    import { MatchGroupDetails } from "../../models/Match";
    import MatchGroup from "../match/MatchGroup.svelte";
    import InBetweenMatchesOverview from "../match/InBetweenMatchesOverview.svelte";
    import LiveMatchesOverview from "../match/LiveMatchesOverview.svelte";
    import { SeasonStatus } from "../../ic-agent/declarations/league";
    import { onDestroy } from "svelte";
    import { toJsonString } from "../../utils/StringUtil";

    let seasonStatus: SeasonStatus | undefined;
    let lastMatchGroup: MatchGroupDetails | undefined;
    let nextOrCurrentMatchGroup: MatchGroupDetails | undefined;

    scheduleStore.subscribeStatus((status) => {
        seasonStatus = status;
    });

    scheduleStore.subscribeMatchGroups((matchGroups: MatchGroupDetails[]) => {
        lastMatchGroup = matchGroups
            .slice()
            .reverse()
            .find((mg) => mg.state == "Completed");
        nextOrCurrentMatchGroup = matchGroups.find(
            (mg) =>
                mg.id > (lastMatchGroup?.id || -1) &&
                (mg.state == "InProgress" || mg.state == "Scheduled"),
        );
    });
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
        <SeasonWinners completedSeason={seasonStatus.completed} />

        <div class="flex flex-wrap justify-evenly gap-2">
            <div class="teams">
                <TeamStandings completedSeason={seasonStatus.completed} />
            </div>
            <div class="players">
                <PlayerAwards completedSeason={seasonStatus.completed} />
            </div>
        </div>
    {:else if "inProgress" in seasonStatus}
        {#if nextOrCurrentMatchGroup}
            {#if nextOrCurrentMatchGroup.state == "Scheduled"}
                <InBetweenMatchesOverview />
            {:else if nextOrCurrentMatchGroup.state == "InProgress"}
                <LiveMatchesOverview />
            {/if}
            <MatchGroup matchGroup={nextOrCurrentMatchGroup} {lastMatchGroup} />
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
    .players {
        max-width: 600px;
    }
</style>
