<script lang="ts">
    import { scheduleStore } from "../../stores/ScheduleStore";
    import { nanosecondsToDate } from "../../utils/DateUtils";
    import { teamStore } from "../../stores/TeamStore";
    import SectionWithOverview from "../common/SectionWithOverview.svelte";
    import { Team } from "../../ic-agent/declarations/main";
    import MatchBanner from "../match/MatchBanner.svelte";

    $: teams = $teamStore;

    let nextMatchGroupDate: Date | undefined;
    let matchGroupInProgress: number | undefined;
    let seasonChampionId: bigint | undefined;
    let seasonChampion: Team | undefined;
    scheduleStore.subscribeMatchGroups((matchGroups) => {
        matchGroupInProgress = matchGroups.findIndex(
            (mg) => "inProgress" in mg,
        );
        let nextMatchGroup = matchGroups.find((mg) => "scheduled" in mg);
        if (nextMatchGroup) {
            nextMatchGroupDate = nanosecondsToDate(
                nextMatchGroup?.scheduled.time,
            );
        } else {
            nextMatchGroupDate = undefined;
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

    <MatchBanner />
</SectionWithOverview>
