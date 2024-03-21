<script lang="ts">
    import Countdown from "../common/Countdown.svelte";
    import { scheduleStore } from "../../stores/ScheduleStore";
    import { nanosecondsToDate } from "../../utils/DateUtils";
    import { Button } from "flowbite-svelte";
    import { navigate } from "svelte-routing";
    import TeamLogo from "../team/TeamLogo.svelte";
    import { teamStore } from "../../stores/TeamStore";
    import { TeamWithId } from "../../ic-agent/declarations/league";

    $: teams = $teamStore;

    let nextMatchGroupDate: Date | undefined;
    let matchGroupInProgress: bigint | undefined;
    let seasonChampionId: bigint | undefined;
    let seasonChampion: TeamWithId | undefined;
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
        seasonChampion = teams.find((t) => t.id == seasonChampionId);
    }
</script>

<div class="text-3xl text-center">Season 0</div>
<div class="text-xl text-center mb-5">The Awakening</div>
<div class="flex justify-around">
    <div>
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
        {:else if seasonChampion !== undefined}
            <div class="text-xl text-center">Season Complete</div>
            <div class="text-xl text-center">Champions:</div>
            <div class="text-xl text-center">{seasonChampion.name}</div>

            <TeamLogo team={seasonChampion} size="md" />
        {/if}
    </div>
    <div class="flex items-center">
        <Button on:click={() => navigate("/season")}>Details =></Button>
    </div>
</div>
