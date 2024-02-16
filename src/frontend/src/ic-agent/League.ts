import type { Principal } from '@dfinity/principal';
import { IDL } from "@dfinity/candid";
import { ActorMethod } from '@dfinity/agent';
import { InterfaceFactory } from '@dfinity/candid/lib/cjs/idl';
import { createActor } from './Actor';
import { Team, TeamId, TeamIdIdl, TeamIdOrBoth, TeamIdOrBothIdl, TeamIdOrTie, TeamIdOrTieIdl, TeamIdl } from '../models/Team';
import { SeasonStatus, SeasonStatusIdl } from '../models/Season';
import { ScenarioTemplate, ScenarioTemplateIdl, EffectOutcome, EffectOutcomeIdl, ScenarioInstanceWithChoice, ScenarioInstanceWithChoiceIdl } from '../models/Scenario';

export type Time = bigint;
export const TimeIdl = IDL.Int;
export type Nat = bigint;
export type Nat32 = number;
export type Int = number;
export type Bool = boolean;
export type Text = string;

export type ProcessEffectOutcomesRequest = {
  outcomes: EffectOutcome[];
};
export const ProcessEffectOutcomesRequestIdl = IDL.Record({
  outcomes: IDL.Vec(EffectOutcomeIdl),
});

export type ProcessEffectOutcomesResult =
  | { ok: null }
  | { notAuthorized: null }
  | { seasonNotInProgress: null };
export const ProcessEffectOutcomesResultIdl = IDL.Variant({
  ok: IDL.Null,
  notAuthorized: IDL.Null,
  seasonNotInProgress: IDL.Null,
});

export type AddScenarioTemplateRequest = ScenarioTemplate;
export const AddScenarioTemplateRequestIdl = ScenarioTemplateIdl;

export type AddScenarioTemplateResult =
  | { ok: null }
  | { idTaken: null }
  | { notAuthorized: null };
export const AddScenarioTemplateResultIdl = IDL.Variant({
  ok: IDL.Null,
  idTaken: IDL.Null,
  notAuthorized: IDL.Null,
});

export type UpcomingMatchPrediction = {
  team1: Nat;
  team2: Nat;
  yourVote: TeamId | null;
};
export const UpcomingMatchPredictionIdl = IDL.Record({
  team1: IDL.Nat,
  team2: IDL.Nat,
  yourVote: IDL.Opt(TeamIdIdl),
});

export type UpcomingMatchPredictionsResult =
  | { ok: UpcomingMatchPrediction[] }
  | { noUpcomingMatches: null };
export const UpcomingMatchPredictionsResultIdl = IDL.Variant({
  ok: IDL.Vec(UpcomingMatchPredictionIdl),
  noUpcomingMatches: IDL.Null,
});

export type PredictMatchOutcomeRequest = {
  matchId: Nat32;
  winner: TeamId | null;
};
export const PredictMatchOutcomeRequestIdl = IDL.Record({
  matchId: IDL.Nat32,
  winner: IDL.Opt(TeamIdIdl),
});

export type PredictMatchOutcomeResult =
  | { ok: null }
  | { matchGroupNotFound: null }
  | { matchNotFound: null }
  | { predictionsClosed: null }
  | { identityRequired: null };
export const PredictMatchOutcomeResultIdl = IDL.Variant({
  ok: IDL.Null,
  matchGroupNotFound: IDL.Null,
  matchNotFound: IDL.Null,
  predictionsClosed: IDL.Null,
  identityRequired: IDL.Null,
});

export type StartMatchError =
  | { notEnoughPlayers: TeamIdOrBoth };
export const StartMatchErrorIdl = IDL.Variant({
  notEnoughPlayers: TeamIdOrBothIdl,
});

export type StartMatchGroupResult =
  | { ok: null }
  | { matchGroupNotFound: null }
  | { notAuthorized: null }
  | { notScheduledYet: null }
  | { alreadyStarted: null }
  | { matchErrors: { matchId: Nat; error: StartMatchError }[] };
