import Principal "mo:base/Principal";
import Player "../models/Player";
import DateTime "mo:datetime/DateTime";
import Time "mo:base/Time";
import Trie "mo:base/Trie";
import Hash "mo:base/Hash";
import Nat "mo:base/Nat";
import Offering "../models/Offering";
import MatchAura "../models/MatchAura";
import Base "../models/Base";
import Team "../models/Team";

module {
    type FieldPosition = Player.FieldPosition;
    type Base = Base.Base;
    type PlayerId = Player.PlayerId;

    public type StadiumActor = actor {
        getMatchGroup : query (id : Nat) -> async ?MatchGroupWithId;
        tickMatchGroup : (id : Nat) -> async TickMatchGroupResult;
        scheduleMatchGroup : (request : ScheduleMatchGroupRequest) -> async ScheduleMatchGroupResult;
        resetTickTimer(matchGroupId : Nat) : async ResetTickTimerResult;
    };

    public type ResetTickTimerResult = {
        #ok;
        #matchGroupNotFound;
        #matchGroupNotStarted;
        #matchGroupComplete;
    };

    public type ScheduleMatchGroupRequest = {
        id : Nat;
        startTime : Time.Time;
        matches : [ScheduleMatchRequest];
    };

    public type ScheduleMatchRequest = {
        team1Id : Principal;
        team2Id : Principal;
        offerings : [Offering.Offering];
        aura : MatchAura.MatchAura;
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
        #teamNotFound : Team.TeamIdOrBoth;
    };

    public type PlayerState = {
        teamId : Team.TeamId;
        condition : Player.PlayerCondition;
        skills : Player.PlayerSkills;
        position : FieldPosition;
    };

    public type PlayerStateWithId = PlayerState and {
        id : PlayerId;
    };

    public type TeamState = {
        score : Int;
        offering : Offering.Offering;
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
        message : Text;
        isImportant : Bool;
    };

    public type InProgressMatchState = {
        offenseTeamId : Team.TeamId;
        team1 : TeamState;
        team2 : TeamState;
        aura : MatchAura.MatchAura;
        players : [PlayerStateWithId];
        field : FieldState;
        log : [LogEntry];
        round : Nat;
        outs : Nat;
        strikes : Nat;
    };

    public type PlayerNotFoundError = {
        id : PlayerId;
        teamId : ?Team.TeamId;
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
        #absentTeam : Team.TeamId;
        #allAbsent;
        #played : PlayedMatchState;
        #stateBroken : BrokenState;
    };

    public type PlayedMatchState = {
        team1 : PlayedTeamState;
        team2 : PlayedTeamState;
        winner : Team.TeamIdOrTie;
        log : [LogEntry];
    };

    public type PlayedTeamState = {
        score : Int;
    };

    public type MatchWithoutState = {
        team1 : MatchTeam;
        team2 : MatchTeam;
        offerings : [Offering.OfferingWithMetaData];
        aura : MatchAura.MatchAuraWithMetaData;
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
        id : Nat;
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
};
