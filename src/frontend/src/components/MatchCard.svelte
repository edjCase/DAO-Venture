<script lang="ts">
  import { Link } from "svelte-routing";
  import type { Match, PlayerState } from "../ic-agent/Stadium";
  import { teamStore } from "../stores/TeamStore";
  import { nanosecondsToDate } from "../utils/DateUtils";
  import { Team } from "../ic-agent/League";
  import { getOptValueOrUndefined } from "../utils/CandidUtil";
  import Bases from "./Bases.svelte";
  import { matchStore } from "../stores/MatchStore";
  import Tooltip from "./Tooltip.svelte";

  export let match: Match;

  let team1: Team | undefined;
  let team2: Team | undefined;
  let team1Score: bigint | undefined;
  let team2Score: bigint | undefined;
  let title: string | undefined;
  let round: bigint | undefined;
  let team1Lead: string | undefined;
  let team2Lead: string | undefined;
  let baseState:
    | {
        firstBase: number | undefined;
        secondBase: number | undefined;
        thirdBase: number | undefined;
      }
    | undefined;

  let startDate = nanosecondsToDate(match.time);

  let getPlayerName = (players: PlayerState[], playerId: number): string => {
    let player = players.find((p) => p.id == playerId);
    if (player) {
      return player.name;
    }
    return "Unknown";
  };

  teamStore.subscribe((teams) => {
    team1 = teams.find((team) => team.id.compareTo(match.team1.id) === "eq");
    team2 = teams.find((team) => team.id.compareTo(match.team2.id) === "eq");
  });
  matchStore.subscribe((matches) => {
    let newMatch = matches.find(
      (m) => m.id == match.id && m.stadiumId == match.stadiumId
    )!;
    if (newMatch) {
      match = newMatch;
    }

    if (match) {
      if ("inProgress" in match.state) {
        let offense = match.state.inProgress.field.offense;
        baseState = {
          firstBase: getOptValueOrUndefined(offense.firstBase),
          secondBase: getOptValueOrUndefined(offense.secondBase),
          thirdBase: getOptValueOrUndefined(offense.thirdBase),
        };
        team1Score = match.state.inProgress.team1.score;
        team2Score = match.state.inProgress.team2.score;
        title = undefined;
        round = match.state.inProgress.round;
        let team1LeadId, team2LeadId: number;
        let team1LeadEmoji, team2LeadEmoji: string;
        if ("team1" in match.state.inProgress.offenseTeamId) {
          team1LeadEmoji = "🏹";
          team1LeadId = match.state.inProgress.field.offense.atBat;
          team2LeadEmoji = "⚾";
          team2LeadId = match.state.inProgress.field.defense.pitcher;
        } else {
          team1LeadEmoji = "⚾";
          team1LeadId = match.state.inProgress.field.defense.pitcher;
          team2LeadEmoji = "🏹";
          team2LeadId = match.state.inProgress.field.offense.atBat;
        }
        team1Lead =
          team1LeadEmoji +
          " " +
          getPlayerName(match.state.inProgress.players, team1LeadId);
        team2Lead =
          getPlayerName(match.state.inProgress.players, team2LeadId) +
          " " +
          team2LeadEmoji;
      } else if ("completed" in match.state) {
        baseState = undefined;
        round = undefined;
        team1Lead = undefined;
        team2Lead = undefined;
        if ("played" in match.state.completed) {
          let played = match.state.completed.played;
          team1Score = played.team1.score;
          team2Score = played.team2.score;
          let winner;
          if ("team1" in played.winner) {
            winner = team1;
          } else if ("team2" in played.winner) {
            winner = team2;
          } else {
            winner = undefined;
          }
          title = winner ? `${winner.name} Wins!` : "Tie Game";
        } else if ("absentTeam" in match.state.completed) {
          let absentTeam = match.state.completed.absentTeam;
          if (team1 && team2) {
            let team = "team1" in absentTeam ? team1 : team2;
            title = `${team.name} Absent`;
          }
        } else if ("allAbsent" in match.state.completed) {
          title = "All Absent";
        } else {
          team1Score = undefined;
          team2Score = undefined;
        }
      } else {
        baseState = undefined;
        team1Score = undefined;
        team2Score = undefined;
        round = undefined;
        team1Lead = undefined;
        team2Lead = undefined;
        title = startDate.toLocaleString("en-US", {
          month: "short",
          day: "2-digit",
          hour: "2-digit",
          minute: "2-digit",
        });
      }
    }
  });
</script>

{#if !team1 || !team2}
  <div>Loading...</div>
{:else}
  <div class="card">
    <Link to={`/matches/${match.id}-${match.stadiumId.toString()}`}>
      <div class="header">
        <div class="team">
          <div class="top">
            <Tooltip>
              <img
                class="logo"
                src={team1.logoUrl}
                alt="{team1.name} Logo"
                slot="content"
              />
              <div slot="tooltip" class="name">{team1.name}</div>
            </Tooltip>
            {#if team1Score !== undefined}
              <div class="score">{team1Score}</div>
            {/if}
          </div>
          <div class="mid">
            {#if team1Lead}
              <div class="team-lead">{team1Lead}</div>
            {/if}
          </div>
          <div class="bottom" />
        </div>
        <div class="center">
          <div class="top">
            {#if baseState}
              <Bases state={baseState} />
            {:else if title !== undefined}
              <div class="title">{title}</div>
            {/if}
          </div>

          <div class="mid">
            {#if round}
              <div>Round {round}</div>
            {/if}
          </div>
          <div class="bottom" />
        </div>
        <div class="team">
          <div class="top">
            {#if team2Score !== undefined}
              <div class="score">{team2Score}</div>
            {/if}
            <Tooltip>
              <img
                class="logo"
                src={team2.logoUrl}
                alt="{team2.name} Logo"
                slot="content"
              />
              <div slot="tooltip" class="name">{team2.name}</div>
            </Tooltip>
          </div>
          <div class="mid">
            {#if team2Lead}
              <div class="team-lead">{team2Lead}</div>
            {/if}
          </div>
          <div class="bottom" />
        </div>
      </div>
    </Link>
  </div>
{/if}

<style>
  .card {
    background: black;
    border-radius: 5px;
    box-shadow: 2px 2px 5px rgba(0, 0, 0, 0.3);
    margin: 1rem;
  }
  .card :global(a) {
    text-decoration: none;
    color: inherit;
  }
  .team {
    display: flex;
    flex-direction: column;
  }
  .name {
    font-size: 2rem;
    font-weight: bold;
  }
  .logo {
    width: 50px;
    height: 50px;
  }

  .header {
    display: flex;
    justify-content: space-between;
  }
  .top {
    display: flex;
    flex-direction: row;
    align-items: center;
    height: 50px;
  }
  .top,
  .mid,
  .bottom {
    max-width: 120px;
  }

  .team-lead {
    font-size: 0.9rem;
    text-align: center;
  }

  .title {
    display: flex;
    align-items: center;
  }

  .score {
    font-size: 2rem;
    font-weight: bold;
    margin: 0 1rem;
  }
</style>
