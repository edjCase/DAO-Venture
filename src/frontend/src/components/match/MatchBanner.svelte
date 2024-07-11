<script lang="ts">
    import { afterUpdate } from "svelte";
    import { InProgressSeasonMatchGroupVariant } from "../../ic-agent/declarations/main";
    import { scheduleStore } from "../../stores/ScheduleStore";
    import { nanosecondsToDate } from "../../utils/DateUtils";
    import MatchBannerMatch from "./MatchBannerMatch.svelte";

    let matchGroups: InProgressSeasonMatchGroupVariant[] = [];
    let scrollContainer: HTMLElement;

    scheduleStore.subscribeMatchGroups((mgs) => {
        matchGroups = mgs;
    });

    function findNextMatchGroupIndex(): number {
        const now = Date.now();
        return matchGroups.findIndex((group) => {
            const groupTime =
                "scheduled" in group
                    ? group.scheduled.time
                    : "notScheduled" in group
                      ? group.notScheduled.time
                      : "inProgress" in group
                        ? group.inProgress.time
                        : group.completed.time;
            return nanosecondsToDate(groupTime).getTime() > now;
        });
    }

    function scrollToNextMatchGroup() {
        if (!scrollContainer || matchGroups.length === 0) return;
        const nextGroupIndex = findNextMatchGroupIndex();
        if (nextGroupIndex === -1) return;

        const matchGroupWidth =
            scrollContainer.querySelector(".match-group")?.clientWidth || 0;
        scrollContainer.scrollLeft = nextGroupIndex * matchGroupWidth;
    }

    afterUpdate(scrollToNextMatchGroup);

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
        const walk = x - startX;
        scrollContainer.scrollLeft = scrollLeft - walk;
    }

    function dragEnd() {
        startX = undefined;
        scrollLeft = undefined;
    }

    function getMatchGroupDate(matchGroup: InProgressSeasonMatchGroupVariant) {
        let time;
        if ("scheduled" in matchGroup) {
            time = matchGroup.scheduled.time;
        } else if ("notScheduled" in matchGroup) {
            time = matchGroup.notScheduled.time;
        } else if ("inProgress" in matchGroup) {
            time = matchGroup.inProgress.time;
        } else {
            time = matchGroup.completed.time;
        }
        let date = nanosecondsToDate(time);
        let monthString = date.toLocaleString("default", { month: "short" });
        return monthString + " " + date.getDate();
    }
</script>

<div
    class="flex overflow-x-auto hide-scrollbar bg-gray-900 py-2"
    bind:this={scrollContainer}
    on:mousedown={dragStart}
    on:mousemove={dragAction}
    on:mouseup={dragEnd}
    on:mouseleave={dragEnd}
    role="button"
    tabindex="0"
>
    <div class="flex">
        {#each matchGroups as matchGroup}
            <div class="match-group inline-flex">
                <div class="flex items-center text-center">
                    {getMatchGroupDate(matchGroup)}
                </div>
                {#if "notScheduled" in matchGroup}
                    {#each matchGroup.notScheduled.matches as match}
                        <MatchBannerMatch match={{ notScheduled: match }} />
                    {/each}
                {:else if "scheduled" in matchGroup}
                    {#each matchGroup.scheduled.matches as match}
                        <MatchBannerMatch match={{ scheduled: match }} />
                    {/each}
                {:else if "inProgress" in matchGroup}
                    {#each matchGroup.inProgress.matches as match}
                        <MatchBannerMatch match={{ inProgress: match }} />
                    {/each}
                {:else}
                    {#each matchGroup.completed.matches as match}
                        <MatchBannerMatch match={{ completed: match }} />
                    {/each}
                {/if}
            </div>
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
