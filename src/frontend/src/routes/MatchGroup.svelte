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
  type NotStartedMatchStateDetails = {};

  type StartedMatchStateDetails =
    | { completed: CompletedMatchStateDetails }
    | { inProgress: InProgressMatchState };

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
    | { notStarted: NotStartedMatchGroupStateDetails }
    | { completed: CompletedMatchGroupStateDetails }
    | { inProgress: InProgressMatchGroupStateDetails };

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
  type MatchDetail = {
    team1: TeamDetails;
    team2: TeamDetails;
    offerings: OfferingDetails[];
    aura: MatchAuraDetails;
  };
  type MatchGroupDetails = {
    id: number;
    time: bigint;
    matches: MatchDetail[];
    state: MatchGroupStateDetails;
  };
</script>

<script lang="ts">
  import {
    getOfferingDetails,
    matchGroupStore,
  } from "../stores/MatchGroupStore";
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
    StartedMatchState,
    NotStartedMatchGroupState,
    CompletedMatchState,
    InProgressMatchState,
    LogEntry,
    TeamIdOrTie,
    TeamIdOrBoth,
  } from "../ic-agent/Stadium";
  import MatchCard from "../components/MatchCard.svelte";

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
      id: team.id,
      name: team.name,
      predictionVotes: team.predictionVotes,
    };
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
  let mapMatch = (match: Match): MatchDetail => {
    return {
      team1: mapTeam(match.team1),
      team2: mapTeam(match.team2),
      offerings: match.offerings.map(getOfferingDetails),
      aura: mapAura(match.aura),
    };
  };
  let mapInProgressMatchState = (
    state: InProgressMatchState
  ): InProgressMatchState => {
    return state;
  };
  let mapCompletedMatchState = (
    state: CompletedMatchState,
    matchIndex: number
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
        absentTeam: {
          name: getTeamName(state.absentTeam, matchIndex),
        },
      };
    }
  };
  let mapStartedMatchState = (
    state: StartedMatchState,
    matchIndex: number
  ): StartedMatchStateDetails => {
    if ("inProgress" in state) {
      return { inProgress: mapInProgressMatchState(state.inProgress) };
    } else {
      return { completed: mapCompletedMatchState(state.completed, matchIndex) };
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
      return { inProgress: mapInProgressState(state.inProgress) };
    } else if ("completed" in state) {
      return { completed: mapCompletedState(state.completed) };
    } else {
      return { notStarted: mapNotStartedState(state.notStarted) };
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
    if (g) {
      matchGroup = mapMatchGroup(g);
    } else {
      matchGroup = undefined;
    }
  });

  let remainingMillis: number | undefined;
  onMount(() => {
    const intervalId = setInterval(() => {
      if (matchGroup) {
        remainingMillis =
          Number(matchGroup.time / BigInt(1_000_000)) - Date.now();
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

{#if !!matchGroup}
  <section>
    <section class="match-details">
      {#if remainingMillis}
        <h1>
          Upcoming in {printTime(remainingMillis)}
        </h1>
      {/if}

      {#if "inProgress" in matchGroup.state}
        {#each matchGroup.matches as match}
          <MatchCard {match} />
        {/each}
      {:else if "notStarted" in matchGroup.state}
        <div>
          <h1>Vote for Matche</h1>
          <VoteForMatch
            matchId={index}
            stadiumId={matchGroup.stadiumId}
            teamId={match.team1.id}
          />
          <VoteForMatch
            matchId={index}
            stadiumId={matchGroup.stadiumId}
            teamId={match.team2.id}
          />
        </div>
      {:else if "completed" in matchGroup.state}
        <div>Completed</div>
        {#if "played" in matchGroup.state.completed}
          <div>Played</div>
        {:else if "allAbsent" in matchGroup.state.completed}
          <div>All absent</div>
        {:else if "absentTeam" in matchGroup.state.completed}
          <div>Absent Team: {matchGroup.state.completed.absentTeam}</div>
        {/if}
      {:else}
        <h1>Game hasnt started</h1>
      {/if}

      <section class="match-log">
        <h2>Match Log</h2>
      </section>

      <h2>JSON</h2>
      <pre>
        {toJsonString(matchGroup)}
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
