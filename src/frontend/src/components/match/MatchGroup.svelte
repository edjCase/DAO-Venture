<script lang="ts">
  import { MatchDetails, MatchGroupDetails } from "../../models/Match";
  import { nanosecondsToDate } from "../../utils/DateUtils";
  import PredictMatchOutcome from "./PredictMatchOutcome.svelte";
  import LiveMatchComponent from "./LiveMatch.svelte";
  import {
    LiveMatch,
    liveMatchGroupStore,
  } from "../../stores/LiveMatchGroupStore";
  import MatchCardCompact from "./MatchCardCompact.svelte";
  import TeamChoice from "../scenario/Scenarios.svelte";
  import { ScenarioInstance } from "../../models/Scenario";
  import Countdown from "../common/Countdown.svelte";

  export let matchGroup: MatchGroupDetails;

  let selectedMatchId = 0;
  let selectedMatch: MatchDetails = matchGroup.matches[selectedMatchId];
  let liveMatches: LiveMatch[] | undefined = undefined;
  let selectedLiveMatch: LiveMatch | undefined;
  let matches: [MatchDetails, LiveMatch | undefined][] = [];

  let updateMatches = () => {
    matches = matchGroup.matches.map((match, index) => [
      match,
      liveMatches ? liveMatches[index] : undefined,
    ]);
    selectedMatch = matchGroup.matches[selectedMatchId];
    selectedLiveMatch = liveMatches ? liveMatches[selectedMatchId] : undefined;
  };

  liveMatchGroupStore.subscribe((liveMatchGroup) => {
    if (!liveMatchGroup || matchGroup.id != liveMatchGroup?.id) {
      selectedLiveMatch = undefined;
      liveMatches = undefined;
    } else {
      selectedLiveMatch = liveMatchGroup.matches[selectedMatchId];
      liveMatches = liveMatchGroup.matches;
    }
    updateMatches();
  });

  let selectMatch = (matchId: number) => () => {
    selectedMatchId = matchId;
    updateMatches();
  };
  let currentScenarios: ScenarioInstance[] | undefined;
  if (matchGroup.state == "Scheduled") {
    currentScenarios = [];
    for (let match of matchGroup.matches) {
      if ("scenario" in match.team1 && match.team1.scenario) {
        currentScenarios.push(match.team1.scenario);
      }
      if ("scenario" in match.team2 && match.team2.scenario) {
        currentScenarios.push(match.team2.scenario);
      }
    }
  }
</script>

<section>
  <section class="match-details">
    {#if matchGroup.state == "Scheduled" || matchGroup.state == "NotScheduled"}
      <Countdown title="Next Match" date={nanosecondsToDate(matchGroup.time)} />
    {:else if matchGroup.state == "Completed"}
      <div>Match Group is over</div>
    {/if}
    {#if currentScenarios !== undefined}
      <TeamChoice matchGroupId={matchGroup.id} scenarios={currentScenarios} />
    {/if}
    {#if matchGroup.state == "Scheduled"}
      <h1>Predict the upcoming match-up winners</h1>
      {#each matchGroup.matches as match}
        <PredictMatchOutcome {match} />
      {/each}
    {:else if matchGroup.state == "NotScheduled"}
      Not Scheduled TODO
    {:else}
      <div class="container">
        <div class="selected-match">
          {#if selectedLiveMatch}
            <LiveMatchComponent
              match={selectedMatch}
              liveMatch={selectedLiveMatch}
            />
          {:else}
            <!-- {#if lastScenarios !== undefined}
              <TeamChoice matchGroupId={matchGroup.id} scenarios={currentScenarios} />
            {/if} -->
          {/if}
        </div>
        <div class="other-matches">
          {#each matches as [match, liveMatch]}
            <div
              class="clickable"
              on:click={selectMatch(match.id)}
              on:keydown={() => {}}
              on:keyup={() => {}}
              role="button"
              tabindex="0"
            >
              <MatchCardCompact
                {match}
                {liveMatch}
                selected={match.id == selectedMatchId}
              />
            </div>
          {/each}
        </div>
      </div>
    {/if}
  </section>
</section>

<style>
  section {
    margin-bottom: 20px;
  }
  .match-details {
    display: flex;
    flex-direction: column;
    align-items: center;
  }

  .container {
    display: flex;
    flex-direction: row;
    justify-content: center;
    flex-wrap: wrap;
    align-items: stretch;
    padding: 5px;
    max-width: 800px;
  }
  .selected-match {
    display: flex;
    justify-content: center;
    align-items: stretch;
    margin: 0 10px;
    height: 50vh;
    flex: 1;
  }
  .other-matches {
    display: flex;
    flex-direction: column;
    justify-content: center;
    align-items: center;
    flex: 1;
  }

  @media (max-width: 768px) {
    .container {
      flex-direction: column;
      flex-wrap: nowrap;
      align-items: center;
    }
    .selected-match,
    .other-matches {
      flex: none;
    }
  }
  .clickable {
    cursor: pointer;
    width: 100%;
  }
</style>
