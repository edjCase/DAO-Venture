import type { Principal } from '@dfinity/principal';
import type { ActorMethod } from '@dfinity/agent';
import type { IDL } from '@dfinity/candid';

export interface AddJobContent { 'job' : Job }
export type AddScenarioError = { 'notAuthorized' : null } |
  { 'invalid' : Array<string> };
export interface AddScenarioRequest {
  'startTime' : [] | [Time],
  'title' : string,
  'endTime' : Time,
  'kind' : ScenarioKindRequest,
  'description' : string,
  'undecidedEffect' : Effect,
}
export type AddScenarioResult = { 'ok' : null } |
  { 'err' : AddScenarioError };
export type AssignUserToTownError = { 'townNotFound' : null } |
  { 'notAuthorized' : null } |
  { 'notWorldMember' : null };
export interface AssignUserToTownRequest {
  'userId' : Principal,
  'townId' : bigint,
}
export interface AxialCoordinate { 'q' : bigint, 'r' : bigint }
export type BenevolentDictatorState = { 'open' : null } |
  { 'claimed' : Principal } |
  { 'disabled' : null };
export interface ChangeTownFlagContent { 'image' : FlagImage }
export interface ChangeTownMottoContent { 'motto' : string }
export interface ChangeTownNameContent { 'name' : string }
export type ClaimBenevolentDictatorRoleError = { 'notOpenToClaim' : null } |
  { 'notAuthenticated' : null };
export type ClaimBenevolentDictatorRoleResult = { 'ok' : null } |
  { 'err' : ClaimBenevolentDictatorRoleError };
export type CreateTownProposalError = { 'townNotFound' : null } |
  { 'notAuthorized' : null } |
  { 'invalid' : Array<string> };
export type CreateTownProposalResult = { 'ok' : bigint } |
  { 'err' : CreateTownProposalError };
export type CreateWorldProposalError = { 'notAuthorized' : null } |
  { 'invalid' : Array<string> };
export type CreateWorldProposalRequest = { 'motion' : MotionContent };
export type CreateWorldProposalResult = { 'ok' : bigint } |
  { 'err' : CreateWorldProposalError };
export type Effect = { 'resource' : ResourceEffect } |
  { 'allOf' : Array<Effect> } |
  { 'noEffect' : null } |
  { 'oneOf' : Array<WeightedEffect> } |
  { 'entropy' : EntropyEffect };
export type EffectOutcome = { 'resource' : ResourceTownEffectOutcome } |
  { 'entropy' : EntropyTownEffectOutcome };
export interface EntropyEffect { 'town' : TargetTown, 'delta' : bigint }
export interface EntropyTownEffectOutcome {
  'townId' : bigint,
  'delta' : bigint,
}
export interface FlagImage { 'pixels' : Array<Array<Pixel>> }
export interface FoodResourceInfo { 'amount' : bigint }
export type GetScenarioError = { 'notStarted' : null } |
  { 'notFound' : null };
export type GetScenarioResult = { 'ok' : Scenario } |
  { 'err' : GetScenarioError };
export type GetScenarioVoteError = { 'notEligible' : null } |
  { 'scenarioNotFound' : null };
export interface GetScenarioVoteRequest { 'scenarioId' : bigint }
export type GetScenarioVoteResult = { 'ok' : VotingData } |
  { 'err' : GetScenarioVoteError };
export type GetScenariosResult = { 'ok' : Array<Scenario> };
export interface GetTopUsersRequest { 'count' : bigint, 'offset' : bigint }
export type GetTopUsersResult = { 'ok' : PagedResult_2 };
export type GetTownOwnersRequest = { 'all' : null } |
  { 'town' : bigint };
export type GetTownOwnersResult = { 'ok' : Array<UserVotingInfo> };
export type GetTownProposalError = { 'proposalNotFound' : null } |
  { 'townNotFound' : null };
export type GetTownProposalResult = { 'ok' : TownProposal } |
  { 'err' : GetTownProposalError };
