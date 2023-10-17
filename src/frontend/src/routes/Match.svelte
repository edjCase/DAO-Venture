<script lang="ts">
  import Events from "../components/Events.svelte";
  import ScoreHeader from "../components/ScoreHeader.svelte";
  import { matchStore } from "../stores/MatchStore";
  import { teamStore } from "../stores/TeamStore";
  import type { Team } from "../ic-agent/League";
  import {
    stadiumAgentFactory,
    type Match,
    type MatchState,
    type MatchEvent,
  } from "../ic-agent/Stadium";
  import FieldState from "../components/FieldState.svelte";
  import type { Principal } from "@dfinity/principal";

  export let id: number;

  let match: Match;
  let team1: Team;
  let team2: Team;
  let loadingTeams = true;
  let matchDetails;
  let state: MatchState;
  let events: MatchEvent[];
  matchStore.subscribe((matches) => {
    match = matches.find((item) => item.id == id);
    if (match) {
      state = match.state;
      teamStore.subscribe((teams) => {
        team1 = teams.find(
          (team) => team.id.compareTo(match.teams[0].id) === "eq"
        );
        team2 = teams.find(
          (team) => team.id.compareTo(match.teams[1].id) === "eq"
        );
        loadingTeams = false;
      });
    }
  });

  let loading = false;
  let tick = async () => {
    let stadiumAgent = stadiumAgentFactory(match.stadiumId);
    loading = true;
    let result = await stadiumAgent.tickMatch(match.id);
    loading = false;
    if ("ok" in result) {
      state = { inProgress: result.ok };
    } else if ("matchOver" in result) {
      state = { completed: result.matchOver };
    } else {
      // TODO
      console.log("Error ticking: ", result);
    }
  };
  let timerId;
  let toggle = async () => {
    if (timerId) {
      clearInterval(timerId);
      timerId = undefined;
      return;
    }
    timerId = setInterval(tick, 500);
  };
  let s = (key, value) =>
    typeof value === "bigint" ? value.toString() : value; // return everything else unchanged;

  $: {
    let team1Score: bigint;
    let team2Score: bigint;
    let winner: Principal | undefined;
    if (!!state) {
      if ("inProgress" in state) {
        team1Score = state.inProgress.team1.score;
        team2Score = state.inProgress.team2.score;
        events = state.inProgress.events;
      } else if ("completed" in state && "played" in state.completed) {
        team1Score = state.completed.played.team1.score;
        team2Score = state.completed.played.team2.score;
        events = state.completed.played.events;
        winner =
          "team1" in state.completed.played.winner
            ? match.teams[0].id
            : match.teams[1].id;
      } else if ("notStarted" in state) {
        team1Score = BigInt(0);
        team2Score = BigInt(0);
        events = [];
      } else {
        throw "Invalid state: " + JSON.stringify(state, s, 2);
      }

      matchDetails = {
        team1: {
          id: match.teams[0].id,
          name: team1.name,
          predictionVotes: match.teams[0].predictionVotes,
          score: team1Score,
        },
        team2: {
          id: match.teams[1].id,
          name: team2.name,
          predictionVotes: match.teams[1].predictionVotes,
          score: team2Score,
        },
        winner: winner,
      };
    }
  }
</script>

{#if !loadingTeams}
  <section id="match-details">
    <ScoreHeader {...matchDetails} />

    {#if "inProgress" in state || "notStarted" in state}
      <button on:click={tick}>Tick</button>
      <button on:click={toggle}>{!timerId ? "Start" : "Stop"}</button>
      {#if loading}
        <span>Ticking...</span>
      {/if}
      {#if "inProgress" in state}
        <FieldState state={state.inProgress} />
      {/if}
    {:else if "completed" in state}
      <div />
    {:else}
      <h1>Game hasnt started</h1>
    {/if}

    <section class="match-events">
      <h2>Events</h2>
      <Events {events} />
    </section>

    <h2>JSON</h2>
    <pre>
    {JSON.stringify(match, s, 2)}
  </pre>
  </section>
{:else}
  Loading...
{/if}

<style>
  section {
    margin-bottom: 20px;
  }

  .match-events {
    display: flex;
    flex-direction: column;
    align-items: center;
  }
</style>
