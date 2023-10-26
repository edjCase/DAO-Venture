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
  import { Principal } from "@dfinity/principal";
  import VoteForMatch from "../components/VoteForMatch.svelte";

  export let leagueMatchId: string;
  let id = parseInt(leagueMatchId.split("-", 1)[0]);
  let stadiumId = Principal.fromText(
    leagueMatchId.slice(id.toString().length + 1)
  );

  let match: Match;
  let team1: Team;
  let team2: Team;
  let loadingTeams = true;
  let matchDetails;
  let state: MatchState;
  let events: MatchEvent[];
  matchStore.subscribe((matches) => {
    match = matches.find(
      (item) => item.id == id && item.stadiumId.compareTo(stadiumId) == "eq"
    );
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
  let start = async () => {
    let stadiumAgent = stadiumAgentFactory(match.stadiumId);
    let result = await stadiumAgent.startMatch(match.id);
    if ("ok" in result) {
      state = { inProgress: result.ok };
      console.log("Started match");
    } else if ("completed" in result) {
      state = { completed: result.completed };
      console.log("Match is complete");
    } else {
      console.log("Error starting: ", result);
    }
  };
  let looping = false;
  let tickLoop = async () => {
    await tick();
    if (looping) {
      await tickLoop();
    }
  };
  let toggle = async () => {
    looping = !looping;
    if (looping) {
      tickLoop();
    }
  };
  let s = (key, value) => {
    if (typeof value === "bigint" || value instanceof Principal) {
      return value.toString();
    }
    return value;
  };

  $: {
    let team1Score: bigint;
    let team2Score: bigint;
    let winner: Principal | undefined;
    if (!!state) {
      if ("inProgress" in state) {
        team1Score = state.inProgress.team1.score;
        team2Score = state.inProgress.team2.score;
        events = state.inProgress.events;
      } else if ("completed" in state) {
        if ("played" in state.completed) {
          team1Score = state.completed.played.team1.score;
          team2Score = state.completed.played.team2.score;
          events = state.completed.played.events;
          winner =
            "team1" in state.completed.played.winner
              ? match.teams[0].id
              : match.teams[1].id;
        } else {
          team1Score = BigInt(0);
          team2Score = BigInt(0);
          events = [];
        }
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
  <section>
    <ScoreHeader {...matchDetails} />
    <section class="match-details">
      {#if "inProgress" in state}
        <div class="buttons">
          <button on:click={tick}>Tick</button>
          <button on:click={toggle}>{!looping ? "Start" : "Stop"}</button>
          {#if loading}
            <span>Ticking...</span>
          {/if}
        </div>
        {#if "inProgress" in state}
          <FieldState state={state.inProgress} />
        {/if}
      {:else if "notStarted" in state}
        <h1>Upcoming</h1>
        <button on:click={start}>Start</button>

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

      <section class="match-events">
        <h2>Events</h2>
        <Events {events} />
      </section>

      <h2>JSON</h2>
      <pre>
    {JSON.stringify(match, s, 2)}
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
  .buttons {
    width: 200px;
  }
  .match-details {
    display: flex;
    flex-direction: column;
    align-items: center;
  }

  .match-events {
    display: flex;
    flex-direction: column;
    align-items: center;
  }
</style>
