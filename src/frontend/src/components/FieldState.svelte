<script lang="ts">
  import type { InProgressMatchState } from "../ic-agent/Stadium";

  export let state: InProgressMatchState;

  let getPlayerName = (id: ([] | [number]) | number) => {
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

<div>
  <h2>Count</h2>
  <div>Strikes: {state.strikes}</div>
  <div>Outs: {state.outs}</div>
  <div>Round: {state.round}</div>
</div>
<div>
  <h2>Bases</h2>
  <div>
    At Bat: {getPlayerName([state.field.offense.atBat])}
  </div>
  <div>
    First: {getPlayerName(state.field.offense.firstBase)}
  </div>
  <div>
    Second: {getPlayerName(state.field.offense.secondBase)}
  </div>
  <div>
    Third: {getPlayerName(state.field.offense.thirdBase)}
  </div>
</div>
<div>
  <h2>Field</h2>
  <div>
    Pitcher: {getPlayerName(state.field.defense.pitcher)}
  </div>
  <div>
    First Base: {getPlayerName(state.field.defense.firstBase)}
  </div>
  <div>
    Second Base: {getPlayerName(state.field.defense.secondBase)}
  </div>
  <div>
    Third Base: {getPlayerName(state.field.defense.thirdBase)}
  </div>
  <div>
    Short Stop: {getPlayerName(state.field.defense.shortStop)}
  </div>
  <div>
    Left Field: {getPlayerName(state.field.defense.leftField)}
  </div>
  <div>
    Center Field: {getPlayerName(state.field.defense.centerField)}
  </div>
  <div>
    Right Field: {getPlayerName(state.field.defense.rightField)}
  </div>
</div>
