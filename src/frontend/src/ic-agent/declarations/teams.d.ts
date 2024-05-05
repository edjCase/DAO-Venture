import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';
import type { IDL } from '@dfinity/candid';

export interface ChangeColorContent { 'color' : [number, number, number] }
export interface ChangeDescriptionContent { 'description' : string }
export interface ChangeLogoContent { 'logoUrl' : string }
export interface ChangeMottoContent { 'motto' : string }
export interface ChangeNameContent { 'name' : string }
export interface CompletedMatch {
  'team1' : CompletedMatchTeam,
  'team2' : CompletedMatchTeam,
  'aura' : MatchAura,
  'winner' : TeamIdOrTie,
}
export interface CompletedMatchGroup {
  'time' : Time,
  'matches' : Array<CompletedMatch>,
}
export interface CompletedMatchTeam { 'id' : bigint, 'score' : bigint }
export type CreateProposalError = { 'notAuthorized' : null } |
  { 'teamNotFound' : null };
export interface CreateProposalRequest { 'content' : ProposalContent }
export type CreateProposalResult = { 'ok' : bigint } |
  { 'err' : CreateProposalError };
export interface CreateTeamRequest {
  'motto' : string,
  'name' : string,
  'color' : [number, number, number],
  'description' : string,
  'logoUrl' : string,
}
export type CreateTeamResult = { 'ok' : bigint } |
  { 'nameTaken' : null } |
  { 'notAuthorized' : null };
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
export type GetProposalResult = { 'ok' : Proposal } |
  { 'proposalNotFound' : null } |
  { 'teamNotFound' : null };
export type GetProposalsResult = { 'ok' : PagedResult } |
  { 'teamNotFound' : null };
export interface Link { 'url' : string, 'name' : string }
export type MatchAura = { 'foggy' : null } |
  { 'moveBasesIn' : null } |
  { 'extraStrike' : null } |
  { 'moreBlessingsAndCurses' : null } |
  { 'fastBallsHardHits' : null } |
  { 'explodingBalls' : null } |
  { 'lowGravity' : null } |
  { 'doubleOrNothing' : null } |
  { 'windy' : null } |
  { 'rainy' : null };
export interface ModifyLinkContent { 'url' : [] | [string], 'name' : string }
export type OnMatchGroupCompleteError = { 'notAuthorized' : null };
export interface OnMatchGroupCompleteRequest {
  'matchGroup' : CompletedMatchGroup,
}
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
export type Result = { 'ok' : null } |
  { 'err' : OnMatchGroupCompleteError };
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
export interface Team {
  'id' : bigint,
  'motto' : string,
  'name' : string,
  'color' : [number, number, number],
  'description' : string,
  'links' : Array<Link>,
  'entropy' : bigint,
  'logoUrl' : string,
  'energy' : bigint,
}
export type TeamIdOrTie = { 'tie' : null } |
  { 'team1' : null } |
  { 'team2' : null };
export type Time = bigint;
export interface TrainContent { 'skill' : Skill, 'position' : FieldPosition }
export type UpdateTeamColorResult = { 'ok' : null } |
  { 'notAuthorized' : null } |
  { 'teamNotFound' : null };
export type UpdateTeamDescriptionResult = { 'ok' : null } |
  { 'notAuthorized' : null } |
  { 'teamNotFound' : null };
export type UpdateTeamEnergyResult = { 'ok' : null } |
  { 'notAuthorized' : null } |
  { 'teamNotFound' : null };
export type UpdateTeamEntropyResult = { 'ok' : null } |
  { 'notAuthorized' : null } |
  { 'teamNotFound' : null };
export type UpdateTeamLogoResult = { 'ok' : null } |
  { 'notAuthorized' : null } |
  { 'teamNotFound' : null };
export type UpdateTeamMottoResult = { 'ok' : null } |
  { 'notAuthorized' : null } |
  { 'teamNotFound' : null };
export type UpdateTeamNameResult = { 'ok' : null } |
  { 'nameTaken' : null } |
  { 'notAuthorized' : null } |
  { 'teamNotFound' : null };
export interface Vote { 'value' : [] | [boolean], 'votingPower' : bigint }
export type VoteOnProposalError = { 'proposalNotFound' : null } |
  { 'notAuthorized' : null } |
  { 'alreadyVoted' : null } |
  { 'votingClosed' : null } |
  { 'teamNotFound' : null };
export interface VoteOnProposalRequest {
  'vote' : boolean,
  'proposalId' : bigint,
}
export type VoteOnProposalResult = { 'ok' : null } |
  { 'err' : VoteOnProposalError };
export interface _SERVICE {
  'createProposal' : ActorMethod<
    [bigint, CreateProposalRequest],
    CreateProposalResult
  >,
  'createTeam' : ActorMethod<[CreateTeamRequest], CreateTeamResult>,
  'getCycles' : ActorMethod<[], GetCyclesResult>,
  'getProposal' : ActorMethod<[bigint, bigint], GetProposalResult>,
  'getProposals' : ActorMethod<[bigint, bigint, bigint], GetProposalsResult>,
  'getTeams' : ActorMethod<[], Array<Team>>,
  'onMatchGroupComplete' : ActorMethod<[OnMatchGroupCompleteRequest], Result>,
  'onSeasonEnd' : ActorMethod<[], OnSeasonEndResult>,
  'setLeague' : ActorMethod<[Principal], SetLeagueResult>,
  'updateTeamColor' : ActorMethod<
    [bigint, [number, number, number]],
    UpdateTeamColorResult
  >,
  'updateTeamDescription' : ActorMethod<
    [bigint, string],
    UpdateTeamDescriptionResult
  >,
  'updateTeamEnergy' : ActorMethod<[bigint, bigint], UpdateTeamEnergyResult>,
  'updateTeamEntropy' : ActorMethod<[bigint, bigint], UpdateTeamEntropyResult>,
  'updateTeamLogo' : ActorMethod<[bigint, string], UpdateTeamLogoResult>,
  'updateTeamMotto' : ActorMethod<[bigint, string], UpdateTeamMottoResult>,
  'updateTeamName' : ActorMethod<[bigint, string], UpdateTeamNameResult>,
  'voteOnProposal' : ActorMethod<
    [bigint, VoteOnProposalRequest],
    VoteOnProposalResult
  >,
}
export declare const idlFactory: IDL.InterfaceFactory;
export declare const init: (args: { IDL: typeof IDL }) => IDL.Type[];
