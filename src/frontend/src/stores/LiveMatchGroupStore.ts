import { writable } from "svelte/store";
import { LiveBaseState, MatchLog, LivePlayerState, TeamId, LiveMatchStateWithStatus, LiveMatchTeam, } from "../ic-agent/declarations/main";
import { nanosecondsToDate } from "../utils/DateUtils";
import { scheduleStore } from "./ScheduleStore";
import { TeamDetailsWithScore } from "../models/Match";
import { MatchAura, SeasonStatus, TeamIdOrTie, TeamPositions } from "../ic-agent/declarations/main";
import { mainAgentFactory } from "../ic-agent/Main";

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
  players: LivePlayerState[];
  bases: LiveBaseState;
  round: number;
  outs: number;
  strikes: number;
};

export const liveMatchGroupStore = (() => {
  const { subscribe, set } = writable<LiveMatchGroup | undefined>();
  let nextMatchTimeout: any;
  let liveMatchInterval: any;

  const mapTeam = (team: LiveMatchTeam): LiveTeamDetails => {
    return {
      id: team.id,
      name: team.name,
      logoUrl: team.logoUrl,
      score: team.score,
      positions: team.positions,
      color: team.color
    }
  };

  const mapTickResult = (tickResult: LiveMatchStateWithStatus): LiveMatch => {
    let liveState: LiveMatchState | undefined;
    let winner: TeamIdOrTie | undefined;
    if ('inProgress' in tickResult.status) {
      liveState = {
        offenseTeamId: tickResult.offenseTeamId,
        players: tickResult.players,
        bases: tickResult.bases,
        round: tickResult.log.rounds.length,
        outs: Number(tickResult.outs),
        strikes: Number(tickResult.strikes)
      }
    } else {
      liveState = undefined;
      winner = undefined; // TODO
    }
    return {
      team1: mapTeam(tickResult.team1),
      team2: mapTeam(tickResult.team2),
      liveState: liveState,
      log: tickResult.log,
      winner: winner,
      aura: tickResult.aura
    };
  };


  const refetchMatchGroup = async (matchGroupId: bigint) => {
    let mainAgent = await mainAgentFactory();
    let matchGroupOrNull = await mainAgent
      .getLiveMatchGroupState();
    if (matchGroupOrNull.length === 0) {
      set(undefined);
      return;
    }
    let matchGroup = matchGroupOrNull[0];
    set({
      id: matchGroupId,
      matches: matchGroup.matches.map(mapTickResult)
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