export const StartMatchGroupResultIdl = IDL.Variant({
  ok: IDL.Null,
  matchGroupNotFound: IDL.Null,
  notAuthorized: IDL.Null,
  notScheduledYet: IDL.Null,
  alreadyStarted: IDL.Null,
  matchErrors: IDL.Vec(IDL.Record({ matchId: IDL.Nat, error: StartMatchErrorIdl })),
});

export type PlayedMatchTeamData = {
  score: Int;
  scenario: ScenarioInstanceWithChoice;
};
export const PlayedMatchTeamDataIdl = IDL.Record({
  score: IDL.Int,
  scenario: ScenarioInstanceWithChoiceIdl,
});

export type PlayedMatchResult = {
  team1: PlayedMatchTeamData;
  team2: PlayedMatchTeamData;
  winner: TeamIdOrTie;
};
export const PlayedMatchResultIdl = IDL.Record({
  team1: PlayedMatchTeamDataIdl,
  team2: PlayedMatchTeamDataIdl,
  winner: TeamIdOrTieIdl,
});

export type FailedMatchResult = {
  message: Text;
};
export const FailedMatchResultIdl = IDL.Record({
  message: IDL.Text,
});


export type OnMatchGroupCompleteResult =
  | { ok: null }
  | { seasonNotOpen: null }
  | { matchGroupNotFound: null }
  | { matchGroupNotInProgress: null }
  | { seedGenerationError: Text }
  | { notAuthorized: null };
export const OnMatchGroupCompleteResultIdl = IDL.Variant({
  ok: IDL.Null,
  seasonNotOpen: IDL.Null,
  matchGroupNotFound: IDL.Null,
  matchGroupNotInProgress: IDL.Null,
  seedGenerationError: IDL.Text,
  notAuthorized: IDL.Null,
});

export type CreateTeamRequest = {
  name: Text;
  logoUrl: Text;
  motto: Text;
  description: Text;
  color: [number, number, number];
};
export const CreateTeamRequestIdl = IDL.Record({
  name: IDL.Text,
  logoUrl: IDL.Text,
  motto: IDL.Text,
  description: IDL.Text,
  color: IDL.Tuple(IDL.Nat8, IDL.Nat8, IDL.Nat8),
});

export type CreateTeamResult =
  | { ok: Principal }
  | { nameTaken: null }
  | { noStadiumsExist: null }
  | { teamFactoryCallError: Text }
  | { notAuthorized: null }
  | { populateTeamRosterCallError: Text };
export const CreateTeamResultIdl = IDL.Variant({
  ok: IDL.Principal,
  nameTaken: IDL.Null,
  noStadiumsExist: IDL.Null,
  teamFactoryCallError: IDL.Text,
  notAuthorized: IDL.Null,
  populateTeamRosterCallError: IDL.Text,
});

export type StartSeasonRequest = {
  startTime: Time;
};
export const StartSeasonRequestIdl = IDL.Record({
  startTime: TimeIdl,
});

export type StartSeasonResult =
  | { ok: null }
  | { alreadyStarted: null }
  | { noStadiumsExist: null }
  | { seedGenerationError: Text }
  | { noTeams: null }
  | { oddNumberOfTeams: null }
  | { notAuthorized: null };
export const StartSeasonResultIdl = IDL.Variant({
  ok: IDL.Null,
  alreadyStarted: IDL.Null,
  noStadiumsExist: IDL.Null,
  seedGenerationError: IDL.Text,
  noTeams: IDL.Null,
  oddNumberOfTeams: IDL.Null,
  notAuthorized: IDL.Null,
});

export type CloseSeasonResult =
  | { ok: null }
  | { notAuthorized: null }
  | { seasonNotOpen: null };
