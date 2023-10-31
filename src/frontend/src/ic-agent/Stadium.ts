import type { Principal } from '@dfinity/principal';
import type { Actor, ActorMethod } from '@dfinity/agent';
import { createActor } from './Actor';
import type { InterfaceFactory } from '@dfinity/candid/lib/cjs/idl';
import { IDL } from '@dfinity/candid';


export type Time = bigint;
export type MatchTeam = {
  'id': Principal,
  'predictionVotes': bigint
};
export type OfferingWithId = {
  'id': number,
  'deities': string[],
  'effects': string[],
};
export type SpecialRuleWithId = {
  'id': number,
  'name': string,
  'description': string,
};
export type TeamState = {
  'id': Principal;
  'score': bigint;
  'offeringId': number;
};
export type OffenseFieldState = {
  'firstBase': [] | [number],
  'secondBase': [] | [number],
  'thirdBase': [] | [number],
  'atBat': number,
};
export type DefenseFieldState = {
  'firstBase': number,
  'secondBase': number,
  'thirdBase': number,
  'pitcher': number,
  'shortStop': number,
  'leftField': number,
  'centerField': number,
  'rightField': number,
};
export type FieldState = {
  'offense': OffenseFieldState,
  'defense': DefenseFieldState,
}
export type Base = {
  'firstBase': null
} | {
  'secondBase': null
} | {
  'thirdBase': null
} | {
  'homeBase': null
};
export type PlayerInjury = {
  'twistedAnkle': null
} | {
  'brokenLeg': null
} | {
  'brokenArm': null
} | {
  'concussion': null
};
export type MatchEndReason = {
  'noMoreRounds': null
} | {
  'outOfPlayers': {
    'team1': null
  } | {
    'team2': null
  } | {
    'bothTeams': null
  }
};
export type MatchEvent = {
  'pitch': {
    'pitchRoll': number,
  }
} | {
  'hit': {
    'hitRoll': number,
  }
} | {
  'run': {
    'base': Base,
    'ballLocation': FieldPosition,
    'runRoll': number,
  }
} | {
  'foul': null
} | {
  'strike': null
} | {
  'out': number
} | {
  'playerMovedBases': {
    'playerId': number,
    'base': Base,
  }
} | {
  'playerInjured': {
    'playerId': number,
    'injury': PlayerInjury,
  }
} | {
  'playerSubstituted': {
    'playerId': number,
  }
} | {
  'score': {
    'teamId': TeamId,
    'amount': number,
  }
} | {
  'endRound': null
} | {
  'endMatch': MatchEndReason
};
export type PlayerCondition = {
  'ok': null
} | {
  'injured': PlayerInjury
} | {
  'dead': null
};
export type PlayerSkills = {
  'battingAccuracy': bigint,
  'battingPower': bigint,
  'throwingAccuracy': bigint,
  'throwingPower': bigint,
  'catching': bigint,
  'defense': bigint,
  'piety': bigint,
  'speed': bigint
};
export type FieldPosition = {
  'pitcher': null
} | {
  'firstBase': null
} | {
  'secondBase': null
} | {
  'thirdBase': null
} | {
  'shortStop': null
} | {
  'leftField': null
} | {
  'centerField': null
} | {
  'rightField': null
};

