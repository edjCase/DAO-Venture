import Team "Team";
import Anomoly "Anomoly";
import FieldPosition "FieldPosition";
import Player "Player";
import Trait "Trait";
import Base "Base";
module {

    public type LiveMatchGroupState = {
        id : Nat;
        matches : [LiveMatchStateWithStatus];
        tickTimerId : Nat;
        currentSeed : Nat32;
    };

    public type LiveMatchState = {
        team1 : LiveMatchTeam;
        team2 : LiveMatchTeam;
        offenseTeamId : Team.TeamId;
        anomoly : Anomoly.Anomoly;
        players : [LivePlayerState];
        bases : LiveBaseState;
        log : MatchLog;
        outs : Nat;
        strikes : Nat;
    };

    public type LiveMatchStateWithStatus = LiveMatchState and {
        status : LiveMatchStatus;
    };

    public type LiveMatchStatus = {
        #inProgress;
        #completed : LiveMatchStatusCompleted;
    };

    public type LiveMatchStatusCompleted = {
        reason : MatchEndReason;
    };

    public type LiveMatchTeam = {
        id : Nat;
        name : Text;
        logoUrl : Text;
        color : (Nat8, Nat8, Nat8);
        score : Int;
        positions : FieldPosition.TeamPositions;
    };

    public type MatchLog = {
        rounds : [RoundLog];
    };

    public type RoundLog = {
        turns : [TurnLog];
    };

    public type TurnLog = {
        events : [MatchEvent];
    };

    public type LivePlayerState = {
        id : Player.PlayerId;
        name : Text;
        teamId : Team.TeamId;
        condition : Player.PlayerCondition;
        skills : Player.Skills;
        matchStats : Player.PlayerMatchStats;
    };
    public type LiveBaseState = {
        atBat : Player.PlayerId;
        firstBase : ?Player.PlayerId;
        secondBase : ?Player.PlayerId;
        thirdBase : ?Player.PlayerId;
    };

    public type MatchEvent = {
        #traitTrigger : {
            id : Trait.Trait;
            playerId : Player.PlayerId;
            description : Text;
        };
        #anomolyTrigger : {
            id : Anomoly.Anomoly;
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

    public type HitLocation = FieldPosition.FieldPosition or {
        #stands;
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
};