export type GetTownProposalsError = { 'townNotFound' : null };
export type GetTownProposalsResult = { 'ok' : PagedResult_1 } |
  { 'err' : GetTownProposalsError };
export type GetUserError = { 'notAuthorized' : null } |
  { 'notFound' : null };
export type GetUserResult = { 'ok' : User } |
  { 'err' : GetUserError };
export type GetUserStatsResult = { 'ok' : UserStats } |
  { 'err' : null };
export type GetWorldError = {};
export type GetWorldProposalError = { 'proposalNotFound' : null };
export type GetWorldProposalResult = { 'ok' : WorldProposal } |
  { 'err' : GetWorldProposalError };
export type GetWorldProposalsResult = { 'ok' : PagedResult };
export type GetWorldResult = { 'ok' : World } |
  { 'err' : GetWorldError };
export interface GoldResourceInfo { 'difficulty' : bigint }
export type Job = {
    'processResource' : { 'resource' : ResourceKind, 'workerCount' : bigint }
  } |
  {
    'gatherResource' : {
      'resource' : ResourceKind,
      'locationId' : bigint,
      'workerCount' : bigint,
    }
  };
export type JoinWorldError = { 'notAuthorized' : null } |
  { 'alreadyWorldMember' : null } |
  { 'noTowns' : null };
export interface LocationResourceList {
  'food' : FoodResourceInfo,
  'gold' : GoldResourceInfo,
  'wood' : WoodResourceInfo,
  'stone' : StoneResourceInfo,
}
export interface LotteryPrize { 'description' : string, 'effect' : Effect }
export interface LotteryScenario { 'minBid' : bigint, 'prize' : LotteryPrize }
export interface LotteryScenarioOutcome { 'winningTownId' : [] | [bigint] }
export interface MotionContent { 'title' : string, 'description' : string }
export interface MotionContent__1 { 'title' : string, 'description' : string }
export interface NoWorldEffectScenario {
  'options' : Array<ScenarioOptionDiscrete>,
}
export interface NoWorldEffectScenarioRequest {
  'options' : Array<ScenarioOptionDiscrete__1>,
}
export interface PagedResult {
  'data' : Array<WorldProposal>,
  'count' : bigint,
  'offset' : bigint,
}
export interface PagedResult_1 {
  'data' : Array<Proposal>,
  'count' : bigint,
  'offset' : bigint,
}
export interface PagedResult_2 {
  'data' : Array<User>,
  'count' : bigint,
  'offset' : bigint,
}
export interface Pixel { 'red' : number, 'blue' : number, 'green' : number }
export interface ProportionalBidPrize {
  'kind' : PropotionalBidPrizeKind,
  'description' : string,
  'amount' : bigint,
}
export interface ProportionalBidScenario { 'prize' : ProportionalBidPrize }
export interface ProportionalBidScenarioOutcome {
  'bids' : Array<ProportionalWinningBid>,
}
export interface ProportionalWinningBid {
  'proportion' : bigint,
  'townId' : bigint,
}
export interface Proposal {
  'id' : bigint,
  'content' : ProposalContent__1,
  'timeStart' : bigint,
  'votes' : Array<[Principal, Vote]>,
  'statusLog' : Array<ProposalStatusLogEntry>,
  'endTimerId' : [] | [bigint],
  'timeEnd' : bigint,
  'proposerId' : Principal,
}
export type ProposalContent = { 'motion' : MotionContent };
export type ProposalContent__1 = { 'changeFlag' : ChangeTownFlagContent } |
  { 'changeName' : ChangeTownNameContent } |
  { 'changeMotto' : ChangeTownMottoContent } |
  { 'updateJob' : UpdateJobContent } |
  { 'addJob' : AddJobContent } |
  { 'removeJob' : RemoveJobContent } |
  { 'motion' : MotionContent__1 };
export type ProposalStatusLogEntry = {
    'failedToExecute' : { 'time' : Time, 'error' : string }
  } |
  { 'rejected' : { 'time' : Time } } |
  { 'executing' : { 'time' : Time } } |
  { 'executed' : { 'time' : Time } };
