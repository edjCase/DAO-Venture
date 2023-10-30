<script lang="ts">
  import Log from "../components/Log.svelte";
  import ScoreHeader from "../components/ScoreHeader.svelte";
  import { matchStore } from "../stores/MatchStore";
  import { teamStore } from "../stores/TeamStore";
  import type { Team } from "../ic-agent/League";
  import type { Match, MatchState, LogEntry } from "../ic-agent/Stadium";
  import FieldState from "../components/FieldState.svelte";
  import { Principal } from "@dfinity/principal";
  import VoteForMatch from "../components/VoteForMatch.svelte";
  import { toJsonString } from "../utils/JsonUtil";
  import { subscribe, type LiveStreamMessage } from "../ic-agent/LiveStreamHub";
  import { onDestroy } from "svelte";

  export let leagueMatchId: string;
  let id = parseInt(leagueMatchId.split("-", 1)[0]);
  let stadiumId = Principal.fromText(
    leagueMatchId.slice(id.toString().length + 1)
  );

  type TeamDetails = {
    id: Principal;
    name: string;
    predictionVotes: bigint;
    score: bigint;
  };

  let match: Match | undefined;
  let team1: Team | undefined;
  let team2: Team | undefined;
  let loadingTeams = true;
  let matchDetails:
    | { team1: TeamDetails; team2: TeamDetails; winner: Principal | undefined }
    | undefined;
  let state: MatchState;
  let log: LogEntry[];
  matchStore.subscribe((matches) => {
    match = matches.find(
      (item) => item.id == id && item.stadiumId.compareTo(stadiumId) == "eq"
    );
    if (match) {
      state = match.state;
      teamStore.subscribe((teams) => {
        team1 = teams.find(
          (team) => team.id.compareTo(match!.team1.id) === "eq"
        );
        team2 = teams.find(
          (team) => team.id.compareTo(match!.team2.id) === "eq"
        );
        loadingTeams = false;
      });
    }
  });
  let ws = subscribe((msg: LiveStreamMessage) => {
    state = msg.state;
  });
  onDestroy(() => {
    ws.close();
  });

  $: {
    let team1Score: bigint;
    let team2Score: bigint;
    let winner: Principal | undefined;
    if (!!state && !!match && !!team1 && !!team2) {
      if ("inProgress" in state) {
        team1Score = state.inProgress.team1.score;
        team2Score = state.inProgress.team2.score;
        log = state.inProgress.log;
      } else if ("completed" in state) {
        if ("played" in state.completed) {
          team1Score = state.completed.played.team1.score;
          team2Score = state.completed.played.team2.score;
          log = state.completed.played.log;
          winner =
            "team1" in state.completed.played.winner
              ? match.team1.id
              : match.team2.id;
        } else {
          team1Score = BigInt(0);
          team2Score = BigInt(0);
          log = [];
        }
      } else if ("notStarted" in state) {
        team1Score = BigInt(0);
        team2Score = BigInt(0);
        log = [];
      } else {
        throw "Invalid state: " + toJsonString(state);
      }

      matchDetails = {
        team1: {
          id: match.team1.id,
          name: team1.name,
          predictionVotes: match.team1.predictionVotes,
          score: team1Score,
        },
        team2: {
          id: match.team2.id,
          name: team2.name,
          predictionVotes: match.team2.predictionVotes,
          score: team2Score,
        },
        winner: winner,
      };
    }
  }
  let getRemainingTime = (startTime: bigint): string => {
    let msDifference = Number(startTime / BigInt(1_000_000)) - Date.now();
    if (msDifference < 1) {
      return "ANY SECOND!";
    }
    let seconds = Math.floor(msDifference / 1000);
    let minutes = Math.floor(seconds / 60);
    let hours = Math.floor(minutes / 60);
    let days = Math.floor(hours / 24);

    // Adjust values so they reflect remaining time, not total time
    seconds %= 60;
    minutes %= 60;
    hours %= 24;

    return `${days} days, ${hours} hours, ${minutes} minutes, ${seconds} seconds`;
  };
</script>

{#if !loadingTeams && !!match && !!team1 && !!team2 && !!matchDetails}
  <section>
    <ScoreHeader {...matchDetails} />
    <section class="match-details">
      {#if "inProgress" in state}
        <FieldState state={state.inProgress} />
      {:else if "notStarted" in state}
        <h1>
          Upcoming in {getRemainingTime(match.time)}
        </h1>
        <div>
          <h1>Vote for Matches</h1>
          <VoteForMatch
            matchId={match.id}
            stadiumId={match.stadiumId}
            teamId={team1.id}
          />
          <VoteForMatch
            matchId={match.id}
            stadiumId={match.stadiumId}
            teamId={team2.id}
          />
        </div>
      {:else if "completed" in state}
        <div>Completed</div>
        {#if "played" in state.completed}
          <div>Played</div>
        {:else if "allAbsent" in state.completed}
          <div>All absent</div>
        {:else if "abstentTeam" in state.completed}
          <div>Absent Team: {state.completed.absentTeam}</div>
        {/if}
      {:else}
        <h1>Game hasnt started</h1>
      {/if}

      <section class="match-log">
        <h2>Match Log</h2>
        <Log {log} />
      </section>

      <h2>JSON</h2>
      <pre>
        {toJsonString(match)}
      </pre>
    </section>
  </section>
{:else}
  Loading...
{/if}

<style>
  section {
    margin-bottom: 20px;
  }
  .match-details {
    display: flex;
    flex-direction: column;
    align-items: center;
  }

  .match-log {
    display: flex;
    flex-direction: column;
    align-items: center;
  }
</style>
