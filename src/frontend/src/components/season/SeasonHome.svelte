<script lang="ts">
    import Countdown from "../common/Countdown.svelte";
    import { scheduleStore } from "../../stores/ScheduleStore";
    import { nanosecondsToDate } from "../../utils/DateUtils";
    import { Button } from "flowbite-svelte";
    import { navigate } from "svelte-routing";
    import TeamLogo from "../team/TeamLogo.svelte";
    import { teamStore } from "../../stores/TeamStore";
    import SectionWithOverview from "../common/SectionWithOverview.svelte";
    import { Team } from "../../ic-agent/declarations/main";

    $: teams = $teamStore;

    let nextMatchGroupDate: Date | undefined;
    let matchGroupInProgress: bigint | undefined;
    let seasonChampionId: bigint | undefined;
    let seasonChampion: Team | undefined;
    scheduleStore.subscribeMatchGroups((matchGroups) => {
        let now = new Date();
        nextMatchGroupDate = undefined;
        matchGroupInProgress = undefined;
        for (let matchGroup of matchGroups) {
            if (matchGroup.state == "InProgress") {
                matchGroupInProgress = matchGroup.id;
                break;
            }
            if (matchGroup.state != "Scheduled") {
                continue;
            }
            let date = nanosecondsToDate(matchGroup.time);
            if (date > now) {
                nextMatchGroupDate = date;
                break;
            }
        }
    });
    scheduleStore.subscribeStatus((status) => {
        if (status == undefined) {
            return;
        }
        if ("completed" in status) {
            seasonChampionId = status.completed.championTeamId;
        } else {
            seasonChampionId = undefined;
        }
    });

    $: {
        seasonChampion = teams?.find((t) => t.id == seasonChampionId);
    }
</script>

<SectionWithOverview title="Matches">
    <ul slot="details" class="list-disc list-inside text-sm space-y-1">
        <li>
            The season is a series of matches where teams compete to win the
            championship
        </li>
        <li>
            Each match group has a set of matches that are played in parallel
        </li>
        <li>
            The season champion is the team with the most points at the end of
            the season
        </li>
    </ul>

    <div class="flex justify-around border-2 rounded border-gray-700 p-4">
        <div>
            {#if matchGroupInProgress}
                <Button on:click={() => navigate("/matches")}
                    >View Live Match</Button
                >
            {:else if nextMatchGroupDate}
                <div class="text-xl text-center">
                    Next Matches in <Countdown date={nextMatchGroupDate} />
                </div>
                <div class="flex justify-center mt-2">
                    <Button on:click={() => navigate("/matches")}>
                        Make your predictions
                    </Button>
                </div>
            {:else if seasonChampion !== undefined}
                <div class="text-xl text-center">Season Complete</div>
                <div class="text-xl text-center">Champions:</div>
                <div class="text-xl text-center">{seasonChampion.name}</div>

                <TeamLogo team={seasonChampion} size="md" />
            {/if}
        </div>
    </div>
</SectionWithOverview>