export type PropotionalBidPrizeKind = {};
export type RangeRequirement = { 'above' : bigint } |
  { 'below' : bigint };
export interface RemoveJobContent { 'jobId' : bigint }
export type Requirement = { 'age' : RangeRequirement } |
  { 'resource' : ResourceRequirement } |
  { 'size' : RangeRequirement } |
  { 'entropy' : RangeRequirement } |
  { 'population' : RangeRequirement };
export interface ResourceCost { 'kind' : ResourceKind, 'amount' : bigint }
export interface ResourceEffect {
  'value' : { 'flat' : bigint },
  'kind' : ResourceKind,
  'town' : TargetTown,
}
export type ResourceKind = { 'food' : null } |
  { 'gold' : null } |
  { 'wood' : null } |
  { 'stone' : null };
export interface ResourceList {
  'food' : bigint,
  'gold' : bigint,
  'wood' : bigint,
  'stone' : bigint,
}
export interface ResourceRequirement {
  'kind' : ResourceKind,
  'range' : RangeRequirement,
}
export interface ResourceTownEffectOutcome {
  'kind' : ResourceKind,
  'townId' : bigint,
  'delta' : bigint,
}
export type Result = { 'ok' : null } |
  { 'err' : JoinWorldError };
export type Result_1 = { 'ok' : null } |
  { 'err' : AssignUserToTownError };
export interface Scenario {
  'id' : bigint,
  'startTime' : bigint,
  'title' : string,
  'endTime' : bigint,
  'kind' : ScenarioKind,
  'description' : string,
  'undecidedEffect' : Effect,
  'state' : ScenarioState,
}
export type ScenarioKind = { 'lottery' : LotteryScenario } |
  { 'threshold' : ThresholdScenario } |
  { 'textInput' : TextInputScenario } |
  { 'noWorldEffect' : NoWorldEffectScenario } |
  { 'worldChoice' : WorldChoiceScenario } |
  { 'proportionalBid' : ProportionalBidScenario };
export type ScenarioKindRequest = { 'lottery' : LotteryScenario } |
  { 'threshold' : ThresholdScenarioRequest } |
  { 'textInput' : TextInputScenario } |
  { 'noWorldEffect' : NoWorldEffectScenarioRequest } |
  { 'worldChoice' : WorldChoiceScenarioRequest } |
  { 'proportionalBid' : ProportionalBidScenario };
export interface ScenarioOptionDiscrete {
  'title' : string,
  'description' : string,
  'resourceCosts' : Array<ResourceCost>,
  'allowedTownIds' : Array<bigint>,
  'townEffect' : Effect,
  'requirements' : Array<Requirement>,
}
export interface ScenarioOptionDiscrete__1 {
  'title' : string,
  'description' : string,
  'resourceCosts' : Array<ResourceCost>,
  'townEffect' : Effect,
  'requirements' : Array<Requirement>,
}
export type ScenarioOptionValue = { 'id' : bigint } |
  { 'nat' : bigint } |
  { 'text' : string };
export type ScenarioOutcome = { 'lottery' : LotteryScenarioOutcome } |
  { 'threshold' : ThresholdScenarioOutcome } |
  { 'textInput' : TextInputScenarioOutcome } |
  { 'noWorldEffect' : null } |
  { 'worldChoice' : WorldChoiceScenarioOutcome } |
  { 'proportionalBid' : ProportionalBidScenarioOutcome };
export interface ScenarioResolvedOptionDiscrete {
  'id' : bigint,
  'title' : string,
  'chosenByTownIds' : Array<bigint>,
  'description' : string,
  'resourceCosts' : Array<ResourceCost>,
  'townEffect' : Effect,
  'requirements' : Array<Requirement>,
  'seenByTownIds' : Array<bigint>,
}
export interface ScenarioResolvedOptionRaw {
  'value' : bigint,
  'chosenByTownIds' : Array<bigint>,
}
export interface ScenarioResolvedOptionRaw_1 {
  'value' : string,
  'chosenByTownIds' : Array<bigint>,
}
export interface ScenarioResolvedOptions {
  'undecidedOption' : {
    'chosenByTownIds' : Array<bigint>,
    'townEffect' : Effect,
  },
  'kind' : ScenarioResolvedOptionsKind,
}
export type ScenarioResolvedOptionsKind = {
    'nat' : Array<ScenarioResolvedOptionRaw>
  } |
  { 'text' : Array<ScenarioResolvedOptionRaw_1> } |
  { 'discrete' : Array<ScenarioResolvedOptionDiscrete> };