export const CloseSeasonResultIdl = IDL.Variant({
  ok: IDL.Null,
  notAuthorized: IDL.Null,
  seasonNotOpen: IDL.Null,
});

export type SetUserIsAdminResult =
  | { ok: null }
  | { notAuthorized: null };
export const SetUserIsAdminResultIdl = IDL.Variant({
  ok: IDL.Null,
  notAuthorized: IDL.Null,
});

export type UpdateLeagueCanistersResult =
  | { ok: null }
  | { notAuthorized: null };
export const UpdateLeagueCanistersResultIdl = IDL.Variant({
  ok: IDL.Null,
  notAuthorized: IDL.Null,
});

export interface _SERVICE {
  'getTeams': ActorMethod<[], Array<Team>>,
  'getSeasonStatus': ActorMethod<[], SeasonStatus>,
  'getScenarioTemplates': ActorMethod<[], Array<ScenarioTemplate>>,
  'addScenarioTemplate': ActorMethod<[AddScenarioTemplateRequest], AddScenarioTemplateResult>,
  'processEventOutcomes': ActorMethod<[ProcessEffectOutcomesRequest], ProcessEffectOutcomesResult>,
  'startSeason': ActorMethod<[StartSeasonRequest], StartSeasonResult>,
  'closeSeason': ActorMethod<[], CloseSeasonResult>,
  'createTeam': ActorMethod<[CreateTeamRequest], CreateTeamResult>,
  'predictMatchOutcome': ActorMethod<[PredictMatchOutcomeRequest], PredictMatchOutcomeResult>,
  'getUpcomingMatchPredictions': ActorMethod<[], UpcomingMatchPredictionsResult>,
  'updateLeagueCanisters': ActorMethod<[], UpdateLeagueCanistersResult>,
  'startMatchGroup': ActorMethod<[Nat], StartMatchGroupResult>,
  'setUserIsAdmin': ActorMethod<[Principal, Bool], SetUserIsAdminResult>,
  'getAdmins': ActorMethod<[], Array<Principal>>,
}

export const idlFactory: InterfaceFactory = ({ }) => {
  return IDL.Service({
    'getTeams': IDL.Func([], [IDL.Vec(TeamIdl)], ['query']),
    'getSeasonStatus': IDL.Func([], [SeasonStatusIdl], ['query']),
    'getScenarioTemplates': IDL.Func([], [IDL.Vec(ScenarioTemplateIdl)], ['query']),
    'addScenarioTemplate': IDL.Func([AddScenarioTemplateRequestIdl], [AddScenarioTemplateResultIdl], []),
    'processEventOutcomes': IDL.Func([ProcessEffectOutcomesRequestIdl], [ProcessEffectOutcomesResultIdl], []),
    'startSeason': IDL.Func([StartSeasonRequestIdl], [StartSeasonResultIdl], []),
    'closeSeason': IDL.Func([], [CloseSeasonResultIdl], []),
    'createTeam': IDL.Func([CreateTeamRequestIdl], [CreateTeamResultIdl], []),
    'predictMatchOutcome': IDL.Func([PredictMatchOutcomeRequestIdl], [PredictMatchOutcomeResultIdl], []),
    'getUpcomingMatchPredictions': IDL.Func([], [UpcomingMatchPredictionsResultIdl], ['query']),
    'updateLeagueCanisters': IDL.Func([], [UpdateLeagueCanistersResultIdl], []),
    'startMatchGroup': IDL.Func([IDL.Nat], [StartMatchGroupResultIdl], []),
    'setUserIsAdmin': IDL.Func([IDL.Principal, IDL.Bool], [SetUserIsAdminResultIdl], []),
    'getAdmins': IDL.Func([], [IDL.Vec(IDL.Principal)], ['query']),
  });
};

const canisterId = process.env.CANISTER_ID_LEAGUE || "";
export let leagueAgentFactory = () => createActor<_SERVICE>(canisterId, idlFactory);
