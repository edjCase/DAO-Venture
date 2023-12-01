import { writable } from "svelte/store";
import { leagueAgentFactory } from "../ic-agent/League";
import {
    CompletedMatch,
    InProgressMatch,
    InProgressSeasonMatchGroupVariant,
    NotScheduledMatch,
    ScheduledMatch,
    SeasonStatus,
    TeamInfo
} from "../models/Season";
import { MatchDetails, MatchGroupDetails, MatchState } from "../models/Match";
import { TeamIdOrTie } from "../models/Team";

type MatchVariant =
    | { completed: CompletedMatch }
    | { inProgress: InProgressMatch }
    | { scheduled: ScheduledMatch }
    | { notScheduled: NotScheduledMatch };

export const scheduleStore = (() => {
    const { subscribe: subscribeStatus, set: setStatus } = writable<SeasonStatus | undefined>();
    const { subscribe: subscribeMatchGroups, set: setMatchGroups } = writable<MatchGroupDetails[]>([]);

    const mapTeam = (team: TeamInfo, score: bigint | undefined) => {
        return {
            id: team.id,
            name: team.name,
            logoUrl: team.logoUrl,
            score: score
        };
    };

    const mapMatch = (
        index: number,
        matchGroupId: bigint,
        time: bigint,
        match: MatchVariant
    ): MatchDetails => {
        if ('completed' in match) {
            let team1Score: bigint | undefined;
            let team2Score: bigint | undefined;
            let winner: TeamIdOrTie | undefined;
            let state: MatchState;
            if ('played' in match.completed.result) {
                team1Score = match.completed.result.played.team1Score;
                team2Score = match.completed.result.played.team2Score;
                winner = match.completed.result.played.winner;
                state = "Played";
            } else if ('allAbsent' in match.completed.result) {
                state = "AllAbsent";
            } else if ('absentTeam' in match.completed.result) {
                if ('team1' in match.completed.result.absentTeam) {
                    state = "Team1Absent";
                } else {
                    state = "Team2Absent";
                }
            } else {
                state = "Error";
            }

            return {
                id: BigInt(index),
                time: time,
                matchGroupId: matchGroupId,
                state: state,
                offerings: undefined,
                team1: mapTeam(match.completed.team1, team1Score),
                team2: mapTeam(match.completed.team2, team2Score),
                winner: winner
            };
        } else if ('inProgress' in match) {
            return {
                id: BigInt(index),
                time: time,
                matchGroupId: matchGroupId,
                state: 'InProgress',
                offerings: undefined,
                team1: mapTeam(match.inProgress.team1, undefined),
                team2: mapTeam(match.inProgress.team2, undefined),
                winner: undefined
            };
        }
        else if ('scheduled' in match) {
            return {
                id: BigInt(index),
                time: time,
                matchGroupId: matchGroupId,
                state: 'Scheduled',
                offerings: match.scheduled.offerings,
                team1: mapTeam(match.scheduled.team1, undefined),
                team2: mapTeam(match.scheduled.team2, undefined),
                winner: undefined
            };
        }
        else {
            return {
                id: BigInt(index),
                time: time,
                matchGroupId: matchGroupId,
                state: 'NotScheduled',
                offerings: undefined,
                team1: mapTeam(match.notScheduled.team1, undefined),
                team2: mapTeam(match.notScheduled.team2, undefined),
                winner: undefined
            };
        }
    };

    const mapMatchGroup = (matchGroupIndex: number, matchGroup: InProgressSeasonMatchGroupVariant): MatchGroupDetails => {
        let id = BigInt(matchGroupIndex);
        if ('completed' in matchGroup) {
            return {
                id: id,
                time: matchGroup.completed.time,
                matches: matchGroup.completed.matches.map((match, matchIndex) => (mapMatch(matchIndex, id, matchGroup.completed.time, { completed: match }))),
                state: 'Completed'
            };
        } else if ('inProgress' in matchGroup) {
            return {
                id: id,
                time: matchGroup.inProgress.time,
                matches: matchGroup.inProgress.matches.map((match, matchIndex) => (mapMatch(matchIndex, id, matchGroup.inProgress.time, { inProgress: match }))),
                state: 'InProgress'
            };
        } else if ('scheduled' in matchGroup) {
            return {
                id: id,
                time: matchGroup.scheduled.time,
                matches: matchGroup.scheduled.matches.map((match, matchIndex) => (mapMatch(matchIndex, id, matchGroup.scheduled.time, { scheduled: match }))),
                state: 'Scheduled'
            };
        } else {
            return {
                id: id,
                time: matchGroup.notScheduled.time,
                matches: matchGroup.notScheduled.matches.map((match, matchIndex) => (mapMatch(matchIndex, id, matchGroup.notScheduled.time, { notScheduled: match }))),
                state: 'NotScheduled'
            };
        }
    };

    const refetch = async () => {
        return leagueAgentFactory()
            .getSeasonStatus()
            .then((status: SeasonStatus) => {
                setStatus(status);
                let matchGroups: MatchGroupDetails[] = [];
                if ('inProgress' in status) {
                    matchGroups = status.inProgress.matchGroups.map((matchGroup, index) => {
                        return mapMatchGroup(index, matchGroup);
                    });
                } else if ('completed' in status) {
                    matchGroups = status.completed.matchGroups.map((matchGroup, index) => {
                        return mapMatchGroup(index, { completed: matchGroup });
                    });
                } else {
                    matchGroups = [];
                }
                setMatchGroups(matchGroups);
            });
    };

    refetch();


    return {
        subscribeStatus,
        subscribeMatchGroups,
        refetch
    };
})();