export type ScenarioState = { 'notStarted' : null } |
  { 'resolved' : ScenarioStateResolved } |
  { 'resolving' : null } |
  { 'inProgress' : null };
export interface ScenarioStateResolved {
  'scenarioOutcome' : ScenarioOutcome,
  'options' : ScenarioResolvedOptions,
  'effectOutcomes' : Array<EffectOutcome>,
}
export interface ScenarioTownOptionDiscrete {
  'id' : bigint,
  'title' : string,
  'description' : string,
  'resourceCosts' : Array<ResourceCost>,
  'currentVotingPower' : bigint,
  'requirements' : Array<Requirement>,
}
export interface ScenarioTownOptionNat {
  'value' : bigint,
  'currentVotingPower' : bigint,
}
export interface ScenarioTownOptionText {
  'value' : string,
  'currentVotingPower' : bigint,
}
export type ScenarioTownOptions = { 'nat' : Array<ScenarioTownOptionNat> } |
  { 'text' : Array<ScenarioTownOptionText> } |
  { 'discrete' : Array<ScenarioTownOptionDiscrete> };
export interface ScenarioVote {
  'townOptions' : ScenarioTownOptions,
  'value' : [] | [ScenarioOptionValue],
  'votingPower' : bigint,
  'townId' : bigint,
  'townVotingPower' : TownVotingPower,
}
export type SetBenevolentDictatorStateError = { 'notAuthorized' : null };
export type SetBenevolentDictatorStateResult = { 'ok' : null } |
  { 'err' : SetBenevolentDictatorStateError };
export interface Skill { 'proficiencyLevel' : bigint, 'techLevel' : bigint }
export interface SkillList {
  'farming' : Skill,
  'mining' : Skill,
  'woodCutting' : Skill,
}
export interface StoneResourceInfo { 'difficulty' : bigint }
export type TargetTown = { 'all' : null } |
  { 'contextual' : null } |
  { 'random' : bigint } |
  { 'chosen' : Array<bigint> };
export interface TextInputScenario { 'description' : string }
export interface TextInputScenarioOutcome { 'text' : string }
export interface ThresholdContribution { 'townId' : bigint, 'amount' : bigint }
export interface ThresholdScenario {
  'failure' : { 'description' : string, 'effect' : Effect },
  'minAmount' : bigint,
  'success' : { 'description' : string, 'effect' : Effect },
  'options' : Array<ThresholdScenarioOption>,
  'undecidedAmount' : ThresholdValue,
}
export interface ThresholdScenarioOption {
  'title' : string,
  'value' : ThresholdValue,
  'description' : string,
  'resourceCosts' : Array<ResourceCost>,
  'allowedTownIds' : Array<bigint>,
  'townEffect' : Effect,
  'requirements' : Array<Requirement>,
}
export interface ThresholdScenarioOptionRequest {
  'title' : string,
  'value' : ThresholdValue__1,
  'description' : string,
  'resourceCosts' : Array<ResourceCost>,
  'townEffect' : Effect,
  'requirements' : Array<Requirement>,
}
export interface ThresholdScenarioOutcome {
  'contributions' : Array<ThresholdContribution>,
  'successful' : boolean,
}
export interface ThresholdScenarioRequest {
  'failure' : { 'description' : string, 'effect' : Effect },
  'minAmount' : bigint,
  'success' : { 'description' : string, 'effect' : Effect },
  'options' : Array<ThresholdScenarioOptionRequest>,
  'undecidedAmount' : ThresholdValue__1,
}
export type ThresholdValue = { 'fixed' : bigint } |
  {
    'weightedChance' : Array<
      { 'weight' : bigint, 'value' : bigint, 'description' : string }
    >
  };
