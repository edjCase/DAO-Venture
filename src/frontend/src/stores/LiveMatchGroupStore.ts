import { writable } from "svelte/store";
import { BaseState, MatchGroupWithId, MatchLog, PlayerStateWithId, TeamId, TeamState, TickResult } from "../ic-agent/declarations/stadium";
import { nanosecondsToDate } from "../utils/DateUtils";
import { scheduleStore } from "./ScheduleStore";
import { TeamDetailsWithScore } from "../models/Match";
import { MatchAura, SeasonStatus, TeamIdOrTie, TeamPositions } from "../ic-agent/declarations/league";
import { stadiumAgentFactory } from "../ic-agent/Stadium";

export type LiveMatchGroup = {
  id: bigint;
  matches: LiveMatch[];
};

export type LiveTeamDetails = TeamDetailsWithScore & {
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
      score: team.score,
      positions: team.positions,
      color: team.color
    }
  };

  const mapTickResult = (tickResult: TickResult): LiveMatch => {
    let liveState: LiveMatchState | undefined;
    let winner: TeamIdOrTie | undefined;
    if ('inProgress' in tickResult.status) {
      liveState = {
        offenseTeamId: tickResult.match.offenseTeamId,
        players: tickResult.match.players,
        bases: tickResult.match.bases,
        round: tickResult.match.log.rounds.length,
        outs: Number(tickResult.match.outs),
        strikes: Number(tickResult.match.strikes)
      }
    } else {
      liveState = undefined;
      winner = undefined; // TODO
    }
    return {
      team1: mapTeam(tickResult.match.team1),
      team2: mapTeam(tickResult.match.team2),
      liveState: liveState,
      log: tickResult.match.log,
      winner: winner,
      aura: tickResult.match.aura
    };
  };


  const refetchMatchGroup = async (matchGroupId: bigint) => {
    stadiumAgentFactory()
      .getMatchGroup(matchGroupId)
      .then((matchGroupOrNull: [MatchGroupWithId] | []) => {
        if (matchGroupOrNull.length === 0) {
          return;
        }
        let matchGroup = matchGroupOrNull[0];
        set({
          id: matchGroupId,
          matches: matchGroup.matches.map(mapTickResult)
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
        refetchMatchGroup(BigInt(index));
        liveMatchInterval = setInterval(
          () => refetchMatchGroup(BigInt(index)),
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


