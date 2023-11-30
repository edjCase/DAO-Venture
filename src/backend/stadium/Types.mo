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
        resetTickTimer : (matchGroupId : Nat) -> async ResetTickTimerResult;
        startMatchGroup : (request : StartMatchGroupRequest) -> async StartMatchGroupResult;
    };

    public type StartMatchGroupRequest = {
        id : Nat;
        matches : [StartMatchRequest];
    };

    public type StartMatchRequest = {
        #start : {
            team1 : TeamStartData;
            team2 : TeamStartData;
            aura : MatchAura.MatchAura;
        };
        #allAbsent;
        #absentTeam : Team.TeamId;
    };

    public type TeamStartData = {
        id : Principal;
        name : Text;
        logoUrl : Text;
        offering : Offering.Offering;
        championId : PlayerId;
        players : [Player.PlayerWithId];
    };

    public type StartMatchGroupError = {
        #noMatchesSpecified;
    };

    public type StartMatchGroupResult = StartMatchGroupError or {
        #ok;
    };

    public type MatchVariant = {
        #inProgress : InProgressMatch;
        #completed : CompletedMatch;
    };

    public type InProgressMatch = {
        team1 : Team;
        team2 : Team;
        offenseTeamId : Team.TeamId;
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

    public type CompletedMatch = {
        #absentTeam : Team.TeamId;
        #allAbsent;
        #played : PlayedMatch;
        #stateBroken : BrokenState;
    };

    public type PlayedMatch = {
        team1 : Team;
        team2 : Team;
        winner : Team.TeamIdOrTie;
        log : [LogEntry];
    };

    public type MatchGroup = {
        matches : [MatchVariant];
        tickTimerId : Nat;
        currentSeed : Nat32;
    };

    public type MatchGroupWithId = MatchGroup and {
        id : Nat;
    };

    public type ResetTickTimerResult = {
        #ok;
        #matchGroupNotFound;
    };

    public type PlayerState = {
        name : Text;
        teamId : Team.TeamId;
        condition : Player.PlayerCondition;
        skills : Player.PlayerSkills;
        position : FieldPosition;
    };

    public type PlayerStateWithId = PlayerState and {
        id : PlayerId;
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

    public type Player = {
        id : PlayerId;
        name : Text;
    };

    public type Team = {
        id : Principal;
        name : Text;
        logoUrl : Text;
        score : Int;
        offering : Offering.Offering;
        championId : PlayerId;
    };

};
