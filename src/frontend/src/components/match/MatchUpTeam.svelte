<script lang="ts">
    import { Spinner } from "flowbite-svelte";
    import { TownId, TownStandingInfo } from "../../ic-agent/declarations/main";
    import { predictionStore } from "../../stores/PredictionsStore";
    import { townStore } from "../../stores/TownStore";
    import TeamFlag from "../town/TeamFlag.svelte";
    import { TownOrUndetermined } from "../../models/Town";

    type MatchPrediction = {
        townTotal: number;
        townPercentage: number;
        yourVote: TownId | undefined;
    };

    export let matchGroupId: number;
    export let matchId: number;
    export let town: TownOrUndetermined;
    export let townId: TownId;

    let matchPredictions: MatchPrediction | undefined;
    let predicting = false;

    let townStandings: TownStandingInfo[] | undefined;

    townStore.subscribeTownStandings((standings) => {
        townStandings = standings;
    });

    predictionStore.subscribeToMatchGroup(matchGroupId, (predictions) => {
        if (!predictions) {
            matchPredictions = undefined;
            predictionStore.refetchMatchGroup(matchGroupId);
        } else {
            let matchPrediction = predictions.matches[Number(matchId)];
            let totalPredictions =
                Number(matchPrediction.town1) + Number(matchPrediction.town2);
            let town =
                "town1" in townId
                    ? matchPrediction.town1
                    : matchPrediction.town2;
            matchPredictions = {
                townTotal: Number(town),
                townPercentage: Number(town) / totalPredictions || 0,
                yourVote:
                    matchPrediction.yourVote.length > 0
                        ? matchPrediction.yourVote[0]
                        : undefined,
            };
        }
    });

    let predict = async function () {
        predicting = true;
        await predictionStore.predictMatchOutcome(
            matchGroupId,
            matchId,
            townId,
        );
        predicting = false;
    };
    function areTownsEqual(
        town1: TownId | undefined,
        town2: TownId | undefined,
    ) {
        if (town1 === undefined || town2 === undefined) {
            return false;
        }
        if ("town1" in town1 && "town1" in town2) {
            return true;
        }
        if ("town2" in town1 && "town2" in town2) {
            return true;
        }
        return false;
    }

    // Placeholder function for getting town stats
    let townStats: string;
    $: {
        townStats = "";
        if ("id" in town) {
            let id = town.id;
            const standing = townStandings?.find((s) => s.id == id);
            if (standing) {
                townStats = `${standing.wins}-${standing.losses}`;
            }
        }
    }
    let predictionIcon = "";
    $: {
        if (matchPredictions !== undefined) {
            if (areTownsEqual(matchPredictions.yourVote, townId)) {
                predictionIcon = "🟢";
            } else if (matchPredictions.yourVote !== undefined) {
                predictionIcon = "";
            } else {
                predictionIcon = "❓";
            }
        }
    }
</script>

<div class="flex justify-between gap-2">
    <div class="flex flex-col justify-center items-center">
        <TeamFlag {town} size="sm" stats={false} />
        <div class="text-sm font-bold">
            {townStats}
        </div>
    </div>
    <div class="flex flex-col items-center justify-center text-center">
        <div class="flex items-center">
            {#if matchPredictions?.yourVote === undefined}
                <button class="text-3xl cursor-pointer" on:click={predict}>
                    🔮
                </button>
            {:else}
                <div class="text-3xl">🔮</div>
            {/if}
        </div>
        {#if matchPredictions !== undefined}
            <div class="flex flex-col items-center justify-center">
                <div class="text-sm">
                    {(matchPredictions.townPercentage * 100).toFixed(0)}%
                </div>
                {#if predicting}
                    <Spinner size="5" />
                {:else}
                    <div class="text-xs">{predictionIcon}</div>
                {/if}
            </div>
        {/if}
    </div>
</div>