export type PlayerState = {
  'id': number,
  'name': string;
  'teamId': TeamId;
  'condition': PlayerCondition;
  'skills': PlayerSkills;
  'position': FieldPosition;
};
export type LogEntry = {
  'description': string,
  'isImportant': boolean
}
export type InProgressMatchState = {
  'offenseTeamId': TeamId,
  'team1': TeamState,
  'team2': TeamState,
  'specialRuleId': [] | [number],
  'log': [LogEntry],
  'field': FieldState,
  'round': bigint,
  'outs': bigint,
  'strikes': bigint,
  'players': PlayerState[]
};
export type TeamId = {
  'team1': null
} | {
  'team2': null;
};
export type TeamIdOrTie = TeamId | { 'tie': null };
export type CompletedTeamState = {
  id: Principal;
  score: bigint;
};
export type CompletedMatchResult = {
  team1: CompletedTeamState;
  team2: CompletedTeamState;
  winner: TeamIdOrTie;
  log: [LogEntry];
};
export type CompletedMatchState = {
  'absentTeam': TeamId
} | {
  'allAbsent': null
} | {
  'played': CompletedMatchResult;
};
export type MatchState = {
  'notStarted': null
} | {
  'inProgress': InProgressMatchState
} | {
  'completed': CompletedMatchState;
};
export type StartedMatchState = {
  'inProgress': InProgressMatchState
} | {
  'completed': CompletedMatchState
};
export type TickMatchResult = StartedMatchState | {
  'matchNotFound': null
} | {
  'notStarted': null
};
export type Match = {
  'id': number,
  'stadiumId': Principal,
  'team1': MatchTeam,
  'team2': MatchTeam,
  'time': Time,
  'offerings': OfferingWithId[],
  'specialRules': SpecialRuleWithId[],
  'state': MatchState
};
export type StartMatchResult = {
  'ok': InProgressMatchState
} | {
  'matchNotFound': null
} | {
  'matchAlreadyStarted': null
} | {
  'completed': CompletedMatchState
};

