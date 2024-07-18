<script lang="ts">
    import { ArrowUpRightFromSquareOutline } from "flowbite-svelte-icons";
    import { InProgressSeasonMatchGroupVariant } from "../../ic-agent/declarations/main";
    import { scheduleStore } from "../../stores/ScheduleStore";
    import { nanosecondsToDate } from "../../utils/DateUtils";
    import MatchBannerMatch from "./MatchBannerMatch.svelte";
    import { Link } from "svelte-routing";

    let matchGroups: InProgressSeasonMatchGroupVariant[] | undefined;
    let scrollContainer: HTMLElement;
    let matchBannerGroupIndex: number | undefined;

    scheduleStore.subscribeMatchGroups((mgs) => {
        matchGroups = mgs;
    });

    function findNextMatchGroupIndex(
        matchGroups: InProgressSeasonMatchGroupVariant[],
    ): number {
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

    function scrollToNextMatchGroup(
        scrollContainer: HTMLElement,
        matchGroups: InProgressSeasonMatchGroupVariant[] | undefined,
    ) {
        if (matchBannerGroupIndex !== undefined) return; // Already set, skip
        if (!scrollContainer || !matchGroups || matchGroups.length === 0) {
            return;
        }
        const nextGroupIndex = findNextMatchGroupIndex(matchGroups);
        if (nextGroupIndex === -1) return;
        matchBannerGroupIndex = nextGroupIndex;
    }

    $: scrollToNextMatchGroup(scrollContainer, matchGroups);

    function scrollToMatchGroup(matchBannerGroupIndex: number | undefined) {
        if (matchBannerGroupIndex !== undefined && scrollContainer) {
            const matchGroupWidth =
                scrollContainer.querySelector(".match-group")?.clientWidth || 0;
            scrollContainer.scrollLeft =
                matchBannerGroupIndex * matchGroupWidth;
        }
    }

    $: scrollToMatchGroup(matchBannerGroupIndex);

    function handleWheel(e: WheelEvent) {
        if (scrollContainer) {
            e.preventDefault();
            scrollContainer.scrollLeft += e.deltaY;
        }
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

    function scrollToLeft() {
        if (scrollContainer && matchGroups) {
            if (
                matchBannerGroupIndex !== undefined &&
                matchBannerGroupIndex >= 1
            ) {
                matchBannerGroupIndex -= 1;
            }
        }
    }

    function scrollToRight() {
        if (scrollContainer && matchGroups) {
            if (
                matchBannerGroupIndex !== undefined &&
                matchBannerGroupIndex < matchGroups.length - 1
            ) {
                matchBannerGroupIndex += 1;
            }
        }
    }

    function handleKeydown(e: KeyboardEvent) {
        if (e.key === "ArrowLeft") {
            scrollToLeft();
        } else if (e.key === "ArrowRight") {
            scrollToRight();
        }
    }
</script>

{#if matchGroups && matchGroups.length > 0}
    <div class="relative flex bg-gray-900">
        <button
            class="flex-none w-10 bg-gray-800 text-white flex items-center justify-center border border-gray-700"
            on:click={scrollToLeft}
            aria-label="Scroll left"
        >
            &lt;
        </button>

        <div
            class="flex-grow overflow-x-auto hide-scrollbar py-2 border border-gray-700"
            bind:this={scrollContainer}
            on:wheel={handleWheel}
            on:keydown={handleKeydown}
            role="toolbar"
            aria-label="Match schedule navigation"
            tabindex="0"
        >
            <div class="flex">
                {#each matchGroups as matchGroup, matchGroupId}
                    <div class="match-group inline-flex">
                        <div class="flex items-center text-center">
                            <Link to={"/match-groups/" + matchGroupId}>
                                {getMatchGroupDate(matchGroup)}
                                <div class="flex justify-center mt-2">
                                    <ArrowUpRightFromSquareOutline size="xs" />
                                </div>
                            </Link>
                        </div>
                        {#if "notScheduled" in matchGroup}
                            {#each matchGroup.notScheduled.matches as match}
                                <MatchBannerMatch
                                    match={{ notScheduled: match }}
                                />
                            {/each}
                        {:else if "scheduled" in matchGroup}
                            {#each matchGroup.scheduled.matches as match}
                                <MatchBannerMatch
                                    match={{ scheduled: match }}
                                />
                            {/each}
                        {:else if "inProgress" in matchGroup}
                            {#each matchGroup.inProgress.matches as match}
                                <MatchBannerMatch
                                    match={{ inProgress: match }}
                                />
                            {/each}
                        {:else}
                            {#each matchGroup.completed.matches as match}
                                <MatchBannerMatch
                                    match={{ completed: match }}
                                />
                            {/each}
                        {/if}
                    </div>
                {/each}
            </div>
        </div>

        <button
            class="flex-none w-10 bg-gray-800 text-white flex items-center justify-center border border-gray-700"
            on:click={scrollToRight}
            aria-label="Scroll right"
        >
            &gt;
        </button>
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
{:else}
    <div
        class="text-xl text-center py-2 border border-gray-700 rounded border-2"
    >
        No Upcoming Matches
    </div>
{/if}