export type ThresholdValue__1 = { 'fixed' : bigint } |
  {
    'weightedChance' : Array<
      { 'weight' : bigint, 'value' : bigint, 'description' : string }
    >
  };
export type Time = bigint;
export interface Town {
  'id' : bigint,
  'genesisTime' : Time,
  'motto' : string,
  'resources' : ResourceList,
  'jobs' : Array<Job>,
  'name' : string,
  'size' : bigint,
  'flagImage' : FlagImage,
  'entropy' : bigint,
  'skills' : SkillList,
  'population' : bigint,
}
export interface TownProposal {
  'id' : bigint,
  'content' : ProposalContent__1,
  'timeStart' : bigint,
  'votes' : Array<[Principal, Vote]>,
  'statusLog' : Array<ProposalStatusLogEntry>,
  'endTimerId' : [] | [bigint],
  'timeEnd' : bigint,
  'proposerId' : Principal,
}
export type TownProposalContent = { 'changeFlag' : ChangeTownFlagContent } |
  { 'changeName' : ChangeTownNameContent } |
  { 'changeMotto' : ChangeTownMottoContent } |
  { 'updateJob' : UpdateJobContent } |
  { 'addJob' : AddJobContent } |
  { 'removeJob' : RemoveJobContent } |
  { 'motion' : MotionContent__1 };
export interface TownStats {
  'id' : bigint,
  'totalUserLevel' : bigint,
  'userCount' : bigint,
}
export interface TownVotingPower { 'total' : bigint, 'voted' : bigint }
export interface UpdateJobContent { 'job' : Job, 'jobId' : bigint }
export interface User {
  'id' : Principal,
  'residency' : [] | [UserResidency],
  'gold' : bigint,
  'level' : bigint,
}
export interface UserResidency { 'votingPower' : bigint, 'townId' : bigint }
export interface UserStats {
  'towns' : Array<TownStats>,
  'totalUserLevel' : bigint,
  'userCount' : bigint,
}
export interface UserVotingInfo {
  'id' : Principal,
  'votingPower' : bigint,
  'townId' : bigint,
}
export interface Vote { 'value' : [] | [boolean], 'votingPower' : bigint }
export type VoteOnScenarioError = { 'votingNotOpen' : null } |
  { 'invalidValue' : null } |
  { 'notEligible' : null } |
  { 'scenarioNotFound' : null };
export interface VoteOnScenarioRequest {
  'scenarioId' : bigint,
  'value' : ScenarioOptionValue,
}
export type VoteOnScenarioResult = { 'ok' : null } |
  { 'err' : VoteOnScenarioError };
export type VoteOnTownProposalError = { 'proposalNotFound' : null } |
  { 'townNotFound' : null } |
  { 'notAuthorized' : null } |
  { 'alreadyVoted' : null } |
  { 'votingClosed' : null };
export interface VoteOnTownProposalRequest {
  'vote' : boolean,
  'proposalId' : bigint,
}
export type VoteOnTownProposalResult = { 'ok' : null } |
  { 'err' : VoteOnTownProposalError };
export type VoteOnWorldProposalError = { 'proposalNotFound' : null } |
  { 'notAuthorized' : null } |
  { 'alreadyVoted' : null } |
  { 'votingClosed' : null };
export interface VoteOnWorldProposalRequest {
  'vote' : boolean,
  'proposalId' : bigint,
}
export type VoteOnWorldProposalResult = { 'ok' : null } |
  { 'err' : VoteOnWorldProposalError };
