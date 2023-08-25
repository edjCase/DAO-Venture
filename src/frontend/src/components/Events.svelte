<script lang="ts">
  import type { Match } from "../ic-agent/Stadium";

  export let match: Match;

  // let reducePlayerFunc = (map, player) => {
  //   map[player.id] = player.name;
  //   return map;
  // };
  // let team1PlayerMap = match.teams[0].players.reduce(reducePlayerFunc, {});
  // let team2PlayerMap = match.teams[1].players.reduce(reducePlayerFunc, {});

  // let compiledInningScorings = match.scorings.reduce(
  //   (acc, s) => {
  //     let playerMap = s.topHalf ? team1PlayerMap : team2PlayerMap;
  //     let inning = (s.topHalf ? "Top" : "Bottom") + " " + s.inning;
  //     let battingPlayer = playerMap[s.battingPlayerId];
  //     let scoringPlayers = s.scoringPlayerIds.map((id) => playerMap[id]);

  //     let scoringList;
  //     if (acc.currentInning != inning || acc.innings.length == 0) {
  //       acc.currentInning = inning;
  //       scoringList = [];
  //       acc.innings.push({
  //         inning: inning,
  //         scorings: scoringList,
  //       });
  //     } else {
  //       scoringList = acc.innings[acc.innings.length - 1].scorings;
  //     }
  //     let currentScore = acc.currentScore;
  //     currentScore[s.topHalf ? 0 : 1] += s.scoringPlayerIds.length;
  //     scoringList.push({
  //       battingPlayer: battingPlayer,
  //       scoringPlayers: scoringPlayers,
  //       score: [currentScore[0], currentScore[1]],
  //     });
  //     return acc;
  //   },
  //   {
  //     currentInning: null,
  //     currentScore: [0, 0],
  //     innings: [],
  //   }
  // ).innings;
</script>

<div class="inning-list">
  <!-- {#each compiledInningScorings as inningScoring}
    <div class="inning-name">{inningScoring.inning}</div>
    <div class="inning-item">
      {#each inningScoring.scorings as scoring}
        <div class="scoring">
          <span class="scoring-message"
            >{scoring.battingPlayer} was at bat and {scoring.scoringPlayers.join(
              ", "
            )} scored</span
          >
          <span class="score">{scoring.score[0]} - {scoring.score[1]}</span>
        </div>
      {/each}
    </div>
  {/each} -->
  TODO
</div>

<style>
  .inning-list {
    display: flex;
    flex-direction: column;
  }
  .inning-name {
    font-size: 1.5em;
    font-weight: bold;
    margin-bottom: 10px;
  }
  .inning-item {
    margin-bottom: 20px;
    padding-left: 20px;
  }
  .scoring {
    border-bottom: 1px;
    border-color: var(--text-color);
  }
  .scoring-message {
    margin-right: 20px;
  }
  .score {
    width: 30px;
    font-size: 1.5em;
    font-weight: bold;
  }
</style>
