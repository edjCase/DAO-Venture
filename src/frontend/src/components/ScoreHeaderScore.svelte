<script lang="ts">
    import type { Team } from "../types/Game";
    export let won : boolean;
    export let playerChoice : boolean;
    export let score : number | null;
    export let predictionPercent : number;
</script>

<div class="score">
    <div class="score-value">{score}</div>
    {#if won}
        <div class="winner" title="Winner">👑</div>
    {/if}
    {#if predictionPercent > .5}
        <div class="prediction" title="Community Choice">🔮</div>
    {/if}
    {#if playerChoice}
        <div class="player-choice" title="Your Choice">✔️</div>
    {/if}
</div>

<style>    
    .score {
        font-size: 1.5em;
        font-weight: bold;
        display: flex;
        flex-direction: row;
        align-items: center;
        align-content: space-around;
        
    }
    .winner, .prediction, .player-choice {
        font-size: 0.7em;
        margin-left: 10px;
    }
</style>