export interface VotingData {
  'townIdsWithConsensus' : Array<bigint>,
  'yourData' : [] | [ScenarioVote],
}
export interface WeightedEffect {
  'weight' : bigint,
  'description' : string,
  'effect' : Effect,
}
export interface WoodResourceInfo { 'amount' : bigint }
export interface World {
  'age' : bigint,
  'nextDayStartTime' : bigint,
  'locations' : Array<WorldLocation>,
}
export interface WorldChoiceScenario {
  'options' : Array<WorldChoiceScenarioOption>,
}
export interface WorldChoiceScenarioOption {
  'title' : string,
  'worldEffect' : Effect,
  'description' : string,
  'resourceCosts' : Array<ResourceCost>,
  'allowedTownIds' : Array<bigint>,
  'townEffect' : Effect,
  'requirements' : Array<Requirement>,
}
export interface WorldChoiceScenarioOptionRequest {
  'title' : string,
  'worldEffect' : Effect,
  'description' : string,
  'resourceCosts' : Array<ResourceCost>,
  'townEffect' : Effect,
  'requirements' : Array<Requirement>,
}
export interface WorldChoiceScenarioOutcome { 'optionId' : [] | [bigint] }
export interface WorldChoiceScenarioRequest {
  'options' : Array<WorldChoiceScenarioOptionRequest>,
}
export interface WorldLocation {
  'id' : bigint,
  'resources' : LocationResourceList,
  'townId' : [] | [bigint],
  'coordinate' : AxialCoordinate,
}
export interface WorldProposal {
  'id' : bigint,
  'content' : ProposalContent,
  'timeStart' : bigint,
  'votes' : Array<[Principal, Vote]>,
  'statusLog' : Array<ProposalStatusLogEntry>,
  'endTimerId' : [] | [bigint],
  'timeEnd' : bigint,
  'proposerId' : Principal,
}
export interface _SERVICE {
  'addScenario' : ActorMethod<[AddScenarioRequest], AddScenarioResult>,
  'assignUserToTown' : ActorMethod<[AssignUserToTownRequest], Result_1>,
  'claimBenevolentDictatorRole' : ActorMethod<
    [],
    ClaimBenevolentDictatorRoleResult
  >,
  'createTownProposal' : ActorMethod<
    [bigint, TownProposalContent],
    CreateTownProposalResult
  >,
  'createWorldProposal' : ActorMethod<
    [CreateWorldProposalRequest],
    CreateWorldProposalResult
  >,
  'getBenevolentDictatorState' : ActorMethod<[], BenevolentDictatorState>,
  'getScenario' : ActorMethod<[bigint], GetScenarioResult>,
  'getScenarioVote' : ActorMethod<
    [GetScenarioVoteRequest],
    GetScenarioVoteResult
  >,
  'getScenarios' : ActorMethod<[], GetScenariosResult>,
  'getTopUsers' : ActorMethod<[GetTopUsersRequest], GetTopUsersResult>,
  'getTownOwners' : ActorMethod<[GetTownOwnersRequest], GetTownOwnersResult>,
  'getTownProposal' : ActorMethod<[bigint, bigint], GetTownProposalResult>,
  'getTownProposals' : ActorMethod<
    [bigint, bigint, bigint],
    GetTownProposalsResult
  >,
  'getTowns' : ActorMethod<[], Array<Town>>,
  'getUser' : ActorMethod<[Principal], GetUserResult>,
  'getUserStats' : ActorMethod<[], GetUserStatsResult>,
  'getWorld' : ActorMethod<[], GetWorldResult>,
  'getWorldProposal' : ActorMethod<[bigint], GetWorldProposalResult>,
  'getWorldProposals' : ActorMethod<[bigint, bigint], GetWorldProposalsResult>,
  'joinWorld' : ActorMethod<[], Result>,
  'setBenevolentDictatorState' : ActorMethod<
    [BenevolentDictatorState],
    SetBenevolentDictatorStateResult
  >,
  'voteOnScenario' : ActorMethod<[VoteOnScenarioRequest], VoteOnScenarioResult>,
  'voteOnTownProposal' : ActorMethod<
    [bigint, VoteOnTownProposalRequest],
    VoteOnTownProposalResult
  >,
  'voteOnWorldProposal' : ActorMethod<
    [VoteOnWorldProposalRequest],
    VoteOnWorldProposalResult
  >,
}
export declare const idlFactory: IDL.InterfaceFactory;
export declare const init: (args: { IDL: typeof IDL }) => IDL.Type[];
