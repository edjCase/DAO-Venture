import { writable } from "svelte/store";
import { FieldState, LogEntry, MatchGroup, MatchVariant, PlayerState, stadiumAgentFactory } from "../ic-agent/Stadium";
import { nanosecondsToDate } from "../utils/DateUtils";
import { Principal } from "@dfinity/principal";
import { SeasonStatus } from "../models/Season";
import { scheduleStore } from "./ScheduleStore";
import { TeamId, TeamIdOrTie } from "../models/Team";
import { TeamDetails } from "../models/Match";
import { MatchAura } from "../models/MatchAura";

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
  | {
    inProgress: {
      offenseTeamId: TeamId;
      aura: MatchAura;
      players: PlayerState[];
      field: FieldState;
      round: number;
      outs: number;
      strikes: number;
    }
  }
  | {
    played: {

    }
  }
  | { absentTeam: TeamId }
  | { allAbsent: null };

export const liveMatchGroupStore = (() => {
  const { subscribe, set } = writable<LiveMatchGroup | undefined>();
  let nextMatchTimeout: NodeJS.Timeout;
  let liveMatchInterval: NodeJS.Timeout;

  const mapLiveMatch = (match: MatchVariant): LiveMatch => {
    if ('inProgress' in match) {
      return {
        team1: match.inProgress.team1,
        team2: match.inProgress.team2,
        state: {
          inProgress: {
            offenseTeamId: match.inProgress.offenseTeamId,
            aura: match.inProgress.aura,
            players: match.inProgress.players,
            field: match.inProgress.field,
            round: Number(match.inProgress.round),
            outs: Number(match.inProgress.outs),
            strikes: Number(match.inProgress.strikes),
          }
        },
        log: match.inProgress.log,
        winner: undefined
      };
    } else {
      if ('played' in match.completed) {
        return {
          team1: match.completed.played.team1,
          team2: match.completed.played.team2,
          state: {
            played: {

            }
          },
          log: match.completed.played.log,
          winner: match.completed.played.winner
        };
      } else if ('absentTeam' in match.completed) {
        return {
          team1: match.completed,
          team2: match.team2,
          state: {
            absentTeam: match.absentTeam
          },
          log: [],
          winner: undefined
        };
      } else if ('allAbsent' in match.completed) {
        return {
          team1: match.completed.,
          team2: match.team2,
          state: {
            allAbsent: null
          },
          log: [],
          winner: undefined
        };
      } else {
        return {
          team1: match.team1,
          team2: match.team2,
          state: {
            absentTeam: match.absentTeam
          },
          log: [],
          winner: undefined
        }
      }
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


