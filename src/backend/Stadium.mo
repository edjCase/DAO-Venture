import Principal "mo:base/Principal";
import Player "Player";
import DateTime "mo:datetime/DateTime";
import Time "mo:base/Time";
import Nat32 "mo:base/Nat32";
import Trie "mo:base/Trie";
import Hash "mo:base/Hash";
import Nat "mo:base/Nat";

module {
    type FieldPosition = Player.FieldPosition;
    type Base = Player.Base;
    type PlayerId = Player.PlayerId;

    public type StadiumActor = actor {
        getMatchGroup : query (id : Nat32) -> async ?MatchGroupWithId;
        tickMatchGroup : (id : Nat32) -> async TickMatchGroupResult;
        scheduleMatchGroup : (request : ScheduleMatchGroupRequest) -> async ScheduleMatchGroupResult;
        resetTickTimer(matchGroupId : Nat32) : async ResetTickTimerResult;
    };

    public type ResetTickTimerResult = {
        #ok;
        #matchGroupNotFound;
        #matchGroupNotStarted;
        #matchGroupComplete;
    };

    public type RegisterResult = {
        #ok;
        #matchNotFound;
        #teamNotInMatch;
        #matchAlreadyStarted;
        #invalidInfo : [RegistrationInfoError];
    };

    public type RegistrationInfoError = {
        #invalidOffering : Offering;
        #invalidChampionId : PlayerId;
    };

    public type ScheduleMatchGroupRequest = {
        id : Nat32;
        startTime : Time.Time;
        matches : [ScheduleMatchRequest];
    };

    public type ScheduleMatchRequest = {
        team1Id : Principal;
        team2Id : Principal;
        offerings : [Offering];
        aura : MatchAura;
    };

    public type ScheduleMatchGroupError = {
        #teamFetchError : Text;
        #matchErrors : [ScheduleMatchError];
        #noMatchesSpecified;
        #playerFetchError : Text;
    };
    public type ScheduleMatchGroupResult = ScheduleMatchGroupError or {
        #ok : MatchGroupWithId;
    };

    public type ScheduleMatchError = {
        #teamNotFound : TeamIdOrBoth;
    };

    public type TeamId = {
        #team1;
        #team2;
    };

    public type TeamIdOrBoth = TeamId or { #bothTeams };

    public type MatchEndReason = {
        #noMoreRounds;
        #outOfPlayers : TeamIdOrBoth;
        #stateBroken : BrokenStateError;
    };

    public type PlayerState = {
        teamId : TeamId;
        condition : Player.PlayerCondition;
        skills : Player.PlayerSkills;
        position : FieldPosition;
    };

    public type PlayerStateWithId = PlayerState and {
        id : PlayerId;
    };

    public type TeamState = {
        score : Int;
        offering : Offering;
        championId : PlayerId;
    };

    public type DefenseFieldState = {
        firstBase : PlayerId;
        secondBase : PlayerId;
        thirdBase : PlayerId;
        shortStop : PlayerId;
        pitcher : PlayerId;
        leftField : PlayerId;
        centerField : PlayerId;
        rightField : PlayerId;
    };

    public type OffenseFieldState = {
        atBat : PlayerId;
        firstBase : ?PlayerId;
        secondBase : ?PlayerId;
        thirdBase : ?PlayerId;
    };

    public type FieldState = {
        defense : DefenseFieldState;
        offense : OffenseFieldState;
    };

    public type LogEntry = {
        description : Text;
        isImportant : Bool;
    };

    public type InProgressMatchState = {
        offenseTeamId : TeamId;
        team1 : TeamState;
        team2 : TeamState;
        aura : MatchAura;
        players : [PlayerStateWithId];
        field : FieldState;
        log : [LogEntry];
        round : Nat;
        outs : Nat;
        strikes : Nat;
    };

    public type PlayerNotFoundError = {
        id : PlayerId;
        teamId : ?TeamId;
    };
    public type PlayerExpectedOnFieldError = {
        id : PlayerId;
        onOffense : Bool;
        description : Text;
    };

    public type BrokenStateError = {
        #playerNotFound : PlayerNotFoundError;
        #playerExpectedOnField : PlayerExpectedOnFieldError;
    };

    public type BrokenState = {
        log : [LogEntry];
        error : BrokenStateError;
    };

    public type CompletedMatchState = {
        #absentTeam : TeamId;
        #allAbsent;
        #played : PlayedMatchState;
        #stateBroken : BrokenState;
    };

    public type TeamIdOrTie = TeamId or { #tie };

    public type PlayedMatchState = {
        team1 : PlayedTeamState;
        team2 : PlayedTeamState;
        winner : TeamIdOrTie;
        log : [LogEntry];
    };

    public type PlayedTeamState = {
        score : Int;
    };

    public type StartMatchGroupResult = {
        #inProgress : InProgressMatchGroupState;
        #matchGroupNotFound;
        #matchGroupAlreadyStarted;
        #completed : CompletedMatchGroupState;
    };

    public type Stadium = {};

    public type StadiumWithId = Stadium and {
        id : Principal;
    };

    public type Offering = {
        #shuffleAndBoost;
    };
    public type OfferingMetaData = {
        name : Text;
        description : Text;
    };

    public type OfferingWithMetaData = OfferingMetaData and {
        offering : Offering;
    };

    public func hashOffering(offering : Offering) : Nat32 = switch (offering) {
        case (#shuffleAndBoost) 0;
    };

    public func equalOffering(a : Offering, b : Offering) : Bool = a == b;

    public func getOfferingMetaData(offering : Offering) : OfferingMetaData {
        switch (offering) {
            case (#shuffleAndBoost) {
                {
                    name = "Shuffle And Boost";
                    description = "Shuffle your team's field positions and boost your team with a random blessing.";
                };
            };
        };
    };

    public func getMatchAuraMetaData(aura : MatchAura) : MatchAuraMetaData {
        switch (aura) {
            case (#lowGravity) {
                {
                    name = "Low Gravity";
                    description = "Balls fly farther and players jump higher.";
                };
            };
            case (#explodingBalls) {
                {
                    name = "Exploding Balls";
                    description = "Balls have a chance to explode on contact with the bat.";
                };
            };
            case (#fastBallsHardHits) {
                {
                    name = "Fast Balls, Hard Hits";
                    description = "Balls are faster and fly farther when hit by the bat.";
                };
            };
            case (#moreBlessingsAndCurses) {
                {
                    name = "More Blessings And Curses";
                    description = "Blessings and curses are more common.";
                };
            };
        };
    };

    public type MatchAura = {
        #lowGravity;
        #explodingBalls;
        #fastBallsHardHits;
        #moreBlessingsAndCurses;
    };

    public type MatchAuraMetaData = {
        name : Text;
        description : Text;
    };

    public type MatchAuraWithMetaData = MatchAuraMetaData and {
        aura : MatchAura;
    };

    public func hashMatchAura(aura : MatchAura) : Nat32 = switch (aura) {
        case (#lowGravity) 0;
        case (#explodingBalls) 1;
        case (#fastBallsHardHits) 2;
        case (#moreBlessingsAndCurses) 3;
    };

    public func equalMatchAura(a : MatchAura, b : MatchAura) : Bool = a == b;

    public type MatchWithoutState = {
        team1 : MatchTeam;
        team2 : MatchTeam;
        offerings : [OfferingWithMetaData];
        aura : MatchAuraWithMetaData;
    };

    public type Match = MatchWithoutState and {
        state : MatchState;
    };

    public type StartedMatchState = {
        #inProgress : InProgressMatchState;
        #completed : CompletedMatchState;
    };

    public type MatchState = StartedMatchState or {
        #notStarted;
    };

    public type MatchGroup = {
        time : Time.Time;
        matches : [Match];
        state : MatchGroupState;
    };

    public type MatchGroupWithId = MatchGroup and {
        id : Nat32;
    };

    public type StartedMatchGroupState = {
        #inProgress : InProgressMatchGroupState;
        #completed : CompletedMatchGroupState;
    };

    public type MatchGroupState = StartedMatchGroupState or {
        #notStarted : NotStartedMatchGroupState;
    };

    public type NotStartedMatchGroupState = {
        startTimerId : Nat;
    };

    public type InProgressMatchGroupState = {
        tickTimerId : Nat;
        currentSeed : Nat32;
        matches : [StartedMatchState];
    };

    public type CompletedMatchGroupState = {
        matches : [CompletedMatchState];
    };

    public type TickMatchGroupResult = {
        #inProgress;
        #matchGroupNotFound;
        #onStartCallbackError : {
            #unknown : Text;
            #notScheduledYet;
            #alreadyStarted;
            #notAuthorized;
            #matchGroupNotFound;
        };
        #completed;
    };

    public type MatchOptions = {
        offering : Offering;
        championId : PlayerId;
    };

    public type MatchPlayer = {
        id : PlayerId;
        name : Text;
    };

    public type MatchTeam = {
        id : Principal;
        name : Text;
        logoUrl : Text;
        predictionVotes : Nat;
        players : [MatchPlayer];
    };

    public type Blessing = {
        #skill : Player.Skill;
    };

    public type Curse = {
        #skill : Player.Skill;
        #injury : Player.Injury;
    };
};
