<script lang="ts">
  import type {
    CompletedMatchState,
    InProgressMatchState,
    MatchGroup,
    MatchTeam,
    PlayerState,
    StartedMatchState,
  } from "../ic-agent/Stadium";
  import { matchGroupStore } from "../stores/MatchGroupStore";
  import MatchCard, {
    CompletedMatchDetail,
    InProgressMatchDetail,
    MatchDetail,
  } from "./MatchCard.svelte";
  import { getOptValueOrUndefined } from "../utils/CandidUtil";

  export let matchGroupId: number;

  let matchDetails: MatchDetail[] | undefined;

  let getPlayerName = (players: PlayerState[], playerId: number): string => {
    let player = players.find((p) => p.id == playerId);
    if (player) {
      return player.name;
    }
    return "Unknown";
  };
  let buildInProgressMatchDetail = (
    team1: MatchTeam,
    team2: MatchTeam,
    matchState: InProgressMatchState
  ): InProgressMatchDetail => {
    let offense = matchState.field.offense;
    let team1LeadId, team2LeadId: number;
    let team1LeadEmoji, team2LeadEmoji: string;
    if ("team1" in matchState.offenseTeamId) {
      team1LeadEmoji = "🏹";
      team1LeadId = matchState.field.offense.atBat;
      team2LeadEmoji = "⚾";
      team2LeadId = matchState.field.defense.pitcher;
    } else {
      team1LeadEmoji = "⚾";
      team1LeadId = matchState.field.defense.pitcher;
      team2LeadEmoji = "🏹";
      team2LeadId = matchState.field.offense.atBat;
    }
    let team1Lead =
      team1LeadEmoji + " " + getPlayerName(matchState.players, team1LeadId);
    let team2Lead =
      getPlayerName(matchState.players, team2LeadId) + " " + team2LeadEmoji;
    return {
      team1: {
        name: team1.name,
        logoUrl: team1.logoUrl,
        score: matchState.team1.score,
        activePlayerName: team1Lead,
      },
      team2: {
        name: team2.name,
        logoUrl: team2.logoUrl,
        score: matchState.team2.score,
        activePlayerName: team2Lead,
      },
      baseState: {
        firstBase: getOptValueOrUndefined(offense.firstBase),
        secondBase: getOptValueOrUndefined(offense.secondBase),
        thirdBase: getOptValueOrUndefined(offense.thirdBase),
      },
      round: matchState.round,
    };
  };
  let buildCompletedMatchDetail = (
    team1: MatchTeam,
    team2: MatchTeam,
    matchState: CompletedMatchState
  ): CompletedMatchDetail => {
    let team1Score, team2Score: bigint | undefined;
    let title: string;
    if ("played" in matchState) {
      team1Score = matchState.played.team1.score;
      team2Score = matchState.played.team2.score;
      let winner;
      if ("team1" in matchState.played.winner) {
        winner = team1;
      } else if ("team2" in matchState.played.winner) {
        winner = team2;
      } else {
        winner = undefined;
      }
      title = winner ? `${winner.name} Wins!` : "Tie Game";
    } else if ("absentTeam" in matchState) {
      let absentTeam = matchState.absentTeam;
      if (team1 && team2) {
        let team = "team1" in absentTeam ? team1 : team2;
        title = `${team.name} Absent`;
      } else {
        title = "Unknown Team Absent";
      }
    } else {
      title = "All Absent";
    }
    return {
      title: title,
      team1: {
        name: team1.name,
        logoUrl: team1.logoUrl,
        score: team1Score,
      },
      team2: {
        name: team2.name,
        logoUrl: team2.logoUrl,
        score: team2Score,
      },
    };
  };
  let buildMatchDetail = (
    team1: MatchTeam,
    team2: MatchTeam,
    matchState: StartedMatchState
  ): MatchDetail => {
    if ("inProgress" in matchState) {
      return buildInProgressMatchDetail(team1, team2, matchState.inProgress);
    } else {
      return buildCompletedMatchDetail(team1, team2, matchState.completed);
    }
  };
  matchGroupStore.subscribe((matchGroups: MatchGroup[]) => {
    let matchGroup = matchGroups.find(
      (matchGroup) => matchGroup.id == matchGroupId
    );
    if (!matchGroup) {
      matchDetails = undefined;
      return;
    }
    if ("notStarted" in matchGroup.state) {
      return;
    }
    if ("inProgress" in matchGroup.state) {
      matchDetails = matchGroup.state.inProgress.matches.map((m, i) => {
        let match = matchGroup!.matches[i];
        return buildMatchDetail(match.team1, match.team2, m);
      });
    } else {
      matchDetails = matchGroup.state.completed.matches.map((m, i) => {
        let match = matchGroup!.matches[i];
        return buildCompletedMatchDetail(match.team1, match.team2, m);
      });
    }
  });
</script>

{#if matchDetails === undefined}
  <div>Loading...</div>
{:else}
  <div class="match-card-grid">
    {#each matchDetails as match}
      <MatchCard {match} />
    {/each}
  </div>

  <style>
    .match-card-grid {
      display: grid;
      grid-template-columns: repeat(auto-fill, 400px);
      justify-content: center;
    }
  </style>
{/if}
