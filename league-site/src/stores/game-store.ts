import { readable } from "svelte/store";
import type { CompletedGame, Game } from "../types/Game";

let completedGames : CompletedGame[] = [
  {
    id: 1,
    team1: "T1",
    team2: "T2",
    stadium: "S1",
    team1Score: 3,
    team2Score: 7,
  },
  {
    id: 2,
    team1: "T2",
    team2: "T3",
    stadium: "S2",
    team1Score: 2,
    team2Score: 3,
  },
];
export const completedGamesStore = readable(completedGames);

let upcomingGames : Game[] = [
  {
    id: 3,
    team1: "T5",
    team2: "T6",
    stadium: "S1",
  },
  {
    id: 4,
    team1: "T7",
    team2: "T8",
    stadium: "S2",
  },
];
export const upcomingGamesStore = readable(upcomingGames);

