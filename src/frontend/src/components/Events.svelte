<script lang="ts">
    import type { Game } from "../types/Game";

    export let game: Game;

    let reducePlayerFunc = (map, player) => {
        map[player.id] = player.name;
        return map;
    };
    let team1PlayerMap = game.team1.players.reduce(reducePlayerFunc, {});
    let team2PlayerMap = game.team2.players.reduce(reducePlayerFunc, {});

    let compiledInnings = game.events.reduce(
        (acc, e) => {
            let playerMap = e.topHalf ? team1PlayerMap : team2PlayerMap;
            let inning = (e.topHalf ? "Top" : "Bottom") + " " + e.inning;

            if (acc.currentInning != inning || acc.innings.length == 0) {
                acc.currentInning = inning;
                acc.innings.push({
                    inning: inning,
                    events: [],
                });
            }

            let inningObj = acc.innings[acc.innings.length - 1];

            let eventMessage: string;
            switch (e.info.type) {
                case "score":
                    let battingPlayer = playerMap[e.info.battingPlayerId];
                    let scoringPlayers = e.info.scoringPlayerIds
                        .map((id) => playerMap[id])
                        .join(", ");

                    let topBottomIndex = e.topHalf ? 0 : 1;
                    acc.currentScore[topBottomIndex] +=
                        e.info.scoringPlayerIds.length;
                    eventMessage =
                        battingPlayer +
                        " was at bat and " +
                        scoringPlayers +
                        " scored " +
                        acc.currentScore[0] +
                        " - " +
                        acc.currentScore[1];
                    break;
                case "injury":
                    eventMessage =
                        playerMap[e.info.playerId] +
                        " was injured: " +
                        e.info.injury;
                    break;
                default:
                    eventMessage = "Unknown event";
            }
            inningObj.events.push(eventMessage);
            return acc;
        },
        {
            currentInning: null,
            currentScore: [0, 0],
            innings: [],
        }
    ).innings;
</script>

<div class="inning-list">
    {#each compiledInnings as inning}
        <div class="inning-name">{inning.inning}</div>
        <div class="inning-item">
            {#each inning.events as event}
                <div class="scoring">
                    {event}
                </div>
            {/each}
        </div>
    {/each}
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
</style>
