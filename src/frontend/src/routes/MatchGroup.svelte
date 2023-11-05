<script context="module" lang="ts">
  type PlayedTeamDetails = {
    score: bigint;
  };
  type PlayedMatchStateDetails = {
    team1: PlayedTeamDetails;
    team2: PlayedTeamDetails;
    winner: TeamIdOrTie;
    log: LogEntry[];
  };
  type CompletedMatchStateDetails =
    | { allAbsent: null }
    | { absentTeam: { name: string } }
    | { played: PlayedMatchStateDetails };
  type InProgressMatchStateDetails = {
    offenseTeamId: TeamId;
    team1: TeamState;
    team2: TeamState;
    aura: MatchAura;
    players: [PlayerState];
    field: FieldState;
    log: [LogEntry];
    round: bigint;
    outs: bigint;
    strikes: bigint;
  };
  type NotStartedMatchStateDetails = {};

  type StartedMatchStateDetails =
    | CompletedMatchStateDetails
    | InProgressMatchStateDetails;

  type CompletedMatchGroupStateDetails = {
    matches: CompletedMatchStateDetails[];
  };
  type InProgressMatchGroupStateDetails = {
    matches: StartedMatchStateDetails[];
  };
  type NotStartedMatchGroupStateDetails = {
    matches: NotStartedMatchStateDetails[];
  };
  type MatchGroupStateDetails =
    | NotStartedMatchGroupStateDetails
    | CompletedMatchGroupStateDetails
    | InProgressMatchGroupStateDetails;

  type OfferingDetails = {
    name: string;
    description: string;
  };
  type MatchAuraDetails = OfferingDetails;

  type TeamDetails = {
    id: Principal;
    name: string;
    predictionVotes: bigint;
  };
  type MatchDetails = {
    team1: TeamDetails;
    team2: TeamDetails;
    offerings: OfferingDetails[];
    aura: MatchAuraDetails;
  };
  type MatchGroupDetails = {
    id: number;
    time: bigint;
    matches: MatchDetails[];
    state: MatchGroupStateDetails;
  };
</script>

