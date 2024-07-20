export const idlFactory = ({ IDL }) => {
  const Effect = IDL.Rec();
  const CreatePlayerFluffRequest = IDL.Record({
    'title': IDL.Text,
    'name': IDL.Text,
    'description': IDL.Text,
    'likes': IDL.Vec(IDL.Text),
    'quirks': IDL.Vec(IDL.Text),
    'dislikes': IDL.Vec(IDL.Text),
  });
  const InvalidError = IDL.Variant({
    'nameTaken': IDL.Null,
    'nameNotSpecified': IDL.Null,
  });
  const CreatePlayerFluffError = IDL.Variant({
    'notAuthorized': IDL.Null,
    'invalid': IDL.Vec(InvalidError),
  });
  const CreatePlayerFluffResult = IDL.Variant({
    'ok': IDL.Null,
    'err': CreatePlayerFluffError,
  });
  const Time = IDL.Int;
  const TownTraitEffectKind = IDL.Variant({
    'add': IDL.Null,
    'remove': IDL.Null,
  });
  const TargetTown = IDL.Variant({
    'all': IDL.Null,
    'contextual': IDL.Null,
    'random': IDL.Nat,
    'chosen': IDL.Vec(IDL.Nat),
  });
  const TownTraitEffect = IDL.Record({
    'kind': TownTraitEffectKind,
    'town': TargetTown,
    'traitId': IDL.Text,
  });
  const WeightedEffect = IDL.Record({
    'weight': IDL.Nat,
    'description': IDL.Text,
    'effect': Effect,
  });
  const EntropyEffect = IDL.Record({ 'town': TargetTown, 'delta': IDL.Int });
  const EntropyThresholdEffect = IDL.Record({ 'delta': IDL.Int });
  const Duration = IDL.Variant({
    'matches': IDL.Nat,
    'indefinite': IDL.Null,
  });
  const Skill = IDL.Variant({
    'battingAccuracy': IDL.Null,
    'throwingAccuracy': IDL.Null,
    'speed': IDL.Null,
    'catching': IDL.Null,
    'battingPower': IDL.Null,
    'defense': IDL.Null,
    'throwingPower': IDL.Null,
  });
  const ChosenOrRandomSkill = IDL.Variant({
    'random': IDL.Null,
    'chosen': Skill,
  });
  const FieldPosition = IDL.Variant({
    'rightField': IDL.Null,
    'leftField': IDL.Null,
    'thirdBase': IDL.Null,
    'pitcher': IDL.Null,
    'secondBase': IDL.Null,
    'shortStop': IDL.Null,
    'centerField': IDL.Null,
    'firstBase': IDL.Null,
  });
  const ChosenOrRandomFieldPosition = IDL.Variant({
    'random': IDL.Null,
    'chosen': FieldPosition,
  });
  const TargetPosition = IDL.Record({
    'town': TargetTown,
    'position': ChosenOrRandomFieldPosition,
  });
  const SkillEffect = IDL.Record({
    'duration': Duration,
    'skill': ChosenOrRandomSkill,
    'position': TargetPosition,
    'delta': IDL.Int,
  });
  const InjuryEffect = IDL.Record({ 'position': TargetPosition });
  const CurrencyEffect = IDL.Record({
    'value': IDL.Variant({ 'flat': IDL.Int }),
    'town': TargetTown,
  });
  const LeagueIncomeEffect = IDL.Record({ 'delta': IDL.Int });
  Effect.fill(
    IDL.Variant({
      'allOf': IDL.Vec(Effect),
      'townTrait': TownTraitEffect,
      'noEffect': IDL.Null,
      'oneOf': IDL.Vec(WeightedEffect),
      'entropy': EntropyEffect,
      'entropyThreshold': EntropyThresholdEffect,
      'skill': SkillEffect,
      'injury': InjuryEffect,
      'currency': CurrencyEffect,
      'leagueIncome': LeagueIncomeEffect,
    })
  );
  const LotteryPrize = IDL.Record({
    'description': IDL.Text,
    'effect': Effect,
  });
  const LotteryScenario = IDL.Record({
    'minBid': IDL.Nat,
    'prize': LotteryPrize,
  });
  const TraitRequirementKind = IDL.Variant({
    'prohibited': IDL.Null,
    'required': IDL.Null,
  });
  const TraitRequirement = IDL.Record({
    'id': IDL.Text,
    'kind': TraitRequirementKind,
  });
  const ScenarioOptionDiscrete__1 = IDL.Record({
    'title': IDL.Text,
    'townEffect': Effect,
    'description': IDL.Text,
    'traitRequirements': IDL.Vec(TraitRequirement),
    'currencyCost': IDL.Nat,
  });
  const NoLeagueEffectScenarioRequest = IDL.Record({
    'options': IDL.Vec(ScenarioOptionDiscrete__1),
  });
  const ThresholdValue__1 = IDL.Variant({
    'fixed': IDL.Int,
    'weightedChance': IDL.Vec(
      IDL.Record({
        'weight': IDL.Nat,
        'value': IDL.Int,
        'description': IDL.Text,
      })
    ),
  });
  const ThresholdScenarioOptionRequest = IDL.Record({
    'title': IDL.Text,
    'value': ThresholdValue__1,
    'townEffect': Effect,
    'description': IDL.Text,
    'traitRequirements': IDL.Vec(TraitRequirement),
    'currencyCost': IDL.Nat,
  });
  const ThresholdScenarioRequest = IDL.Record({
    'failure': IDL.Record({ 'description': IDL.Text, 'effect': Effect }),
    'minAmount': IDL.Nat,
    'success': IDL.Record({ 'description': IDL.Text, 'effect': Effect }),
    'options': IDL.Vec(ThresholdScenarioOptionRequest),
    'undecidedAmount': ThresholdValue__1,
  });
  const TextInputScenario = IDL.Record({ 'description': IDL.Text });
  const PropotionalBidPrizeSkill = IDL.Record({
    'duration': Duration,
    'skill': ChosenOrRandomSkill,
    'position': TargetPosition,
  });
  const PropotionalBidPrizeKind = IDL.Variant({
    'skill': PropotionalBidPrizeSkill,
  });
  const ProportionalBidPrize = IDL.Record({
    'kind': PropotionalBidPrizeKind,
    'description': IDL.Text,
    'amount': IDL.Nat,
  });
  const ProportionalBidScenario = IDL.Record({
    'prize': ProportionalBidPrize,
  });
  const LeagueChoiceScenarioOptionRequest = IDL.Record({
    'title': IDL.Text,
    'townEffect': Effect,
    'description': IDL.Text,
    'leagueEffect': Effect,
    'traitRequirements': IDL.Vec(TraitRequirement),
    'currencyCost': IDL.Nat,
  });
  const LeagueChoiceScenarioRequest = IDL.Record({
    'options': IDL.Vec(LeagueChoiceScenarioOptionRequest),
  });
  const ScenarioKindRequest = IDL.Variant({
    'lottery': LotteryScenario,
    'noLeagueEffect': NoLeagueEffectScenarioRequest,
    'threshold': ThresholdScenarioRequest,
    'textInput': TextInputScenario,
    'proportionalBid': ProportionalBidScenario,
    'leagueChoice': LeagueChoiceScenarioRequest,
  });
  const AddScenarioRequest = IDL.Record({
    'startTime': IDL.Opt(Time),
    'title': IDL.Text,
    'endTime': Time,
    'kind': ScenarioKindRequest,
    'description': IDL.Text,
    'undecidedEffect': Effect,
  });
  const AddScenarioError = IDL.Variant({
    'notAuthorized': IDL.Null,
    'invalid': IDL.Vec(IDL.Text),
  });
  const AddScenarioResult = IDL.Variant({
    'ok': IDL.Null,
    'err': AddScenarioError,
  });
  const AssignUserToTownRequest = IDL.Record({
    'userId': IDL.Principal,
    'townId': IDL.Nat,
  });
  const AssignUserToTownError = IDL.Variant({
    'notAuthorized': IDL.Null,
    'townNotFound': IDL.Null,
    'notLeagueMember': IDL.Null,
  });
  const Result_2 = IDL.Variant({
    'ok': IDL.Null,
    'err': AssignUserToTownError,
  });
  const ClaimBenevolentDictatorRoleError = IDL.Variant({
    'notOpenToClaim': IDL.Null,
    'notAuthenticated': IDL.Null,
  });
  const ClaimBenevolentDictatorRoleResult = IDL.Variant({
    'ok': IDL.Null,
    'err': ClaimBenevolentDictatorRoleError,
  });
  const CloseSeasonError = IDL.Variant({
    'notAuthorized': IDL.Null,
    'seasonNotOpen': IDL.Null,
  });
  const CloseSeasonResult = IDL.Variant({
    'ok': IDL.Null,
    'err': CloseSeasonError,
  });
  const ChangeTownColorContent__1 = IDL.Record({
    'color': IDL.Tuple(IDL.Nat8, IDL.Nat8, IDL.Nat8),
    'townId': IDL.Nat,
  });
  const ChangeTownDescriptionContent__1 = IDL.Record({
    'description': IDL.Text,
    'townId': IDL.Nat,
  });
  const ChangeTownLogoContent__1 = IDL.Record({
    'logoUrl': IDL.Text,
    'townId': IDL.Nat,
  });
  const ChangeTownNameContent__1 = IDL.Record({
    'name': IDL.Text,
    'townId': IDL.Nat,
  });
  const MotionContent__1 = IDL.Record({
    'title': IDL.Text,
    'description': IDL.Text,
  });
  const ChangeTownMottoContent__1 = IDL.Record({
    'motto': IDL.Text,
    'townId': IDL.Nat,
  });
  const CreateLeagueProposalRequest = IDL.Variant({
    'changeTownColor': ChangeTownColorContent__1,
    'changeTownDescription': ChangeTownDescriptionContent__1,
    'changeTownLogo': ChangeTownLogoContent__1,
    'changeTownName': ChangeTownNameContent__1,
    'motion': MotionContent__1,
    'changeTownMotto': ChangeTownMottoContent__1,
  });
  const CreateLeagueProposalError = IDL.Variant({
    'notAuthorized': IDL.Null,
    'invalid': IDL.Vec(IDL.Text),
  });
  const CreateLeagueProposalResult = IDL.Variant({
    'ok': IDL.Nat,
    'err': CreateLeagueProposalError,
  });
  const CreateTownRequest = IDL.Record({
    'motto': IDL.Text,
    'name': IDL.Text,
    'color': IDL.Tuple(IDL.Nat8, IDL.Nat8, IDL.Nat8),
    'description': IDL.Text,
    'entropy': IDL.Nat,
    'logoUrl': IDL.Text,
    'currency': IDL.Nat,
  });
  const CreateTownError = IDL.Variant({
    'nameTaken': IDL.Null,
    'notAuthorized': IDL.Null,
  });
  const CreateTownResult = IDL.Variant({
    'ok': IDL.Nat,
    'err': CreateTownError,
  });
  const TrainContent = IDL.Record({
    'skill': Skill,
    'position': FieldPosition,
  });
  const ChangeTownLogoContent = IDL.Record({ 'logoUrl': IDL.Text });
  const ChangeTownNameContent = IDL.Record({ 'name': IDL.Text });
  const ChangeTownMottoContent = IDL.Record({ 'motto': IDL.Text });
  const ModifyTownLinkContent = IDL.Record({
    'url': IDL.Opt(IDL.Text),
    'name': IDL.Text,
  });
  const ChangeTownColorContent = IDL.Record({
    'color': IDL.Tuple(IDL.Nat8, IDL.Nat8, IDL.Nat8),
  });
  const SwapPlayerPositionsContent = IDL.Record({
    'position1': FieldPosition,
    'position2': FieldPosition,
  });
  const MotionContent = IDL.Record({
    'title': IDL.Text,
    'description': IDL.Text,
  });
  const ChangeTownDescriptionContent = IDL.Record({ 'description': IDL.Text });
  const TownProposalContent = IDL.Variant({
    'train': TrainContent,
    'changeLogo': ChangeTownLogoContent,
    'changeName': ChangeTownNameContent,
    'changeMotto': ChangeTownMottoContent,
    'modifyLink': ModifyTownLinkContent,
    'changeColor': ChangeTownColorContent,
    'swapPlayerPositions': SwapPlayerPositionsContent,
    'motion': MotionContent,
    'changeDescription': ChangeTownDescriptionContent,
  });
  const CreateTownProposalError = IDL.Variant({
    'notAuthorized': IDL.Null,
    'invalid': IDL.Vec(IDL.Text),
    'townNotFound': IDL.Null,
  });
  const CreateTownProposalResult = IDL.Variant({
    'ok': IDL.Nat,
    'err': CreateTownProposalError,
  });
  const CreateTownTraitRequest = IDL.Record({
    'id': IDL.Text,
    'name': IDL.Text,
    'description': IDL.Text,
  });
  const CreateTownTraitError = IDL.Variant({
    'notAuthorized': IDL.Null,
    'invalid': IDL.Vec(IDL.Text),
    'idTaken': IDL.Null,
  });
  const CreateTownTraitResult = IDL.Variant({
    'ok': IDL.Null,
    'err': CreateTownTraitError,
  });
  const Skills = IDL.Record({
    'battingAccuracy': IDL.Int,
    'throwingAccuracy': IDL.Int,
    'speed': IDL.Int,
    'catching': IDL.Int,
    'battingPower': IDL.Int,
    'defense': IDL.Int,
    'throwingPower': IDL.Int,
  });
  const Player = IDL.Record({
    'id': IDL.Nat32,
    'title': IDL.Text,
    'name': IDL.Text,
    'description': IDL.Text,
    'likes': IDL.Vec(IDL.Text),
    'townId': IDL.Nat,
    'position': FieldPosition,
    'quirks': IDL.Vec(IDL.Text),
    'dislikes': IDL.Vec(IDL.Text),
    'skills': Skills,
  });
  const BenevolentDictatorState = IDL.Variant({
    'open': IDL.Null,
    'claimed': IDL.Principal,
    'disabled': IDL.Null,
  });
  const LeagueData = IDL.Record({
    'entropyThreshold': IDL.Nat,
    'currentEntropy': IDL.Nat,
    'leagueIncome': IDL.Nat,
  });
  const ProposalContent__1 = IDL.Variant({
    'changeTownColor': ChangeTownColorContent__1,
    'changeTownDescription': ChangeTownDescriptionContent__1,
    'changeTownLogo': ChangeTownLogoContent__1,
    'changeTownName': ChangeTownNameContent__1,
    'motion': MotionContent__1,
    'changeTownMotto': ChangeTownMottoContent__1,
  });
  const Vote = IDL.Record({
    'value': IDL.Opt(IDL.Bool),
    'votingPower': IDL.Nat,
  });
  const ProposalStatusLogEntry = IDL.Variant({
    'failedToExecute': IDL.Record({ 'time': Time, 'error': IDL.Text }),
    'rejected': IDL.Record({ 'time': Time }),
    'executing': IDL.Record({ 'time': Time }),
    'executed': IDL.Record({ 'time': Time }),
  });
  const LeagueProposal = IDL.Record({
    'id': IDL.Nat,
    'content': ProposalContent__1,
    'timeStart': IDL.Int,
    'votes': IDL.Vec(IDL.Tuple(IDL.Principal, Vote)),
    'statusLog': IDL.Vec(ProposalStatusLogEntry),
    'endTimerId': IDL.Opt(IDL.Nat),
    'timeEnd': IDL.Int,
    'proposerId': IDL.Principal,
  });
  const GetLeagueProposalError = IDL.Variant({ 'proposalNotFound': IDL.Null });
  const GetLeagueProposalResult = IDL.Variant({
    'ok': LeagueProposal,
    'err': GetLeagueProposalError,
  });
  const PagedResult_2 = IDL.Record({
    'data': IDL.Vec(LeagueProposal),
    'count': IDL.Nat,
    'offset': IDL.Nat,
  });
  const GetLeagueProposalsResult = IDL.Variant({ 'ok': PagedResult_2 });
  const PlayerId = IDL.Nat32;
  const OutReason = IDL.Variant({
    'strikeout': IDL.Null,
    'ballCaught': IDL.Null,
    'hitByBall': IDL.Null,
  });
  const TownId = IDL.Variant({ 'town1': IDL.Null, 'town2': IDL.Null });
  const Trait = IDL.Record({
    'id': IDL.Text,
    'name': IDL.Text,
    'description': IDL.Text,
  });
  const Base = IDL.Variant({
    'homeBase': IDL.Null,
    'thirdBase': IDL.Null,
    'secondBase': IDL.Null,
    'firstBase': IDL.Null,
  });
  const Anomoly = IDL.Variant({
    'foggy': IDL.Null,
    'moveBasesIn': IDL.Null,
    'extraStrike': IDL.Null,
    'moreBlessingsAndCurses': IDL.Null,
    'fastBallsHardHits': IDL.Null,
    'explodingBalls': IDL.Null,
    'lowGravity': IDL.Null,
    'doubleOrNothing': IDL.Null,
    'windy': IDL.Null,
    'rainy': IDL.Null,
  });
  const HitLocation = IDL.Variant({
    'rightField': IDL.Null,
    'stands': IDL.Null,
    'leftField': IDL.Null,
    'thirdBase': IDL.Null,
    'pitcher': IDL.Null,
    'secondBase': IDL.Null,
    'shortStop': IDL.Null,
    'centerField': IDL.Null,
    'firstBase': IDL.Null,
  });
  const MatchEndReason = IDL.Variant({
    'noMoreRounds': IDL.Null,
    'error': IDL.Text,
  });
  const MatchEvent = IDL.Variant({
    'out': IDL.Record({ 'playerId': PlayerId, 'reason': OutReason }),
    'throw': IDL.Record({ 'to': PlayerId, 'from': PlayerId }),
    'newBatter': IDL.Record({ 'playerId': PlayerId }),
    'townSwap': IDL.Record({
      'atBatPlayerId': PlayerId,
      'offenseTownId': TownId,
    }),
    'hitByBall': IDL.Record({ 'playerId': PlayerId }),
    'catch': IDL.Record({
      'difficulty': IDL.Record({ 'value': IDL.Int, 'crit': IDL.Bool }),
      'playerId': PlayerId,
      'roll': IDL.Record({ 'value': IDL.Int, 'crit': IDL.Bool }),
    }),
    'traitTrigger': IDL.Record({
      'id': Trait,
      'playerId': PlayerId,
      'description': IDL.Text,
    }),
    'safeAtBase': IDL.Record({ 'base': Base, 'playerId': PlayerId }),
    'anomolyTrigger': IDL.Record({ 'id': Anomoly, 'description': IDL.Text }),
    'score': IDL.Record({ 'townId': TownId, 'amount': IDL.Int }),
    'swing': IDL.Record({
      'pitchRoll': IDL.Record({ 'value': IDL.Int, 'crit': IDL.Bool }),
      'playerId': PlayerId,
      'roll': IDL.Record({ 'value': IDL.Int, 'crit': IDL.Bool }),
      'outcome': IDL.Variant({
        'hit': HitLocation,
        'strike': IDL.Null,
        'foul': IDL.Null,
      }),
    }),
    'injury': IDL.Record({ 'playerId': IDL.Nat32 }),
    'pitch': IDL.Record({
      'roll': IDL.Record({ 'value': IDL.Int, 'crit': IDL.Bool }),
      'pitcherId': PlayerId,
    }),
    'matchEnd': IDL.Record({ 'reason': MatchEndReason }),
    'death': IDL.Record({ 'playerId': IDL.Nat32 }),
  });
  const TurnLog = IDL.Record({ 'events': IDL.Vec(MatchEvent) });
  const RoundLog = IDL.Record({ 'turns': IDL.Vec(TurnLog) });
  const MatchLog = IDL.Record({ 'rounds': IDL.Vec(RoundLog) });
  const LiveMatchStatusCompleted = IDL.Record({ 'reason': MatchEndReason });
  const LiveMatchStatus = IDL.Variant({
    'completed': LiveMatchStatusCompleted,
    'inProgress': IDL.Null,
  });
  const TownPositions = IDL.Record({
    'rightField': IDL.Nat32,
    'leftField': IDL.Nat32,
    'thirdBase': IDL.Nat32,
    'pitcher': IDL.Nat32,
    'secondBase': IDL.Nat32,
    'shortStop': IDL.Nat32,
    'centerField': IDL.Nat32,
    'firstBase': IDL.Nat32,
  });
  const LiveMatchTown = IDL.Record({
    'id': IDL.Nat,
    'anomolies': IDL.Vec(Anomoly),
    'score': IDL.Int,
    'positions': TownPositions,
  });
  const PlayerMatchStatsWithoutId = IDL.Record({
    'battingStats': IDL.Record({
      'homeRuns': IDL.Nat,
      'hits': IDL.Nat,
      'runs': IDL.Nat,
      'strikeouts': IDL.Nat,
      'atBats': IDL.Nat,
    }),
    'injuries': IDL.Nat,
    'pitchingStats': IDL.Record({
      'homeRuns': IDL.Nat,
      'pitches': IDL.Nat,
      'hits': IDL.Nat,
      'runs': IDL.Nat,
      'strikeouts': IDL.Nat,
      'strikes': IDL.Nat,
    }),
    'catchingStats': IDL.Record({
      'missedCatches': IDL.Nat,
      'throwOuts': IDL.Nat,
      'throws': IDL.Nat,
      'successfulCatches': IDL.Nat,
    }),
  });
  const PlayerCondition = IDL.Variant({
    'ok': IDL.Null,
    'dead': IDL.Null,
    'injured': IDL.Null,
  });
  const LivePlayerState = IDL.Record({
    'id': PlayerId,
    'name': IDL.Text,
    'matchStats': PlayerMatchStatsWithoutId,
    'townId': TownId,
    'skills': Skills,
    'condition': PlayerCondition,
  });
  const LiveBaseState = IDL.Record({
    'atBat': PlayerId,
    'thirdBase': IDL.Opt(PlayerId),
    'secondBase': IDL.Opt(PlayerId),
    'firstBase': IDL.Opt(PlayerId),
  });
  const LiveMatchStateWithStatus = IDL.Record({
    'log': MatchLog,
    'status': LiveMatchStatus,
    'town1': LiveMatchTown,
    'town2': LiveMatchTown,
    'outs': IDL.Nat,
    'offenseTownId': TownId,
    'players': IDL.Vec(LivePlayerState),
    'bases': LiveBaseState,
    'strikes': IDL.Nat,
  });
  const LiveMatchGroupState = IDL.Record({
    'id': IDL.Nat,
    'tickTimerId': IDL.Nat,
    'currentSeed': IDL.Nat32,
    'matches': IDL.Vec(LiveMatchStateWithStatus),
  });
  const MatchPredictionSummary = IDL.Record({
    'town1': IDL.Nat,
    'town2': IDL.Nat,
    'yourVote': IDL.Opt(TownId),
  });
  const MatchGroupPredictionSummary = IDL.Record({
    'matches': IDL.Vec(MatchPredictionSummary),
  });
  const GetMatchGroupPredictionsError = IDL.Variant({ 'notFound': IDL.Null });
  const GetMatchGroupPredictionsResult = IDL.Variant({
    'ok': MatchGroupPredictionSummary,
    'err': GetMatchGroupPredictionsError,
  });
  const GetPlayerError = IDL.Variant({ 'notFound': IDL.Null });
  const GetPlayerResult = IDL.Variant({
    'ok': Player,
    'err': GetPlayerError,
  });
  const GetPositionError = IDL.Variant({ 'townNotFound': IDL.Null });
  const Result_1 = IDL.Variant({ 'ok': Player, 'err': GetPositionError });
  const ScenarioOptionDiscrete = IDL.Record({
    'title': IDL.Text,
    'townEffect': Effect,
    'description': IDL.Text,
    'traitRequirements': IDL.Vec(TraitRequirement),
    'currencyCost': IDL.Nat,
    'allowedTownIds': IDL.Vec(IDL.Nat),
  });
  const NoLeagueEffectScenario = IDL.Record({
    'options': IDL.Vec(ScenarioOptionDiscrete),
  });
  const ThresholdValue = IDL.Variant({
    'fixed': IDL.Int,
    'weightedChance': IDL.Vec(
      IDL.Record({
        'weight': IDL.Nat,
        'value': IDL.Int,
        'description': IDL.Text,
      })
    ),
  });
  const ThresholdScenarioOption = IDL.Record({
    'title': IDL.Text,
    'value': ThresholdValue,
    'townEffect': Effect,
    'description': IDL.Text,
    'traitRequirements': IDL.Vec(TraitRequirement),
    'currencyCost': IDL.Nat,
    'allowedTownIds': IDL.Vec(IDL.Nat),
  });
  const ThresholdScenario = IDL.Record({
    'failure': IDL.Record({ 'description': IDL.Text, 'effect': Effect }),
    'minAmount': IDL.Nat,
    'success': IDL.Record({ 'description': IDL.Text, 'effect': Effect }),
    'options': IDL.Vec(ThresholdScenarioOption),
    'undecidedAmount': ThresholdValue,
  });
  const LeagueChoiceScenarioOption = IDL.Record({
    'title': IDL.Text,
    'townEffect': Effect,
    'description': IDL.Text,
    'leagueEffect': Effect,
    'traitRequirements': IDL.Vec(TraitRequirement),
    'currencyCost': IDL.Nat,
    'allowedTownIds': IDL.Vec(IDL.Nat),
  });
  const LeagueChoiceScenario = IDL.Record({
    'options': IDL.Vec(LeagueChoiceScenarioOption),
  });
  const ScenarioKind = IDL.Variant({
    'lottery': LotteryScenario,
    'noLeagueEffect': NoLeagueEffectScenario,
    'threshold': ThresholdScenario,
    'textInput': TextInputScenario,
    'proportionalBid': ProportionalBidScenario,
    'leagueChoice': LeagueChoiceScenario,
  });
  const LotteryScenarioOutcome = IDL.Record({
    'winningTownId': IDL.Opt(IDL.Nat),
  });
  const ThresholdContribution = IDL.Record({
    'townId': IDL.Nat,
    'amount': IDL.Int,
  });
  const ThresholdScenarioOutcome = IDL.Record({
    'contributions': IDL.Vec(ThresholdContribution),
    'successful': IDL.Bool,
  });
  const TextInputScenarioOutcome = IDL.Record({ 'text': IDL.Text });
  const ProportionalWinningBid = IDL.Record({
    'proportion': IDL.Nat,
    'townId': IDL.Nat,
  });
  const ProportionalBidScenarioOutcome = IDL.Record({
    'bids': IDL.Vec(ProportionalWinningBid),
  });
  const LeagueChoiceScenarioOutcome = IDL.Record({
    'optionId': IDL.Opt(IDL.Nat),
  });
  const ScenarioOutcome = IDL.Variant({
    'lottery': LotteryScenarioOutcome,
    'noLeagueEffect': IDL.Null,
    'threshold': ThresholdScenarioOutcome,
    'textInput': TextInputScenarioOutcome,
    'proportionalBid': ProportionalBidScenarioOutcome,
    'leagueChoice': LeagueChoiceScenarioOutcome,
  });
  const ScenarioResolvedOptionRaw = IDL.Record({
    'value': IDL.Nat,
    'chosenByTownIds': IDL.Vec(IDL.Nat),
  });
  const ScenarioResolvedOptionRaw_1 = IDL.Record({
    'value': IDL.Text,
    'chosenByTownIds': IDL.Vec(IDL.Nat),
  });
  const ScenarioResolvedOptionDiscrete = IDL.Record({
    'id': IDL.Nat,
    'title': IDL.Text,
    'townEffect': Effect,
    'seenByTownIds': IDL.Vec(IDL.Nat),
    'description': IDL.Text,
    'traitRequirements': IDL.Vec(TraitRequirement),
    'chosenByTownIds': IDL.Vec(IDL.Nat),
    'currencyCost': IDL.Nat,
  });
  const ScenarioResolvedOptionsKind = IDL.Variant({
    'nat': IDL.Vec(ScenarioResolvedOptionRaw),
    'text': IDL.Vec(ScenarioResolvedOptionRaw_1),
    'discrete': IDL.Vec(ScenarioResolvedOptionDiscrete),
  });
  const ScenarioResolvedOptions = IDL.Record({
    'undecidedOption': IDL.Record({
      'townEffect': Effect,
      'chosenByTownIds': IDL.Vec(IDL.Nat),
    }),
    'kind': ScenarioResolvedOptionsKind,
  });
  const TownTraitTownEffectOutcome = IDL.Record({
    'kind': TownTraitEffectKind,
    'traitId': IDL.Text,
    'townId': IDL.Nat,
  });
  const EntropyTownEffectOutcome = IDL.Record({
    'townId': IDL.Nat,
    'delta': IDL.Int,
  });
  const EntropyThresholdEffectOutcome = IDL.Record({ 'delta': IDL.Int });
  const TargetPositionInstance = IDL.Record({
    'townId': IDL.Nat,
    'position': FieldPosition,
  });
  const SkillPlayerEffectOutcome = IDL.Record({
    'duration': Duration,
    'skill': Skill,
    'position': TargetPositionInstance,
    'delta': IDL.Int,
  });
  const InjuryPlayerEffectOutcome = IDL.Record({
    'position': TargetPositionInstance,
  });
  const CurrencyTownEffectOutcome = IDL.Record({
    'townId': IDL.Nat,
    'delta': IDL.Int,
  });
  const LeagueIncomeEffectOutcome = IDL.Record({ 'delta': IDL.Int });
  const EffectOutcome = IDL.Variant({
    'townTrait': TownTraitTownEffectOutcome,
    'entropy': EntropyTownEffectOutcome,
    'entropyThreshold': EntropyThresholdEffectOutcome,
    'skill': SkillPlayerEffectOutcome,
    'injury': InjuryPlayerEffectOutcome,
    'currency': CurrencyTownEffectOutcome,
    'leagueIncome': LeagueIncomeEffectOutcome,
  });
  const ScenarioStateResolved = IDL.Record({
    'scenarioOutcome': ScenarioOutcome,
    'options': ScenarioResolvedOptions,
    'effectOutcomes': IDL.Vec(EffectOutcome),
  });
  const ScenarioState = IDL.Variant({
    'notStarted': IDL.Null,
    'resolved': ScenarioStateResolved,
    'resolving': IDL.Null,
    'inProgress': IDL.Null,
  });
  const Scenario = IDL.Record({
    'id': IDL.Nat,
    'startTime': IDL.Int,
    'title': IDL.Text,
    'endTime': IDL.Int,
    'kind': ScenarioKind,
    'description': IDL.Text,
    'undecidedEffect': Effect,
    'state': ScenarioState,
  });
  const GetScenarioError = IDL.Variant({
    'notStarted': IDL.Null,
    'notFound': IDL.Null,
  });
  const GetScenarioResult = IDL.Variant({
    'ok': Scenario,
    'err': GetScenarioError,
  });
  const GetScenarioVoteRequest = IDL.Record({ 'scenarioId': IDL.Nat });
  const ScenarioOptionValue = IDL.Variant({
    'id': IDL.Nat,
    'nat': IDL.Nat,
    'text': IDL.Text,
  });
  const ScenarioTownOptionNat = IDL.Record({
    'value': IDL.Nat,
    'currentVotingPower': IDL.Nat,
  });
  const ScenarioTownOptionText = IDL.Record({
    'value': IDL.Text,
    'currentVotingPower': IDL.Nat,
  });
  const ScenarioTownOptionDiscrete = IDL.Record({
    'id': IDL.Nat,
    'title': IDL.Text,
    'description': IDL.Text,
    'traitRequirements': IDL.Vec(TraitRequirement),
    'currentVotingPower': IDL.Nat,
    'currencyCost': IDL.Nat,
  });
  const ScenarioTownOptions = IDL.Variant({
    'nat': IDL.Vec(ScenarioTownOptionNat),
    'text': IDL.Vec(ScenarioTownOptionText),
    'discrete': IDL.Vec(ScenarioTownOptionDiscrete),
  });
  const TownVotingPower = IDL.Record({ 'total': IDL.Nat, 'voted': IDL.Nat });
  const ScenarioVote = IDL.Record({
    'value': IDL.Opt(ScenarioOptionValue),
    'townOptions': ScenarioTownOptions,
    'votingPower': IDL.Nat,
    'townId': IDL.Nat,
    'townVotingPower': TownVotingPower,
  });
  const VotingData = IDL.Record({
    'townIdsWithConsensus': IDL.Vec(IDL.Nat),
    'yourData': IDL.Opt(ScenarioVote),
  });
  const GetScenarioVoteError = IDL.Variant({
    'notEligible': IDL.Null,
    'scenarioNotFound': IDL.Null,
  });
  const GetScenarioVoteResult = IDL.Variant({
    'ok': VotingData,
    'err': GetScenarioVoteError,
  });
  const GetScenariosResult = IDL.Variant({ 'ok': IDL.Vec(Scenario) });
  const CompletedSeasonTown = IDL.Record({
    'id': IDL.Nat,
    'wins': IDL.Nat,
    'losses': IDL.Nat,
    'totalScore': IDL.Int,
  });
  const PlayerMatchStats = IDL.Record({
    'playerId': PlayerId,
    'battingStats': IDL.Record({
      'homeRuns': IDL.Nat,
      'hits': IDL.Nat,
      'runs': IDL.Nat,
      'strikeouts': IDL.Nat,
      'atBats': IDL.Nat,
    }),
    'injuries': IDL.Nat,
    'pitchingStats': IDL.Record({
      'homeRuns': IDL.Nat,
      'pitches': IDL.Nat,
      'hits': IDL.Nat,
      'runs': IDL.Nat,
      'strikeouts': IDL.Nat,
      'strikes': IDL.Nat,
    }),
    'catchingStats': IDL.Record({
      'missedCatches': IDL.Nat,
      'throwOuts': IDL.Nat,
      'throws': IDL.Nat,
      'successfulCatches': IDL.Nat,
    }),
  });
  const CompletedMatchTown = IDL.Record({
    'id': IDL.Nat,
    'anomolies': IDL.Vec(Anomoly),
    'score': IDL.Int,
    'playerStats': IDL.Vec(PlayerMatchStats),
    'positions': TownPositions,
  });
  const TownIdOrTie = IDL.Variant({
    'tie': IDL.Null,
    'town1': IDL.Null,
    'town2': IDL.Null,
  });
  const CompletedMatch = IDL.Record({
    'town1': CompletedMatchTown,
    'town2': CompletedMatchTown,
    'winner': TownIdOrTie,
  });
  const CompletedMatchGroup = IDL.Record({
    'time': Time,
    'matches': IDL.Vec(CompletedMatch),
  });
  const TownAssignment = IDL.Variant({
    'winnerOfMatch': IDL.Nat,
    'predetermined': IDL.Nat,
    'seasonStandingIndex': IDL.Nat,
  });
  const NotScheduledMatch = IDL.Record({
    'town1': TownAssignment,
    'town2': TownAssignment,
  });
  const NotScheduledMatchGroup = IDL.Record({
    'time': Time,
    'matches': IDL.Vec(NotScheduledMatch),
  });
  const CompletedSeasonOutcomeFailure = IDL.Record({
    'incompleteMatchGroups': IDL.Vec(NotScheduledMatchGroup),
  });
  const CompletedSeasonOutcomeSuccess = IDL.Record({
    'runnerUpTownId': IDL.Nat,
    'championTownId': IDL.Nat,
  });
  const CompletedSeasonOutcome = IDL.Variant({
    'failure': CompletedSeasonOutcomeFailure,
    'success': CompletedSeasonOutcomeSuccess,
  });
  const CompletedSeason = IDL.Record({
    'towns': IDL.Vec(CompletedSeasonTown),
    'completedMatchGroups': IDL.Vec(CompletedMatchGroup),
    'outcome': CompletedSeasonOutcome,
  });
  const ScheduledTownInfo = IDL.Record({ 'id': IDL.Nat });
  const ScheduledMatch = IDL.Record({
    'town1': ScheduledTownInfo,
    'town2': ScheduledTownInfo,
  });
  const ScheduledMatchGroup = IDL.Record({
    'time': Time,
    'matches': IDL.Vec(ScheduledMatch),
    'timerId': IDL.Nat,
  });
  const InProgressTown = IDL.Record({
    'id': IDL.Nat,
    'anomolies': IDL.Vec(Anomoly),
    'positions': TownPositions,
  });
  const InProgressMatch = IDL.Record({
    'town1': InProgressTown,
    'town2': InProgressTown,
  });
  const InProgressMatchGroup = IDL.Record({
    'time': Time,
    'matches': IDL.Vec(InProgressMatch),
  });
  const InProgressSeasonMatchGroupVariant = IDL.Variant({
    'scheduled': ScheduledMatchGroup,
    'completed': CompletedMatchGroup,
    'inProgress': InProgressMatchGroup,
    'notScheduled': NotScheduledMatchGroup,
  });
  const InProgressSeason = IDL.Record({
    'matchGroups': IDL.Vec(InProgressSeasonMatchGroupVariant),
  });
  const SeasonStatus = IDL.Variant({
    'notStarted': IDL.Null,
    'completed': CompletedSeason,
    'inProgress': InProgressSeason,
  });
  const GetTownOwnersRequest = IDL.Variant({
    'all': IDL.Null,
    'town': IDL.Nat,
  });
  const UserVotingInfo = IDL.Record({
    'id': IDL.Principal,
    'votingPower': IDL.Nat,
    'townId': IDL.Nat,
  });
  const GetTownOwnersResult = IDL.Variant({ 'ok': IDL.Vec(UserVotingInfo) });
  const ProposalContent = IDL.Variant({
    'train': TrainContent,
    'changeLogo': ChangeTownLogoContent,
    'changeName': ChangeTownNameContent,
    'changeMotto': ChangeTownMottoContent,
    'modifyLink': ModifyTownLinkContent,
    'changeColor': ChangeTownColorContent,
    'swapPlayerPositions': SwapPlayerPositionsContent,
    'motion': MotionContent,
    'changeDescription': ChangeTownDescriptionContent,
  });
  const TownProposal = IDL.Record({
    'id': IDL.Nat,
    'content': ProposalContent,
    'timeStart': IDL.Int,
    'votes': IDL.Vec(IDL.Tuple(IDL.Principal, Vote)),
    'statusLog': IDL.Vec(ProposalStatusLogEntry),
    'endTimerId': IDL.Opt(IDL.Nat),
    'timeEnd': IDL.Int,
    'proposerId': IDL.Principal,
  });
  const GetTownProposalError = IDL.Variant({
    'proposalNotFound': IDL.Null,
    'townNotFound': IDL.Null,
  });
  const GetTownProposalResult = IDL.Variant({
    'ok': TownProposal,
    'err': GetTownProposalError,
  });
  const Proposal = IDL.Record({
    'id': IDL.Nat,
    'content': ProposalContent,
    'timeStart': IDL.Int,
    'votes': IDL.Vec(IDL.Tuple(IDL.Principal, Vote)),
    'statusLog': IDL.Vec(ProposalStatusLogEntry),
    'endTimerId': IDL.Opt(IDL.Nat),
    'timeEnd': IDL.Int,
    'proposerId': IDL.Principal,
  });
  const PagedResult_1 = IDL.Record({
    'data': IDL.Vec(Proposal),
    'count': IDL.Nat,
    'offset': IDL.Nat,
  });
  const GetTownProposalsError = IDL.Variant({ 'townNotFound': IDL.Null });
  const GetTownProposalsResult = IDL.Variant({
    'ok': PagedResult_1,
    'err': GetTownProposalsError,
  });
  const TownStandingInfo = IDL.Record({
    'id': IDL.Nat,
    'wins': IDL.Nat,
    'losses': IDL.Nat,
    'totalScore': IDL.Int,
  });
  const GetTownStandingsError = IDL.Variant({ 'notFound': IDL.Null });
  const GetTownStandingsResult = IDL.Variant({
    'ok': IDL.Vec(TownStandingInfo),
    'err': GetTownStandingsError,
  });
  const Link = IDL.Record({ 'url': IDL.Text, 'name': IDL.Text });
  const Town = IDL.Record({
    'id': IDL.Nat,
    'motto': IDL.Text,
    'traits': IDL.Vec(Trait),
    'name': IDL.Text,
    'color': IDL.Tuple(IDL.Nat8, IDL.Nat8, IDL.Nat8),
    'description': IDL.Text,
    'links': IDL.Vec(Link),
    'entropy': IDL.Nat,
    'logoUrl': IDL.Text,
    'currency': IDL.Int,
  });
  const UserMembership = IDL.Record({
    'votingPower': IDL.Nat,
    'townId': IDL.Nat,
  });
  const User = IDL.Record({
    'id': IDL.Principal,
    'membership': IDL.Opt(UserMembership),
    'points': IDL.Int,
  });
  const GetUserError = IDL.Variant({
    'notAuthorized': IDL.Null,
    'notFound': IDL.Null,
  });
  const GetUserResult = IDL.Variant({ 'ok': User, 'err': GetUserError });
  const GetUserLeaderboardRequest = IDL.Record({
    'count': IDL.Nat,
    'offset': IDL.Nat,
  });
  const PagedResult = IDL.Record({
    'data': IDL.Vec(User),
    'count': IDL.Nat,
    'offset': IDL.Nat,
  });
  const GetUserLeaderboardResult = IDL.Variant({ 'ok': PagedResult });
  const TownStats = IDL.Record({
    'id': IDL.Nat,
    'totalPoints': IDL.Int,
    'ownerCount': IDL.Nat,
    'userCount': IDL.Nat,
  });
  const UserStats = IDL.Record({
    'towns': IDL.Vec(TownStats),
    'townOwnerCount': IDL.Nat,
    'totalPoints': IDL.Int,
    'userCount': IDL.Nat,
  });
  const GetUserStatsResult = IDL.Variant({
    'ok': UserStats,
    'err': IDL.Null,
  });
  const JoinLeagueError = IDL.Variant({
    'notAuthorized': IDL.Null,
    'noTowns': IDL.Null,
    'alreadyLeagueMember': IDL.Null,
  });
  const Result = IDL.Variant({ 'ok': IDL.Null, 'err': JoinLeagueError });
  const PredictMatchOutcomeRequest = IDL.Record({
    'winner': IDL.Opt(TownId),
    'matchId': IDL.Nat,
  });
  const PredictMatchOutcomeError = IDL.Variant({
    'predictionsClosed': IDL.Null,
    'matchNotFound': IDL.Null,
    'matchGroupNotFound': IDL.Null,
    'identityRequired': IDL.Null,
  });
  const PredictMatchOutcomeResult = IDL.Variant({
    'ok': IDL.Null,
    'err': PredictMatchOutcomeError,
  });
  const SetBenevolentDictatorStateError = IDL.Variant({
    'notAuthorized': IDL.Null,
  });
  const SetBenevolentDictatorStateResult = IDL.Variant({
    'ok': IDL.Null,
    'err': SetBenevolentDictatorStateError,
  });
  const TownIdOrBoth = IDL.Variant({
    'town1': IDL.Null,
    'town2': IDL.Null,
    'bothTowns': IDL.Null,
  });
  const StartMatchError = IDL.Variant({ 'notEnoughPlayers': TownIdOrBoth });
  const StartMatchGroupError = IDL.Variant({
    'notAuthorized': IDL.Null,
    'notScheduledYet': IDL.Null,
    'matchGroupNotFound': IDL.Null,
    'alreadyStarted': IDL.Null,
    'matchErrors': IDL.Vec(
      IDL.Record({ 'error': StartMatchError, 'matchId': IDL.Nat })
    ),
  });
  const StartMatchGroupResult = IDL.Variant({
    'ok': IDL.Null,
    'err': StartMatchGroupError,
  });
  const DayOfWeek = IDL.Variant({
    'tuesday': IDL.Null,
    'wednesday': IDL.Null,
    'saturday': IDL.Null,
    'thursday': IDL.Null,
    'sunday': IDL.Null,
    'friday': IDL.Null,
    'monday': IDL.Null,
  });
  const StartSeasonRequest = IDL.Record({
    'startTime': Time,
    'weekDays': IDL.Vec(DayOfWeek),
  });
  const StartSeasonError = IDL.Variant({
    'notAuthorized': IDL.Null,
    'seedGenerationError': IDL.Text,
    'alreadyStarted': IDL.Null,
    'idTaken': IDL.Null,
    'invalidArgs': IDL.Text,
  });
  const StartSeasonResult = IDL.Variant({
    'ok': IDL.Null,
    'err': StartSeasonError,
  });
  const VoteOnLeagueProposalRequest = IDL.Record({
    'vote': IDL.Bool,
    'proposalId': IDL.Nat,
  });
  const VoteOnLeagueProposalError = IDL.Variant({
    'proposalNotFound': IDL.Null,
    'notAuthorized': IDL.Null,
    'alreadyVoted': IDL.Null,
    'votingClosed': IDL.Null,
  });
  const VoteOnLeagueProposalResult = IDL.Variant({
    'ok': IDL.Null,
    'err': VoteOnLeagueProposalError,
  });
  const VoteOnScenarioRequest = IDL.Record({
    'scenarioId': IDL.Nat,
    'value': ScenarioOptionValue,
  });
  const VoteOnScenarioError = IDL.Variant({
    'votingNotOpen': IDL.Null,
    'invalidValue': IDL.Null,
    'notEligible': IDL.Null,
    'scenarioNotFound': IDL.Null,
  });
  const VoteOnScenarioResult = IDL.Variant({
    'ok': IDL.Null,
    'err': VoteOnScenarioError,
  });
  const VoteOnTownProposalRequest = IDL.Record({
    'vote': IDL.Bool,
    'proposalId': IDL.Nat,
  });
  const VoteOnTownProposalError = IDL.Variant({
    'proposalNotFound': IDL.Null,
    'notAuthorized': IDL.Null,
    'alreadyVoted': IDL.Null,
    'votingClosed': IDL.Null,
    'townNotFound': IDL.Null,
  });
  const VoteOnTownProposalResult = IDL.Variant({
    'ok': IDL.Null,
    'err': VoteOnTownProposalError,
  });
  return IDL.Service({
    'addFluff': IDL.Func(
      [CreatePlayerFluffRequest],
      [CreatePlayerFluffResult],
      [],
    ),
    'addScenario': IDL.Func([AddScenarioRequest], [AddScenarioResult], []),
    'assignUserToTown': IDL.Func([AssignUserToTownRequest], [Result_2], []),
    'claimBenevolentDictatorRole': IDL.Func(
      [],
      [ClaimBenevolentDictatorRoleResult],
      [],
    ),
    'closeSeason': IDL.Func([], [CloseSeasonResult], []),
    'createLeagueProposal': IDL.Func(
      [CreateLeagueProposalRequest],
      [CreateLeagueProposalResult],
      [],
    ),
    'createTown': IDL.Func([CreateTownRequest], [CreateTownResult], []),
    'createTownProposal': IDL.Func(
      [IDL.Nat, TownProposalContent],
      [CreateTownProposalResult],
      [],
    ),
    'createTownTrait': IDL.Func(
      [CreateTownTraitRequest],
      [CreateTownTraitResult],
      [],
    ),
    'getAllPlayers': IDL.Func([], [IDL.Vec(Player)], ['query']),
    'getBenevolentDictatorState': IDL.Func(
      [],
      [BenevolentDictatorState],
      ['query'],
    ),
    'getLeagueData': IDL.Func([], [LeagueData], ['query']),
    'getLeagueProposal': IDL.Func(
      [IDL.Nat],
      [GetLeagueProposalResult],
      ['query'],
    ),
    'getLeagueProposals': IDL.Func(
      [IDL.Nat, IDL.Nat],
      [GetLeagueProposalsResult],
      ['query'],
    ),
    'getLiveMatchGroupState': IDL.Func(
      [],
      [IDL.Opt(LiveMatchGroupState)],
      ['query'],
    ),
    'getMatchGroupPredictions': IDL.Func(
      [IDL.Nat],
      [GetMatchGroupPredictionsResult],
      ['query'],
    ),
    'getPlayer': IDL.Func([IDL.Nat32], [GetPlayerResult], ['query']),
    'getPosition': IDL.Func([IDL.Nat, FieldPosition], [Result_1], ['query']),
    'getScenario': IDL.Func([IDL.Nat], [GetScenarioResult], ['query']),
    'getScenarioVote': IDL.Func(
      [GetScenarioVoteRequest],
      [GetScenarioVoteResult],
      ['query'],
    ),
    'getScenarios': IDL.Func([], [GetScenariosResult], ['query']),
    'getSeasonStatus': IDL.Func([], [SeasonStatus], ['query']),
    'getTownOwners': IDL.Func(
      [GetTownOwnersRequest],
      [GetTownOwnersResult],
      ['query'],
    ),
    'getTownPlayers': IDL.Func([IDL.Nat], [IDL.Vec(Player)], ['query']),
    'getTownProposal': IDL.Func(
      [IDL.Nat, IDL.Nat],
      [GetTownProposalResult],
      ['query'],
    ),
    'getTownProposals': IDL.Func(
      [IDL.Nat, IDL.Nat, IDL.Nat],
      [GetTownProposalsResult],
      ['query'],
    ),
    'getTownStandings': IDL.Func([], [GetTownStandingsResult], ['query']),
    'getTowns': IDL.Func([], [IDL.Vec(Town)], ['query']),
    'getTraits': IDL.Func([], [IDL.Vec(Trait)], ['query']),
    'getUser': IDL.Func([IDL.Principal], [GetUserResult], ['query']),
    'getUserLeaderboard': IDL.Func(
      [GetUserLeaderboardRequest],
      [GetUserLeaderboardResult],
      ['query'],
    ),
    'getUserStats': IDL.Func([], [GetUserStatsResult], ['query']),
    'joinLeague': IDL.Func([], [Result], []),
    'predictMatchOutcome': IDL.Func(
      [PredictMatchOutcomeRequest],
      [PredictMatchOutcomeResult],
      [],
    ),
    'setBenevolentDictatorState': IDL.Func(
      [BenevolentDictatorState],
      [SetBenevolentDictatorStateResult],
      [],
    ),
    'startNextMatchGroup': IDL.Func([], [StartMatchGroupResult], []),
    'startSeason': IDL.Func([StartSeasonRequest], [StartSeasonResult], []),
    'voteOnLeagueProposal': IDL.Func(
      [VoteOnLeagueProposalRequest],
      [VoteOnLeagueProposalResult],
      [],
    ),
    'voteOnScenario': IDL.Func(
      [VoteOnScenarioRequest],
      [VoteOnScenarioResult],
      [],
    ),
    'voteOnTownProposal': IDL.Func(
      [IDL.Nat, VoteOnTownProposalRequest],
      [VoteOnTownProposalResult],
      [],
    ),
  });
};
export const init = ({ IDL }) => { return []; };
