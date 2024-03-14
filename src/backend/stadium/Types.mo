import Principal "mo:base/Principal";
import Player "../models/Player";
import Nat "mo:base/Nat";
import MatchAura "../models/MatchAura";
import Base "../models/Base";
import Team "../models/Team";
import FieldPosition "../models/FieldPosition";
import Trait "../models/Trait";

module {
    type FieldPosition = FieldPosition.FieldPosition;
    type Base = Base.Base;
    type PlayerId = Player.PlayerId;

    public type StadiumActor = actor {
        setLeague : (id : Principal) -> async SetLeagueResult;
        getMatchGroup : query (id : Nat) -> async ?MatchGroupWithId;
        tickMatchGroup : (id : Nat) -> async TickMatchGroupResult;
        resetTickTimer : (matchGroupId : Nat) -> async ResetTickTimerResult;
        startMatchGroup : (request : StartMatchGroupRequest) -> async StartMatchGroupResult;
        cancelMatchGroup : (request : CancelMatchGroupRequest) -> async CancelMatchGroupResult;
    };

    public type CancelMatchGroupRequest = {
        id : Nat;
    };
    public type CancelMatchGroupResult = {
        #ok;
        #matchGroupNotFound;
    };

    public type SetLeagueResult = {
        #ok;
        #notAuthorized;
    };

    public type StadiumActorInfo = {};

    public type StadiumActorInfoWithId = StadiumActorInfo and {
        id : Principal;
    };

    public type CreateStadiumResult = {
        #ok : Principal;
        #stadiumCreationError : Text;
    };

    public type StartMatchGroupRequest = {
        id : Nat;
        matches : [StartMatchRequest];
    };

    public type Team = {
        id : Principal;
        name : Text;
        logoUrl : Text;
    };

    public type StartMatchTeam = Team and {
        positions : {
            firstBase : Player.PlayerWithId;
            secondBase : Player.PlayerWithId;
            thirdBase : Player.PlayerWithId;
            shortStop : Player.PlayerWithId;
            pitcher : Player.PlayerWithId;
            leftField : Player.PlayerWithId;
            centerField : Player.PlayerWithId;
            rightField : Player.PlayerWithId;
        };
    };

    public type StartMatchRequest = {
        team1 : StartMatchTeam;
        team2 : StartMatchTeam;
        aura : MatchAura.MatchAura;
    };

    public type StartMatchGroupError = {
        #noMatchesSpecified;
    };

    public type StartMatchError = {
        #notEnoughPlayers : Team.TeamIdOrBoth;
    };

    public type StartMatchGroupResult = StartMatchGroupError or {
        #ok;
    };

    public type RoundLog = {
        turns : [TurnLog];
    };

    public type TurnLog = {
        events : [Event];
    };

    public type HitLocation = FieldPosition.FieldPosition or {
        #stands;
    };

    public type Event = {
        #traitTrigger : {
            id : Trait.Trait;
            playerId : Player.PlayerId;
            description : Text;
        };
        #auraTrigger : {
            id : MatchAura.MatchAura;
            description : Text;
        };
        #pitch : {
            pitcherId : Player.PlayerId;
            roll : {
                value : Int;
                crit : Bool;
            };
        };
        #swing : {
            playerId : Player.PlayerId;
            roll : {
                value : Int;
                crit : Bool;
            };
            pitchRoll : {
                value : Int;
                crit : Bool;
            };
            outcome : {
                #foul;
                #strike;
                #hit : HitLocation;
            };
        };
        #catch_ : {
            playerId : Player.PlayerId;
            roll : {
                value : Int;
                crit : Bool;
            };
            difficulty : {
                value : Int;
                crit : Bool;
            };
        };
        #teamSwap : {
            offenseTeamId : Team.TeamId;
            atBatPlayerId : Player.PlayerId;
        };
        #injury : {
            playerId : Nat32;
            injury : Player.Injury;
        };
        #death : {
            playerId : Nat32;
        };
        #score : {
            teamId : Team.TeamId;
            amount : Int;
        };
        #newBatter : {
            playerId : Player.PlayerId;
        };
        #out : {
            playerId : Player.PlayerId;
            reason : OutReason;
        };
        #matchEnd : {
            reason : MatchEndReason;
        };
        #safeAtBase : {
            playerId : Player.PlayerId;
            base : Base.Base;
        };
        #throw_ : {
            from : Player.PlayerId;
            to : Player.PlayerId;
        };
        #hitByBall : {
            playerId : Player.PlayerId;
        };
    };

    public type MatchEndReason = {
        #noMoreRounds;
        #error : Text;
    };

    public type OutReason = {
        #ballCaught;
        #strikeout;
        #hitByBall;
    };

    public type MatchLog = {
        rounds : [RoundLog];
    };

    public type Match = {
        team1 : TeamState;
        team2 : TeamState;
        offenseTeamId : Team.TeamId;
        aura : MatchAura.MatchAura;
        players : [PlayerStateWithId];
        bases : BaseState;
        log : MatchLog;
        outs : Nat;
        strikes : Nat;
    };

    public type PlayerExpectedOnFieldError = {
        id : PlayerId;
        onOffense : Bool;
        description : Text;
    };

    public type BrokenStateError = {
        #playerNotFound : PlayerId;
        #playerExpectedOnField : PlayerExpectedOnFieldError;
    };

    public type TickResult = {
        match : Match;
        status : MatchStatus;
    };

    public type MatchStatus = {
        #inProgress;
        #completed : MatchStatusCompleted;
    };

    public type MatchStatusCompleted = {
        reason : MatchEndReason;
    };

    public type MatchGroup = {
        matches : [TickResult];
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
        skills : Player.Skills;
        matchStats : Player.PlayerMatchStats;
    };

    public type PlayerStateWithId = PlayerState and {
        id : PlayerId;
    };

    public type BaseState = {
        atBat : PlayerId;
        firstBase : ?PlayerId;
        secondBase : ?PlayerId;
        thirdBase : ?PlayerId;
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

    public type TeamState = Team and {
        score : Int;
        positions : FieldPosition.TeamPositions;
    };

};
