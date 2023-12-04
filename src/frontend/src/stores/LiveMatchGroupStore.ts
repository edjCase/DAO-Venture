import { writable } from "svelte/store";
import { FieldState, LogEntry, MatchGroup, MatchVariant, PlayerState, Team, stadiumAgentFactory } from "../ic-agent/Stadium";
import { nanosecondsToDate } from "../utils/DateUtils";
import { Principal } from "@dfinity/principal";
import { SeasonStatus } from "../models/Season";
import { scheduleStore } from "./ScheduleStore";
import { TeamId, TeamIdOrTie } from "../models/Team";
import { TeamDetails } from "../models/Match";
import { MatchAura } from "../models/MatchAura";
import { Offering } from "../models/Offering";

export type LiveMatchGroup = {
  id: number;
  matches: LiveMatch[];
};

export type LiveMatch = {
  team1: TeamDetails;
  team2: TeamDetails;
  state: LiveMatchState
  log: LogEntry[];
  winner: TeamIdOrTie | undefined;
};

export type LiveMatchState =
  | { inProgress: InProgressMatchState }
  | { played: PlayedMatchState }
  | { absentTeam: TeamId }
  | { allAbsent: null }
  | { error: string };

export type PlayedMatchState = {
  team1Offering: Offering;
  team2Offering: Offering;
  team1ChampionId: number;
  team2ChampionId: number;
};

export type InProgressMatchState = {
  offenseTeamId: TeamId;
  aura: MatchAura;
  players: PlayerState[];
  field: FieldState;
  round: number;
  outs: number;
  strikes: number;
  team1Offering: Offering;
  team1ChampionId: number;
  team2Offering: Offering;
  team2ChampionId: number;
};

export const liveMatchGroupStore = (() => {
  const { subscribe, set } = writable<LiveMatchGroup | undefined>();
  let nextMatchTimeout: NodeJS.Timeout;
  let liveMatchInterval: NodeJS.Timeout;

  const mapTeam = (team: Team, score: bigint | undefined): TeamDetails => {
    return {
      id: team.id,
      name: team.name,
      logoUrl: team.logoUrl,
      score: score,
    }
  };

  const mapLiveMatch = (match: MatchVariant): LiveMatch => {
    if ('inProgress' in match) {
      return {
        team1: mapTeam(match.inProgress.team1, match.inProgress.team1.score),
        team2: mapTeam(match.inProgress.team2, match.inProgress.team2.score),
        state: {
          inProgress: {
            offenseTeamId: match.inProgress.offenseTeamId,
            aura: match.inProgress.aura,
            players: match.inProgress.players,
            field: match.inProgress.field,
            round: Number(match.inProgress.round),
            outs: Number(match.inProgress.outs),
            strikes: Number(match.inProgress.strikes),
            team1Offering: match.inProgress.team1.offering,
            team1ChampionId: match.inProgress.team1.championId,
            team2Offering: match.inProgress.team2.offering,
            team2ChampionId: match.inProgress.team2.championId,
          }
        },
        log: match.inProgress.log,
        winner: undefined
      };
    } else {
      let state: LiveMatchState;
      let team1Score;
      let team2Score;
      let winner;
      if ('played' in match.completed.result) {
        state = {
          played: {
            team1ChampionId: match.completed.result.played.team1.championId,
            team1Offering: match.completed.result.played.team1.offering,
            team2ChampionId: match.completed.result.played.team2.championId,
            team2Offering: match.completed.result.played.team2.offering,
          }
        }
        team1Score = match.completed.result.played.team1.score;
        team2Score = match.completed.result.played.team2.score;
        winner = match.completed.result.played.winner;
      } else if ('absentTeam' in match.completed.result) {
        state = { absentTeam: match.completed.result.absentTeam }
      } else if ('allAbsent' in match.completed.result) {
        state = { allAbsent: null }
      } else {
        state = { error: JSON.stringify(match.completed.result.stateBroken) }
      }
      return {
        team1: mapTeam(match.completed.team1, team1Score),
        team2: mapTeam(match.completed.team2, team2Score),
        state: state,
        log: match.completed.log,
        winner: winner
      };
    }
  };


  const refetchMatchGroup = async (stadiumId: Principal, matchGroupId: number) => {
    stadiumAgentFactory(stadiumId)
      .getMatchGroup(BigInt(matchGroupId))
      .then((matchGroupOrNull: [MatchGroup] | []) => {
        if (matchGroupOrNull.length === 0) {
          return;
        }
        let matchGroup = matchGroupOrNull[0];
        set({
          id: matchGroupId,
          matches: matchGroup.matches.map(mapLiveMatch)
        });
      });
  };


  scheduleStore.subscribeStatus((status: SeasonStatus | undefined) => {
    if (!status) {
      return;
    }
    if ('notStarted' in status || 'starting' in status || 'completed' in status) {
      if (liveMatchInterval) {
        clearInterval(liveMatchInterval);
      }
      if (nextMatchTimeout) {
        clearTimeout(nextMatchTimeout);
      }
      return;
    }
    // Find next one that is live or scheduled
    for (let [index, matchGroup] of status.inProgress.matchGroups.entries()) {
      if ('inProgress' in matchGroup) {
        // If live, then set a recurring timer for every 5 seconds
        if (liveMatchInterval) {
          clearInterval(liveMatchInterval);
        }
        let stadiumId = matchGroup.inProgress.stadiumId;
        refetchMatchGroup(stadiumId, index);
        liveMatchInterval = setInterval(
          () => refetchMatchGroup(stadiumId, index),
          5000
        );
        // Dont break, to set next match timer
      } else if ('scheduled' in matchGroup) {
        // Set a timer for 
        if (nextMatchTimeout) {
          clearTimeout(nextMatchTimeout);
        }
        let waitMillis = nanosecondsToDate(matchGroup.scheduled.time).getTime() - Date.now();
        nextMatchTimeout = setTimeout(() => scheduleStore.refetch(), waitMillis);
        break;
      } else {
        // Match group is completed, skip
        continue;
      }
    }
  });


  return {
    subscribe
  };
})();


