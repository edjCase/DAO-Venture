<script lang="ts">
    import { Spinner } from "flowbite-svelte";
    import { TeamId, TeamStandingInfo } from "../../ic-agent/declarations/main";
    import {
        MatchDetails,
        TeamDetailsOrUndetermined,
    } from "../../models/Match";
    import { predictionStore } from "../../stores/PredictionsStore";
    import { teamStore } from "../../stores/TeamStore";
    import TeamLogo from "../team/TeamLogo.svelte";

    type MatchPrediction = {
        teamTotal: number;
        teamPercentage: number;
        yourVote: TeamId | undefined;
    };

    export let match: MatchDetails;
    export let teamId: TeamId;

    let matchTeam: TeamDetailsOrUndetermined;
    let matchPredictions: MatchPrediction | undefined;
    let predicting = false;

    if ("team1" in teamId) {
        matchTeam = match.team1;
    } else {
        matchTeam = match.team2;
    }

    let teamStandings: TeamStandingInfo[] | undefined;

    teamStore.subscribeTeamStandings((standings) => {
        teamStandings = standings;
    });

    predictionStore.subscribeToMatchGroup(match.matchGroupId, (predictions) => {
        if (!predictions) {
            matchPredictions = undefined;
            predictionStore.refetchMatchGroup(match.matchGroupId);
        } else {
            let matchPrediction = predictions.matches[Number(match.id)];
            let totalPredictions =
                Number(matchPrediction.team1) + Number(matchPrediction.team2);
            let team =
                "team1" in teamId
                    ? matchPrediction.team1
                    : matchPrediction.team2;
            matchPredictions = {
                teamTotal: Number(team),
                teamPercentage: Number(team) / totalPredictions || 0,
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
            match.matchGroupId,
            match.id,
            teamId,
        );
        predicting = false;
    };
    function areTeamsEqual(
        team1: TeamId | undefined,
        team2: TeamId | undefined,
    ) {
        if (team1 === undefined || team2 === undefined) {
            return false;
        }
        if ("team1" in team1 && "team1" in team2) {
            return true;
        }
        if ("team2" in team1 && "team2" in team2) {
            return true;
        }
        return false;
    }

    // Placeholder function for getting team stats
    let teamStats: string;
    $: {
        teamStats = "";
        if ("id" in matchTeam) {
            let id = matchTeam.id;
            const standing = teamStandings?.find((s) => s.id == id);
            if (standing) {
                teamStats = `${standing.wins}-${standing.losses}`;
            }
        }
    }
    let predictionIcon = "";
    $: {
        if (matchPredictions !== undefined) {
            if (areTeamsEqual(matchPredictions.yourVote, teamId)) {
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
        <TeamLogo team={matchTeam} size="sm" stats={true} />
        <div class="text-sm font-bold">
            {teamStats}
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
                    {(matchPredictions.teamPercentage * 100).toFixed(0)}%
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
