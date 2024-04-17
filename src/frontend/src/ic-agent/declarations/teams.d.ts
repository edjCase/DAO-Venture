import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';
import type { IDL } from '@dfinity/candid';

export interface ChangeColorContent { 'color' : [number, number, number] }
export interface ChangeDescriptionContent { 'description' : string }
export interface ChangeLogoContent { 'logoUrl' : string }
export interface ChangeMottoContent { 'motto' : string }
export interface ChangeNameContent { 'name' : string }
export interface CreateProposalRequest { 'content' : ProposalContent }
export type CreateProposalResult = { 'ok' : bigint } |
  { 'notAuthorized' : null } |
  { 'teamNotFound' : null };
export type CreateTeamRequest = {};
export type CreateTeamResult = { 'ok' : { 'id' : bigint } } |
  { 'notAuthorized' : null };
export interface EnergyDividend { 'teamId' : bigint, 'energy' : bigint }
export type FieldPosition = { 'rightField' : null } |
  { 'leftField' : null } |
  { 'thirdBase' : null } |
  { 'pitcher' : null } |
  { 'secondBase' : null } |
  { 'shortStop' : null } |
  { 'centerField' : null } |
  { 'firstBase' : null };
export type GetCyclesResult = { 'ok' : bigint } |
  { 'notAuthorized' : null };
export type GetLinksResult = { 'ok' : Array<TeamLinks> };
export type GetProposalResult = { 'ok' : Proposal } |
  { 'proposalNotFound' : null } |
  { 'teamNotFound' : null };
export type GetProposalsResult = { 'ok' : PagedResult } |
  { 'teamNotFound' : null };
export interface GetScenarioVoteRequest { 'scenarioId' : bigint }
export type GetScenarioVoteResult = { 'ok' : ScenarioVote } |
  { 'notEligible' : null } |
  { 'scenarioNotFound' : null };
export interface GetScenarioVotingResultsRequest { 'scenarioId' : bigint }
export type GetScenarioVotingResultsResult = { 'ok' : ScenarioVotingResults } |
  { 'notAuthorized' : null } |
  { 'scenarioNotFound' : null };
export interface Link { 'url' : string, 'name' : string }
export interface ModifyLinkContent { 'url' : [] | [string], 'name' : string }
export interface OnScenarioEndRequest {
  'scenarioId' : bigint,
  'energyDividends' : Array<EnergyDividend>,
}
export type OnScenarioEndResult = { 'ok' : null } |
  { 'notAuthorized' : null } |
  { 'scenarioNotFound' : null };
export interface OnScenarioStartRequest {
  'scenarioId' : bigint,
  'optionCount' : bigint,
}
export type OnScenarioStartResult = { 'ok' : null } |
  { 'notAuthorized' : null };
export type OnSeasonEndResult = { 'ok' : null } |
  { 'notAuthorized' : null };
export interface PagedResult {
  'data' : Array<Proposal>,
  'count' : bigint,
  'offset' : bigint,
}
export interface Proposal {
  'id' : bigint,
  'content' : ProposalContent,
  'timeStart' : bigint,
  'votes' : Array<[Principal, Vote]>,
  'statusLog' : Array<ProposalStatusLogEntry>,
  'endTimerId' : [] | [bigint],
  'proposer' : Principal,
  'timeEnd' : bigint,
}
export type ProposalContent = { 'train' : TrainContent } |
  { 'changeLogo' : ChangeLogoContent } |
  { 'changeName' : ChangeNameContent } |
  { 'changeMotto' : ChangeMottoContent } |
  { 'modifyLink' : ModifyLinkContent } |
  { 'changeColor' : ChangeColorContent } |
  { 'swapPlayerPositions' : SwapPlayerPositionsContent } |
  { 'changeDescription' : ChangeDescriptionContent };
export type ProposalStatusLogEntry = {
    'failedToExecute' : { 'time' : Time, 'error' : string }
  } |
  { 'rejected' : { 'time' : Time } } |
  { 'executing' : { 'time' : Time } } |
  { 'executed' : { 'time' : Time } };
