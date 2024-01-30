import Time "mo:base/Time";
import Array "mo:base/Array";
import Principal "mo:base/Principal";
import Trie "mo:base/Trie";
import Offering "Offering";
import MatchAura "MatchAura";
import Team "Team";
import Trait "Trait";
import Player "Player";
import Curse "Curse";
import Blessing "Blessing";
import Base "Base";

module {

    public type SeasonStatus = {
        #notStarted;
        #starting;
        #inProgress : InProgressSeason;
        #completed : CompletedSeason;
    };

    public type TeamStandingInfo = {
        id : Principal;
        wins : Nat;
        losses : Nat;
        totalScore : Int;
    };

    public type InProgressSeason = {
        matchGroups : [InProgressSeasonMatchGroupVariant];
        teamStandings : ?[TeamStandingInfo]; // First team to last team
    };

    public type InProgressSeasonMatchGroupVariant = {
        #notScheduled : NotScheduledMatchGroup;
        #scheduled : ScheduledMatchGroup;
        #inProgress : InProgressMatchGroup;
        #completed : CompletedMatchGroup;
    };

    public type TeamInfo = {
        id : Principal;
        name : Text;
        logoUrl : Text;
    };

    public type NotScheduledMatchGroup = {
        time : Time.Time;
        matches : [NotScheduledMatch];
    };

    public type TeamAssignment = {
        #predetermined : TeamInfo;
        #seasonStanding : Nat; // Current standing calculation
        #winnerOfMatch : Nat; // Look at previous match group match id winner
    };

    public type NotScheduledMatch = {
        team1 : TeamAssignment;
        team2 : TeamAssignment;
    };

    public type ScheduledMatchGroup = {
        time : Time.Time;
        timerId : Nat;
        matches : [ScheduledMatch];
    };

    public type ScheduledTeamInfo = TeamInfo and {};

    public type ScheduledMatch = {
        team1 : ScheduledTeamInfo;
        team2 : ScheduledTeamInfo;
        offeringOptions : [Offering.OfferingWithMetaData];
        aura : MatchAura.MatchAuraWithMetaData;
    };

    public type InProgressMatchGroup = {
        time : Time.Time;
        stadiumId : Principal;
        matches : [InProgressMatch];
    };

    public type TeamPositions = {
        firstBase : Player.PlayerId;
        secondBase : Player.PlayerId;
        thirdBase : Player.PlayerId;
        shortStop : Player.PlayerId;
        pitcher : Player.PlayerId;
        leftField : Player.PlayerId;
        centerField : Player.PlayerId;
        rightField : Player.PlayerId;
    };

    public type InProgressTeam = TeamInfo and {
        offering : Offering.Offering;
        positions : TeamPositions;
    };

    public type InProgressMatch = {
        team1 : InProgressTeam;
        team2 : InProgressTeam;
        aura : MatchAura.MatchAura;
        predictions : Trie.Trie<Principal, Team.TeamId>;
    };

    public type CompletedMatchTeam = TeamInfo and {
        offering : Offering.Offering;
        score : Int;
        positions : TeamPositions;
    };

    public type PlayerMatchStats = {
        playerId : Player.PlayerId;
        offenseStats : {
            atBats : Nat;
            hits : Nat;
            runs : Nat;
            runsBattedIn : Nat;
            strikeouts : Nat;
        };
        defenseStats : {
            catches : Nat;
            missedCatches : Nat;
            outs : Nat;
            assists : Nat;
        };
    };

    public type MatchLog = {
        rounds : [RoundLog];
    };

    public type CompletedMatchWithoutPredictions = {
        team1 : CompletedMatchTeam;
        team2 : CompletedMatchTeam;
        aura : MatchAura.MatchAura;
        log : MatchLog;
        winner : Team.TeamIdOrTie;
        playerStats : [PlayerMatchStats];
    };

    public type CompletedMatch = CompletedMatchWithoutPredictions and {
        predictions : Trie.Trie<Principal, Team.TeamId>;
    };

    public type RoundLog = {
        turns : [TurnLog];
    };

    public type TurnLog = {
        events : [Event];
    };

    public type Event = {
        #traitTrigger : {
            id : Trait.Trait;
            playerId : Player.PlayerId;
            description : Text;
        };
        #offeringTrigger : {
            id : Offering.Offering;
            teamId : Team.TeamId;
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
                #hit;
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
        #newRound : {
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
        #curse : {
            playerId : Nat32;
            curse : Curse.Curse;
        };
        #blessing : {
            playerId : Nat32;
            blessing : Blessing.Blessing;
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
        #hitByBall : {
            playerId : Player.PlayerId;
            throwingPlayerId : Player.PlayerId;
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

    public type CompletedMatchGroup = {
        time : Time.Time;
        matches : [CompletedMatch];
    };

    // Completed Season
    public type CompletedSeason = {
        teams : [CompletedSeasonTeam];
        matchGroups : [CompletedMatchGroup];
    };

    public type CompletedSeasonTeam = TeamInfo and {
        standing : Nat;
        wins : Nat;
        losses : Nat;
        totalScore : Int;
    };
};
