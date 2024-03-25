<script lang="ts">
    import { MatchGroupDetails } from "../../models/Match";
    import { scheduleStore } from "../../stores/ScheduleStore";
    import { teamStore } from "../../stores/TeamStore";
    import { nanosecondsToDate } from "../../utils/DateUtils";
    import MatchBannerTeam from "./MatchBannerTeam.svelte";

    let matchGroups: MatchGroupDetails[] = [];

    let winLossRecords: Record<number, string> = {};

    scheduleStore.subscribeMatchGroups((mgs) => {
        matchGroups = mgs;
    });

    teamStore.subscribeTeamStandings((standings) => {
        if (standings === undefined) {
            return;
        }
        winLossRecords = standings.reduce(
            (acc, standing) => {
                acc[Number(standing.id)] =
                    `(${standing.wins}-${standing.losses})`;
                return acc;
            },
            {} as Record<number, string>,
        );
    });

    let scrollContainer: HTMLElement;
    let startX: number | undefined;
    let scrollLeft: number | undefined;

    function dragStart(e: MouseEvent) {
        startX = e.pageX - scrollContainer.offsetLeft;
        scrollLeft = scrollContainer.scrollLeft;
    }

    function dragAction(e: MouseEvent) {
        if (startX === undefined || scrollLeft === undefined) return;
        e.preventDefault();
        const x = e.pageX - scrollContainer.offsetLeft;
        const walk = x - startX; //scroll-fast
        scrollContainer.scrollLeft = scrollLeft - walk;
    }

    function dragEnd() {
        startX = undefined;
        scrollLeft = undefined;
    }

    let getMatchGroupDate = (matchGroup: MatchGroupDetails) => {
        let date = nanosecondsToDate(matchGroup.time);
        let monthString = date.toLocaleString("default", { month: "short" });

        return monthString + " " + date.getDate();
    };
</script>

<!-- svelte-ignore a11y-no-static-element-interactions -->
<!-- TODO a11y -->
<div
    class="flex overflow-x-auto hide-scrollbar"
    bind:this={scrollContainer}
    on:mousedown={dragStart}
    on:mousemove={dragAction}
    on:mouseup={dragEnd}
    on:mouseleave={dragEnd}
>
    <div class="inline-flex">
        {#each matchGroups as matchGroup}
            <div class="flex items-center text-center">
                {getMatchGroupDate(matchGroup)}
            </div>
            {#each matchGroup.matches as match}
                <div class="flex flex-col text-xs w-32 p-1 m-2 border rounded">
                    <div class="text-center">
                        {#if match.state == "Played"}
                            Final
                        {:else}
                            {nanosecondsToDate(match.time).toLocaleTimeString()}
                        {/if}
                    </div>
                    <MatchBannerTeam
                        team={match.team1}
                        winLossRecord={winLossRecords}
                    />
                    <MatchBannerTeam
                        team={match.team2}
                        winLossRecord={winLossRecords}
                    />
                </div>
            {/each}
        {/each}
    </div>
</div>

<style>
    .hide-scrollbar::-webkit-scrollbar {
        display: none;
    }
    .hide-scrollbar {
        -ms-overflow-style: none;
        scrollbar-width: none;
    }
</style>