export interface ScenarioTeamVotingResult {
  'option' : bigint,
  'teamId' : bigint,
}
export interface ScenarioVote {
  'option' : [] | [bigint],
  'votingPower' : bigint,
}
export interface ScenarioVotingResults {
  'teamOptions' : Array<ScenarioTeamVotingResult>,
}
export type SetLeagueResult = { 'ok' : null } |
  { 'notAuthorized' : null };
export type Skill = { 'battingAccuracy' : null } |
  { 'throwingAccuracy' : null } |
  { 'speed' : null } |
  { 'catching' : null } |
  { 'battingPower' : null } |
  { 'defense' : null } |
  { 'throwingPower' : null };
export interface SwapPlayerPositionsContent {
  'position1' : FieldPosition,
  'position2' : FieldPosition,
}
export interface TeamLinks { 'links' : Array<Link>, 'teamId' : bigint }
export type Time = bigint;
export interface TrainContent { 'skill' : Skill, 'position' : FieldPosition }
export type UpdateTeamEnergyResult = { 'ok' : null } |
  { 'notAuthorized' : null } |
  { 'teamNotFound' : null };
export interface Vote { 'value' : [] | [boolean], 'votingPower' : bigint }
export interface VoteOnProposalRequest {
  'vote' : boolean,
  'proposalId' : bigint,
}
export type VoteOnProposalResult = { 'ok' : null } |
  { 'proposalNotFound' : null } |
  { 'notAuthorized' : null } |
  { 'alreadyVoted' : null } |
  { 'votingClosed' : null } |
  { 'teamNotFound' : null };
export interface VoteOnScenarioRequest {
  'scenarioId' : bigint,
  'option' : bigint,
}
export type VoteOnScenarioResult = { 'ok' : null } |
  { 'invalidOption' : null } |
  { 'notAuthorized' : null } |
  { 'alreadyVoted' : null } |
  { 'seasonStatusFetchError' : string } |
  { 'teamNotInScenario' : null } |
  { 'votingNotOpen' : null } |
  { 'teamNotFound' : null } |
  { 'scenarioNotFound' : null };
export interface _SERVICE {
  'createProposal' : ActorMethod<
    [bigint, CreateProposalRequest],
    CreateProposalResult
  >,
  'createTeam' : ActorMethod<[CreateTeamRequest], CreateTeamResult>,
  'getCycles' : ActorMethod<[], GetCyclesResult>,
  'getLinks' : ActorMethod<[], GetLinksResult>,
  'getProposal' : ActorMethod<[bigint, bigint], GetProposalResult>,
  'getProposals' : ActorMethod<[bigint, bigint, bigint], GetProposalsResult>,
  'getScenarioVote' : ActorMethod<
    [GetScenarioVoteRequest],
    GetScenarioVoteResult
  >,
  'getScenarioVotingResults' : ActorMethod<
    [GetScenarioVotingResultsRequest],
    GetScenarioVotingResultsResult
  >,
  'onScenarioEnd' : ActorMethod<[OnScenarioEndRequest], OnScenarioEndResult>,
  'onScenarioStart' : ActorMethod<
    [OnScenarioStartRequest],
    OnScenarioStartResult
  >,
  'onSeasonEnd' : ActorMethod<[], OnSeasonEndResult>,
  'setLeague' : ActorMethod<[Principal], SetLeagueResult>,
  'updateTeamEnergy' : ActorMethod<[bigint, bigint], UpdateTeamEnergyResult>,
  'voteOnProposal' : ActorMethod<
    [bigint, VoteOnProposalRequest],
    VoteOnProposalResult
  >,
  'voteOnScenario' : ActorMethod<[VoteOnScenarioRequest], VoteOnScenarioResult>,
}
export declare const idlFactory: IDL.InterfaceFactory;
export declare const init: (args: { IDL: typeof IDL }) => IDL.Type[];
