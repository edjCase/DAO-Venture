import { readable } from "svelte/store";
import type { Game } from "../types/Game";

let games: Game[] = [
  {
    id: 1,
    start: new Date("2021-04-01T12:00:00Z"),
    end: new Date("2021-04-01T14:00:00Z"),
    stadium: {
      id: 1,
      name: "Stadium 1",
    },
    winningTeamId: 1,
    scorings: [
      {
        inning: 1,
        topHalf: true,
        battingPlayerId: 1,
        scoringPlayerIds: [2, 1],
      },
      {
        inning: 1,
        topHalf: true,
        battingPlayerId: 2,
        scoringPlayerIds: [1],
      },
      {
        inning: 1,
        topHalf: false,
        battingPlayerId: 3,
        scoringPlayerIds: [4],
      },
      {
        inning: 7,
        topHalf: false,
        battingPlayerId: 4,
        scoringPlayerIds: [3],
      },
    ],
    team1: {
      id: 1,
      name: "Phillies",
      logo: "https://cdn-team-logos.theathletic.com/cdn-cgi/image/width=1920,format=auto/https://cdn-team-logos.theathletic.com/team-logo-113-72x72.png",
      players: [
        {
          id: 1,
          name: "Player 1",
          position: "Pitcher",
          gameStats: { runs: 3, hits: 2, errors: 0 },
        },
        {
          id: 2,
          name: "Player 2",
          position: "Shortstop",
          gameStats: { runs: 1, hits: 3, errors: 1 },
        },
      ],
      votes: 30,
      gameStats: {
        score: 3,
      },
    },
    team2: {
      id: 2,
      name: "Diamondbacks",
      logo: "https://cdn-team-logos.theathletic.com/cdn-cgi/image/width=1920,format=auto/https://cdn-team-logos.theathletic.com/team-logo-93-72x72.png",
      players: [
        {
          id: 3,
          name: "Player 3",
          position: "Pitcher",
          gameStats: { runs: 3, hits: 2, errors: 0 },
        },
        {
          id: 4,
          name: "Player 4",
          position: "Shortstop",
          gameStats: { runs: 1, hits: 3, errors: 1 },
        },
      ],
      votes: 100,
      gameStats: {
        score: 2
      },
    },
  },
  {
    id: 2,
    start: new Date("2021-04-01T12:00:00Z"),
    end: new Date("2021-04-01T14:00:00Z"),
    stadium: {
      id: 2,
      name: "Stadium 2",
    },
    winningTeamId: 1,
    scorings: [
      {
        inning: 1,
        topHalf: true,
        battingPlayerId: 1,
        scoringPlayerIds: [2, 1],
      },
      {
        inning: 3,
        topHalf: true,
        battingPlayerId: 2,
        scoringPlayerIds: [1, 2],
      },
      {
        inning: 4,
        topHalf: false,
        battingPlayerId: 3,
        scoringPlayerIds: [4]
      }
    ],
    team1: {
      id: 1,
      name: "Phillies",
      logo: "https://cdn-team-logos.theathletic.com/cdn-cgi/image/width=1920,format=auto/https://cdn-team-logos.theathletic.com/team-logo-113-72x72.png",
      players: [
        {
          id: 1,
          name: "Player 1",
          position: "Pitcher",
          gameStats: { runs: 3, hits: 2, errors: 0 },
        },
        {
          id: 2,
          name: "Player 2",
          position: "Shortstop",
          gameStats: { runs: 1, hits: 3, errors: 1 },
        },
      ],
      votes: 25,
      gameStats: {
        score: 4,
      },
    },
    team2: {
      id: 2,
      name: "Diamondbacks",
      logo: "https://cdn-team-logos.theathletic.com/cdn-cgi/image/width=1920,format=auto/https://cdn-team-logos.theathletic.com/team-logo-93-72x72.png",
      players: [
        {
          id: 3,
          name: "Player 3",
          position: "Pitcher",
          gameStats: { runs: 3, hits: 2, errors: 0 },
        },
        {
          id: 4,
          name: "Player 4",
          position: "Shortstop",
          gameStats: { runs: 1, hits: 3, errors: 1 },
        },
      ],
      votes: 45,
      gameStats: {
        score: 1
      },
    },
  },
  {
    id: 3,
    start: new Date("2021-04-01T12:00:00Z"),
    end: null,
    stadium: {
      id: 1,
      name: "Stadium 1",
    },
    winningTeamId: 4,
    scorings: [
      {
        inning: 4,
        topHalf: false,
        battingPlayerId: 5,
        scoringPlayerIds: [6],
      },
      {
        inning: 7,
        topHalf: false,
        battingPlayerId: 8,
        scoringPlayerIds: [9],
      },
    ],
    team1: {
      id: 3,
      name: "Marlins",
      logo: "https://cdn-team-logos.theathletic.com/cdn-cgi/image/width=1920,format=auto/https://cdn-team-logos.theathletic.com/team-logo-107-72x72.png?1659417046",
      players: [
        {
          id: 1,
          name: "Player 1",
          position: "Pitcher",
          gameStats: { runs: 3, hits: 2, errors: 0 },
        },
        {
          id: 2,
          name: "Player 2",
          position: "Shortstop",
          gameStats: { runs: 1, hits: 3, errors: 1 },
        },
      ],
      votes: 30,
      gameStats: {
        score: 1,
      },
    },
    team2: {
      id: 4,
      name: "Mariners",
      logo: "https://cdn-team-logos.theathletic.com/cdn-cgi/image/width=1920,format=auto/https://cdn-team-logos.theathletic.com/team-logo-116-72x72.png?1659417063",
      players: [
        {
          id: 3,
          name: "Player 3",
          position: "Pitcher",
          gameStats: { runs: 3, hits: 2, errors: 0 },
        },
        {
          id: 4,
          name: "Player 4",
          position: "Shortstop",
          gameStats: { runs: 1, hits: 3, errors: 1 },
        },
      ],
      votes: 100,
      gameStats: {
        score: 1
      },
    },
  }
];
export const gamesStore = readable(games);

