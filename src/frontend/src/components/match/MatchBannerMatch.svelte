<script lang="ts">
    import {
        CompletedMatch,
        InProgressMatch,
        NotScheduledMatch,
        ScheduledMatch,
        TownAssignment,
    } from "../../ic-agent/declarations/main";
    import { TownOrUndetermined } from "../../models/Town";
    import { townStore } from "../../stores/TownStore";
    import MatchBannerTown from "./MatchBannerTown.svelte";

    export let match:
        | { notScheduled: NotScheduledMatch }
        | { scheduled: ScheduledMatch }
        | { inProgress: InProgressMatch }
        | { completed: CompletedMatch };

    $: towns = $townStore;

    let map = (town: TownAssignment): TownOrUndetermined | undefined => {
        if ("predetermined" in town) {
            let townId = town.predetermined;
            return towns?.find((t) => t.id == townId);
        }
        if ("winnerOfMatch" in town) {
            return { winnerOfMatch: Number(town.winnerOfMatch) };
        }
        return { seasonStandingIndex: Number(town.seasonStandingIndex) };
    };

    let town1: TownOrUndetermined | undefined;
    let town2: TownOrUndetermined | undefined;
    $: {
        if ("completed" in match) {
            town1 = towns?.find((t) => t.id == match.completed.town1.id);
            town2 = towns?.find((t) => t.id == match.completed.town2.id);
        } else if ("inProgress" in match) {
            town1 = towns?.find((t) => t.id == match.inProgress.town1.id);
            town2 = towns?.find((t) => t.id == match.inProgress.town2.id);
        } else if ("scheduled" in match) {
            town1 = towns?.find((t) => t.id == match.scheduled.town1.id);
            town2 = towns?.find((t) => t.id == match.scheduled.town2.id);
        } else {
            town1 = map(match.notScheduled.town1);
            town2 = map(match.notScheduled.town2);
        }
    }

    let town1Score: bigint | undefined;
    let town2Score: bigint | undefined;
    $: {
        if ("completed" in match) {
            town1Score = match.completed.town1.score;
            town2Score = match.completed.town2.score;
        } else {
            town1Score = undefined;
            town2Score = undefined;
        }
    }
</script>

{#if town1 && town2}
    <div class="flex flex-col items-center w-16 mr-2 bg-gray-700 rounded py-1">
        <MatchBannerTown town={town1} score={town1Score} />
        <div class="mb-2"></div>
        <MatchBannerTown town={town2} score={town2Score} />
    </div>
{/if}