<script lang="ts">
  import ScoreHeader from "../components/ScoreHeader.svelte";
  import { matchGroupStore } from "../stores/MatchGroupStore";
  import FieldState from "../components/FieldState.svelte";
  import { Principal } from "@dfinity/principal";
  import VoteForMatch from "../components/VoteForMatch.svelte";
  import { toJsonString } from "../utils/JsonUtil";
  import { onMount } from "svelte";
  import {
    InProgressMatchGroupState,
    CompletedMatchGroupState,
    Match,
    MatchAura,
    MatchGroup,
    MatchGroupState,
    MatchTeam,
    Offering,
    StartedMatchState,
    NotStartedMatchGroupState,
    CompletedMatchState,
    InProgressMatchState,
    LogEntry,
    TeamIdOrTie,
    TeamIdOrBoth,
    TeamId,
    TeamState,
    PlayerState,
  } from "../ic-agent/Stadium";

  export let matchGroupId: number;

  let matchGroup: MatchGroupDetails | undefined;

  let getTeamName = (
    teamId: TeamIdOrBoth | TeamIdOrTie,
    matchIndex: number
  ): string => {
    if (!matchGroup) {
      return "Unknown";
    }
    if ("both" in teamId) {
      return "Both Teams";
    } else if ("tie" in teamId) {
      return "Tie";
    } else if ("team1" in teamId) {
      return matchGroup.matches[matchIndex].team1.name;
    } else {
      return matchGroup.matches[matchIndex].team2.name;
    }
  };
  let getTeamNameById = (teamId: Principal): string => {
    if (!!matchGroup) {
      let team = matchGroup.matches
        .map((match) => [match.team1, match.team2])
        .flat()
        .find((team) => team.id.compareTo(teamId) == "eq");
      if (!!team) {
        return team.name;
      }
    }
    return "Unknown";
  };
  let mapTeam = (team: MatchTeam): TeamDetails => {
    return {
      name: team.name,
      predictionVotes: team.predictionVotes,
    };
  };
  let mapOfferings = (offering: Offering): MatchAuraDetails => {
    if ("shuffleAndBoost" in offering) {
      return {
        name: "Shuffle And Boost",
        description:
          "Shuffle your team's field positions and boost your team with a random blessing.",
      };
    } else {
      return {
        name: "Unknown",
        description: "Unknown",
      };
    }
  };

  let mapAura = (aura: MatchAura): MatchAuraDetails => {
    if ("lowGravity" in aura) {
      return {
        name: "Shuffle And Boost",
        description:
          "Shuffle your team's field positions and boost your team with a random blessing",
      };
    } else if ("explodingBalls" in aura) {
      return {
        name: "Exploding Balls",
        description: "Balls have a chance to explode on contact with the bat",
      };
    } else if ("fastBallsHardHits" in aura) {
      return {
        name: "Fast Balls, Hard Hits",
        description: "Balls are faster and fly farther when hit by the bat",
      };
    } else if ("moreBlessingsAndCurses" in aura) {
      return {
        name: "More Blessings And Curses",
        description: "Blessings and curses are more common",
      };
    } else {
      return {
        name: "Unknown",
        description: "Unknown",
      };
    }
  };
  let mapMatch = (match: Match): MatchDetails => {
    return {
      team1: mapTeam(match.team1),
      team2: mapTeam(match.team2),
      offerings: match.offerings.map(mapOfferings),
      aura: mapAura(match.aura),
    };
  };
  let mapInProgressMatchState = (
    state: InProgressMatchState
  ): InProgressMatchStateDetails => {
    return {};
  };
  let mapCompletedMatchState = (
    state: CompletedMatchState
  ): CompletedMatchStateDetails => {
    if ("played" in state) {
      return {
        played: {
          team1: state.played.team1,
          team2: state.played.team2,
          winner: state.played.winner,
          log: state.played.log,
        },
      };
    } else if ("allAbsent" in state) {
      return {
        allAbsent: null,
      };
    } else {
      return {
        absentTeam: getTeamName(state.absentTeam),
      };
    }
  };
  let mapStartedMatchState = (
    state: StartedMatchState
  ): StartedMatchStateDetails => {
    if ("inProgress" in state) {
      return mapInProgressMatchState(state.inProgress);
    } else {
      return mapCompletedMatchState(state.completed);
    }
  };
  let mapNotStartedState = (
    state: NotStartedMatchGroupState
  ): NotStartedMatchGroupStateDetails => {
    return {
      matches: state.matches.map(mapMatch),
    };
  };
  let mapInProgressState = (
    state: InProgressMatchGroupState
  ): InProgressMatchGroupStateDetails => {
    return {
      matches: state.matches.map(mapStartedMatchState),
    };
  };
  let mapCompletedState = (
    state: CompletedMatchGroupState
  ): CompletedMatchGroupStateDetails => {
    return {
      matches: state.matches.map(mapCompletedMatchState),
    };
  };
  let mapState = (state: MatchGroupState): MatchGroupStateDetails => {
    if ("inProgress" in state) {
      return mapInProgressState(state.inProgress);
    } else if ("completed" in state) {
      return mapCompletedState(state.completed);
    } else {
      return mapNotStartedState(state.notStarted);
    }
  };
  let mapMatchGroup = (matchGroup: MatchGroup): MatchGroupDetails => {
    return {
      id: matchGroup.id,
      time: matchGroup.time,
      matches: matchGroup.matches.map(mapMatch),
      state: mapState(matchGroup.state),
    };
  };

  matchGroupStore.subscribe((matchGroups) => {
    let g = matchGroups.find((item) => item.id == matchGroupId);
    matchGroup = mapMatchGroup(g);
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
        remainingMillis = undefined;
      } else if ("completed" in state) {
        if ("played" in state.completed) {
          team1Score = state.completed.played.team1.score;
          team2Score = state.completed.played.team2.score;
          log = state.completed.played.log;
          winner =
            "team1" in state.completed.played.winner
              ? match.team1.id
              : match.team2.id;
          remainingMillis = undefined;
        } else {
          team1Score = BigInt(0);
          team2Score = BigInt(0);
          log = [];
          remainingMillis = undefined;
        }
      } else if ("notStarted" in state) {
        team1Score = BigInt(0);
        team2Score = BigInt(0);
        log = [];
        remainingMillis = Number(match.time / BigInt(1_000_000)) - Date.now();
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
  let remainingMillis: number | undefined;
  onMount(() => {
    const intervalId = setInterval(() => {
      if (match) {
        remainingMillis = Number(match.time / BigInt(1_000_000)) - Date.now();
        if (remainingMillis <= 0) {
          clearInterval(intervalId);
        }
      }
    }, 1000);

    return () => clearInterval(intervalId); // Cleanup interval on component destroy
  });
  let printTime = (remainingMillis: number): string => {
    if (remainingMillis < 1) {
      return "ANY SECOND!";
    }
    let seconds = Math.floor(remainingMillis / 1000);
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
        {#if remainingMillis}
          <h1>
            Upcoming in {printTime(remainingMillis)}
          </h1>
        {/if}
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
