<script lang="ts">
  import {
    stadiumAgentFactory,
    type Match,
    type InProgressMatchState,
  } from "../ic-agent/Stadium";

  export let match: Match;

  let s = (key, value) =>
    typeof value === "bigint" ? value.toString() : value; // return everything else unchanged;
  let state: InProgressMatchState =
    "inProgress" in match.state ? match.state.inProgress : null;

  $: if (state) {
    // TODO make a store for the state
  }
  let stadiumAgent = stadiumAgentFactory(match.stadiumId);
  let tick = async () => {
    let result = await stadiumAgent.tickMatch(match.id);
    if ("ok" in result) {
      state = result.ok;
    } else {
      alert(JSON.stringify(result, s, 2));
    }
  };

  let getPlayerName = (id: ([] | [number]) | number) => {
    if (!state) return "";
    let playerId;
    if (id instanceof Array) {
      if (id.length < 1) return "";
      playerId = id[0];
    } else {
      playerId = id;
    }
    let player = state.players.find((player) => player.id == playerId);
    return player ? player.name : "Unknown";
  };
</script>

<button on:click={tick}>Tick</button>

{#if !!state}
  <div>
    <h2>Bases</h2>
    <div>At Bat: {getPlayerName([state.field.offense.atBat])}</div>
    <div>First: {getPlayerName(state.field.offense.firstBase)}</div>
    <div>Second: {getPlayerName(state.field.offense.secondBase)}</div>
    <div>Third: {getPlayerName(state.field.offense.thirdBase)}</div>
  </div>
  <div>
    <h2>Field</h2>
    <div>Pitcher: {getPlayerName(state.field.defense.pitcher)}</div>
    <div>First Base: {getPlayerName(state.field.defense.firstBase)}</div>
    <div>Second Base: {getPlayerName(state.field.defense.secondBase)}</div>
    <div>Third Base: {getPlayerName(state.field.defense.thirdBase)}</div>
    <div>Short Stop: {getPlayerName(state.field.defense.shortStop)}</div>
    <div>Left Field: {getPlayerName(state.field.defense.leftField)}</div>
    <div>Center Field: {getPlayerName(state.field.defense.centerField)}</div>
    <div>Right Field: {getPlayerName(state.field.defense.rightField)}</div>
  </div>
  <div>
    <ul>
      {#each state.events as event}
        <li>{event.description}</li>
      {/each}
    </ul>
  </div>
{/if}

<h2>JSON</h2>
<pre>
  {JSON.stringify(match, s, 2)}
</pre>

<style>
</style>
