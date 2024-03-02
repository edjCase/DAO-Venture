import { writable } from "svelte/store";
import { BaseState, MatchLog, PlayerStateWithId, TeamId, TeamState } from "../ic-agent/declarations/stadium";
import { nanosecondsToDate } from "../utils/DateUtils";
import { Principal } from "@dfinity/principal";
import { scheduleStore } from "./ScheduleStore";
import { TeamDetails } from "../models/Match";
import { MatchAura, ResolvedScenario, SeasonStatus, TeamIdOrTie, TeamPositions } from "../ic-agent/declarations/league";
import { stadiumAgentFactory } from "../ic-agent/Stadium";

export type LiveMatchGroup = {
  id: number;
  matches: LiveMatch[];
};

export type LiveTeamDetails = TeamDetails & {
  scenario: ResolvedScenario;
  positions: TeamPositions
};

export type LiveMatch = {
  team1: LiveTeamDetails;
  team2: LiveTeamDetails;
  aura: MatchAura;
  liveState: LiveMatchState | undefined
  log: MatchLog | undefined;
  winner: TeamIdOrTie | undefined;
};


export type LiveMatchState = {
  offenseTeamId: TeamId;
  players: PlayerStateWithId[];
  bases: BaseState;
  round: number;
  outs: number;
  strikes: number;
};

export const liveMatchGroupStore = (() => {
  const { subscribe, set } = writable<LiveMatchGroup | undefined>();
  let nextMatchTimeout: any;
  let liveMatchInterval: any;

  const mapTeam = (team: TeamState): LiveTeamDetails => {
    return {
      id: team.id,
      name: team.name,
      logoUrl: team.logoUrl,
      score: Number(team.score),
      scenario: team.scenario,
      positions: team.positions
    }
  };

  const mapLiveMatch = (match: MatchVariant): LiveMatch => {
    if ('inProgress' in match) {
      return {
        team1: mapTeam(match.inProgress.team1),
        team2: mapTeam(match.inProgress.team2),
        liveState: {
          offenseTeamId: match.inProgress.offenseTeamId,
          players: match.inProgress.players,
          bases: match.inProgress.bases,
          round: match.inProgress.log.rounds.length,
          outs: Number(match.inProgress.outs),
          strikes: Number(match.inProgress.strikes)
        },
        log: match.inProgress.log,
        winner: undefined,
        aura: match.inProgress.aura
      };
    } else {
      return {
        team1: mapTeam(match.completed.team1),
        team2: mapTeam(match.completed.team2),
        liveState: undefined,
        log: undefined,
        winner: match.completed.winner,
        aura: match.completed.aura
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