export const OffenseFieldStateIdl = IDL.Record({
  'firstBase': IDL.Opt(IDL.Nat32),
  'secondBase': IDL.Opt(IDL.Nat32),
  'thirdBase': IDL.Opt(IDL.Nat32),
  'atBat': IDL.Nat32,
});
export const DefenseFieldStateIdl = IDL.Record({
  'firstBase': IDL.Nat32,
  'secondBase': IDL.Nat32,
  'thirdBase': IDL.Nat32,
  'pitcher': IDL.Nat32,
  'shortStop': IDL.Nat32,
  'leftField': IDL.Nat32,
  'centerField': IDL.Nat32,
  'rightField': IDL.Nat32
});
export const FieldStateIdl = IDL.Record({
  'defense': DefenseFieldStateIdl,
  'offense': OffenseFieldStateIdl,
});
export const LogEntryIdl = IDL.Record({
  'description': IDL.Text,
  'isImportant': IDL.Bool
});
export const TeamIdIdl = IDL.Variant({
  'team1': IDL.Null,
  'team2': IDL.Null
});
export const TeamStateIdl = IDL.Record({
  'id': IDL.Principal,
  'score': IDL.Int,
  'offeringId': IDL.Nat32,
});
export const PlayerInjuryIdl = IDL.Variant({
  'twistedAnkle': IDL.Null,
  'brokenLeg': IDL.Null,
  'brokenArm': IDL.Null,
  'concussion': IDL.Null
});
export const PlayerConditionIdl = IDL.Variant({
  'ok': IDL.Null,
  'injured': PlayerInjuryIdl,
  'dead': IDL.Null
});
export const PlayerSkillsIdl = IDL.Record({
  'battingAccuracy': IDL.Nat,
  'battingPower': IDL.Nat,
  'throwingAccuracy': IDL.Nat,
  'throwingPower': IDL.Nat,
  'catching': IDL.Nat,
  'defense': IDL.Nat,
  'piety': IDL.Nat,
  'speed': IDL.Nat
});
export const FieldPositionIdl = IDL.Variant({
  'pitcher': IDL.Null,
  'firstBase': IDL.Null,
  'secondBase': IDL.Null,
  'thirdBase': IDL.Null,
  'shortStop': IDL.Null,
  'leftField': IDL.Null,
  'centerField': IDL.Null,
  'rightField': IDL.Null
});
export const PlayerStateIdl = IDL.Record({
  'id': IDL.Nat32,
  'name': IDL.Text,
  'teamId': TeamIdIdl,
  'condition': PlayerConditionIdl,
  'skills': PlayerSkillsIdl,
  'position': FieldPositionIdl
});
export const InProgressStateIdl = IDL.Record({
  'offenseTeamId': TeamIdIdl,
  'team1': TeamStateIdl,
  'team2': TeamStateIdl,
  'specialRuleId': IDL.Opt(IDL.Nat32),
  'log': IDL.Vec(LogEntryIdl),
  'field': FieldStateIdl,
  'players': IDL.Vec(PlayerStateIdl),
  'strikes': IDL.Nat,
  'outs': IDL.Nat,
  'round': IDL.Nat,
});
export const CompletedTeamStateIdl = IDL.Record({
  'id': IDL.Principal,
  'score': IDL.Int
});
export const TeamIdOrTieIdl = IDL.Variant({
  'team1': IDL.Null,
  'team2': IDL.Null,
  'tie': IDL.Null
});
export const CompletedMatchResultIdl = IDL.Record({
  'team1': CompletedTeamStateIdl,
  'team2': CompletedTeamStateIdl,
  'winner': TeamIdOrTieIdl,
  'log': IDL.Vec(LogEntryIdl),
});
export const CompletedStateIdl = IDL.Variant({
  'absentTeam': TeamIdIdl,
  'allAbsent': IDL.Null,
  'played': CompletedMatchResultIdl
});
export const MatchTeamInfoIdl = IDL.Record({
  'id': IDL.Principal,
  'name': IDL.Text,
  'predictionVotes': IDL.Nat
});
export const OfferingWithIdIdl = IDL.Record({
  'id': IDL.Nat32,
  'deities': IDL.Vec(IDL.Text),
  'effects': IDL.Vec(IDL.Text),
});
export const SpecialRuleWithIdIdl = IDL.Record({
  'id': IDL.Nat32,
  'name': IDL.Text,
  'description': IDL.Text,
});
export const BaseIdl = IDL.Variant({
  'firstBase': IDL.Null,
  'secondBase': IDL.Null,
  'thirdBase': IDL.Null,
  'homeBase': IDL.Null
});
export const StartedMatchStateIdl = IDL.Variant({
  'inProgress': InProgressStateIdl,
  'completed': CompletedStateIdl
});
export const MatchStateIdl = IDL.Variant({
  'notStarted': IDL.Null,
  'inProgress': InProgressStateIdl,
  'completed': CompletedStateIdl
});
export const MatchIdl = IDL.Record({
  'id': IDL.Nat32,
  'stadiumId': IDL.Principal,
  'team1': MatchTeamInfoIdl,
  'team2': MatchTeamInfoIdl,
  'time': IDL.Int,
  'offerings': IDL.Vec(OfferingWithIdIdl),
  'specialRules': IDL.Vec(SpecialRuleWithIdIdl),
  'state': MatchStateIdl
});
export const TickMatchResultIdl = IDL.Variant({
  'ok': InProgressStateIdl,
  'matchNotFound': IDL.Null,
  'completed': CompletedStateIdl,
  'notStarted': IDL.Null
});
export const StartMatchResultIdl = IDL.Variant({
  'ok': InProgressStateIdl,
  'matchNotFound': IDL.Null,
  'matchAlreadyStarted': IDL.Null,
  'completed': CompletedStateIdl
});


export interface _SERVICE {
  'getMatches': ActorMethod<[], Match[]>,
  'getMatch': ActorMethod<[number], [] | [Match]>,
  'tickMatch': ActorMethod<[number], TickMatchResult>,
  'startMatch': ActorMethod<[number], StartMatchResult>
}
export const idlFactory: InterfaceFactory = ({ IDL }) => {
  return IDL.Service({
    'getMatches': IDL.Func([], [IDL.Vec(MatchIdl)], ['query']),
    'getMatch': IDL.Func([IDL.Nat32], [IDL.Opt(MatchIdl)], ['query']),
    'tickMatch': IDL.Func([IDL.Nat32], [TickMatchResultIdl], []),
    'startMatch': IDL.Func([IDL.Nat32], [StartMatchResultIdl], [])
  });
};
export const stadiumAgentFactory = (canisterId: string | Principal) => createActor<_SERVICE>(canisterId, idlFactory);