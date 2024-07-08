<script lang="ts">
    import { MatchGroupDetails } from "../../models/Match";
    import { scheduleStore } from "../../stores/ScheduleStore";
    import { teamStore } from "../../stores/TeamStore";
    import { nanosecondsToDate } from "../../utils/DateUtils";
    import MatchBannerMatch from "./MatchBannerMatch.svelte";

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
                    `${standing.wins}-${standing.losses}`;
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

<div
    class="flex overflow-x-auto hide-scrollbar bg-gray-900 py-4"
    bind:this={scrollContainer}
    on:mousedown={dragStart}
    on:mousemove={dragAction}
    on:mouseup={dragEnd}
    on:mouseleave={dragEnd}
    role="button"
    tabindex="0"
>
    <div class="inline-flex">
        {#each matchGroups as matchGroup}
            <div class="flex items-center text-center">
                {getMatchGroupDate(matchGroup)}
            </div>
            {#each matchGroup.matches as match}
                <MatchBannerMatch {match} {winLossRecords} />
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
