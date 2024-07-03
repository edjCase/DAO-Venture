import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';
import type { IDL } from '@dfinity/candid';

export type AddTraitToTeamError = { 'notAuthorized' : null } |
  { 'traitNotFound' : null } |
  { 'teamNotFound' : null };
export interface AddTraitToTeamOk { 'hadTrait' : boolean }
export type AddTraitToTeamResult = { 'ok' : AddTraitToTeamOk } |
  { 'err' : AddTraitToTeamError };
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
  { 'invalid' : Array<string> } |
  { 'teamNotFound' : null };
export interface CreateProposalRequest { 'content' : ProposalContent }
export type CreateProposalResult = { 'ok' : bigint } |
  { 'err' : CreateProposalError };
export type CreateTeamError = { 'nameTaken' : null } |
  { 'notAuthorized' : null };
export interface CreateTeamRequest {
  'motto' : string,
  'name' : string,
  'color' : [number, number, number],
  'description' : string,
  'logoUrl' : string,
}
export type CreateTeamResult = { 'ok' : bigint } |
  { 'err' : CreateTeamError };
export type CreateTeamTraitError = { 'notAuthorized' : null } |
  { 'invalid' : Array<string> } |
  { 'idTaken' : null };
export interface CreateTeamTraitRequest {
  'id' : string,
  'name' : string,
  'description' : string,
}
export type CreateTeamTraitResult = { 'ok' : null } |
  { 'err' : CreateTeamTraitError };
export type FieldPosition = { 'rightField' : null } |
  { 'leftField' : null } |
  { 'thirdBase' : null } |
  { 'pitcher' : null } |
  { 'secondBase' : null } |
  { 'shortStop' : null } |
  { 'centerField' : null } |
  { 'firstBase' : null };
export type GetCyclesError = { 'notAuthorized' : null };
export type GetCyclesResult = { 'ok' : bigint } |
  { 'err' : GetCyclesError };
export type GetProposalError = { 'proposalNotFound' : null } |
  { 'teamNotFound' : null };
export type GetProposalResult = { 'ok' : Proposal } |
  { 'err' : GetProposalError };
export type GetProposalsError = { 'teamNotFound' : null };
export type GetProposalsResult = { 'ok' : PagedResult } |
  { 'err' : GetProposalsError };
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
export type OnSeasonEndError = { 'notAuthorized' : null };
export type OnSeasonEndResult = { 'ok' : null } |
  { 'err' : OnSeasonEndError };
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
export type RemoveTraitFromTeamError = { 'notAuthorized' : null } |
  { 'traitNotFound' : null } |
  { 'teamNotFound' : null };
export interface RemoveTraitFromTeamOk { 'hadTrait' : boolean }
export type RemoveTraitFromTeamResult = { 'ok' : RemoveTraitFromTeamOk } |
  { 'err' : RemoveTraitFromTeamError };
export type Result = { 'ok' : null } |
  { 'err' : OnMatchGroupCompleteError };
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
  'traits' : Array<Trait>,
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
export interface TeamsActor {
  'addTraitToTeam' : ActorMethod<[bigint, string], AddTraitToTeamResult>,
  'createProposal' : ActorMethod<
    [bigint, CreateProposalRequest],
    CreateProposalResult
  >,
  'createTeam' : ActorMethod<[CreateTeamRequest], CreateTeamResult>,
  'createTeamTrait' : ActorMethod<
    [CreateTeamTraitRequest],
    CreateTeamTraitResult
  >,
  'getCycles' : ActorMethod<[], GetCyclesResult>,
  'getEntropyThreshold' : ActorMethod<[], bigint>,
  'getProposal' : ActorMethod<[bigint, bigint], GetProposalResult>,
  'getProposals' : ActorMethod<[bigint, bigint, bigint], GetProposalsResult>,
  'getTeams' : ActorMethod<[], Array<Team>>,
  'getTraits' : ActorMethod<[], Array<Trait>>,
  'onMatchGroupComplete' : ActorMethod<[OnMatchGroupCompleteRequest], Result>,
  'onSeasonEnd' : ActorMethod<[], OnSeasonEndResult>,
  'removeTraitFromTeam' : ActorMethod<
    [bigint, string],
    RemoveTraitFromTeamResult
  >,
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
export type Time = bigint;
export interface TrainContent { 'skill' : Skill, 'position' : FieldPosition }
export interface Trait {
  'id' : string,
  'name' : string,
  'description' : string,
}
export type UpdateTeamColorError = { 'notAuthorized' : null } |
  { 'teamNotFound' : null };
export type UpdateTeamColorResult = { 'ok' : null } |
  { 'err' : UpdateTeamColorError };
export type UpdateTeamDescriptionError = { 'notAuthorized' : null } |
  { 'teamNotFound' : null };
export type UpdateTeamDescriptionResult = { 'ok' : null } |
  { 'err' : UpdateTeamDescriptionError };
export type UpdateTeamEnergyError = { 'notAuthorized' : null } |
  { 'teamNotFound' : null };
export type UpdateTeamEnergyResult = { 'ok' : null } |
  { 'err' : UpdateTeamEnergyError };
export type UpdateTeamEntropyError = { 'notAuthorized' : null } |
  { 'teamNotFound' : null };
export type UpdateTeamEntropyResult = { 'ok' : null } |
  { 'err' : UpdateTeamEntropyError };
export type UpdateTeamLogoError = { 'notAuthorized' : null } |
  { 'teamNotFound' : null };
export type UpdateTeamLogoResult = { 'ok' : null } |
  { 'err' : UpdateTeamLogoError };
export type UpdateTeamMottoError = { 'notAuthorized' : null } |
  { 'teamNotFound' : null };
export type UpdateTeamMottoResult = { 'ok' : null } |
  { 'err' : UpdateTeamMottoError };
export type UpdateTeamNameError = { 'nameTaken' : null } |
  { 'notAuthorized' : null } |
  { 'teamNotFound' : null };
export type UpdateTeamNameResult = { 'ok' : null } |
  { 'err' : UpdateTeamNameError };
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
export interface _SERVICE extends TeamsActor {}
export declare const idlFactory: IDL.InterfaceFactory;
export declare const init: (args: { IDL: typeof IDL }) => IDL.Type[];
