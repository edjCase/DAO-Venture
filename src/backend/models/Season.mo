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
import FieldPosition "FieldPosition";

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
        #seasonStandingIndex : Nat; // Current standing calculation
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
        predictions : [(Principal, Team.TeamId)];
    };

    public type CompletedMatchTeam = TeamInfo and {
        offering : Offering.Offering;
        score : Int;
        positions : TeamPositions;
    };

    public type PlayerMatchStats = {
        battingStats : {
            atBats : Nat;
            hits : Nat;
            strikeouts : Nat;
            runs : Nat;
            homeRuns : Nat;
        };
        catchingStats : {
            successfulCatches : Nat;
            missedCatches : Nat;
            throws : Nat;
            throwOuts : Nat;
        };
        pitchingStats : {
            pitches : Nat;
            strikes : Nat;
            hits : Nat;
            strikeouts : Nat;
            runs : Nat;
            homeRuns : Nat;
        };
        injuries : Nat;
    };
    public type PlayerMatchStatsWithId = PlayerMatchStats and {
        playerId : Player.PlayerId;
    };

    public type CompletedMatchWithoutPredictions = {
        team1 : CompletedMatchTeam;
        team2 : CompletedMatchTeam;
        aura : MatchAura.MatchAura;
        winner : Team.TeamIdOrTie;
        playerStats : [PlayerMatchStatsWithId];
    };

    public type CompletedMatch = CompletedMatchWithoutPredictions and {
        predictions : [(Principal, Team.TeamId)];
    };

    public type CompletedMatchGroup = {
        time : Time.Time;
        matches : [CompletedMatch];
    };

    // Completed Season
    public type CompletedSeason = {
        championTeamId : Principal;
        runnerUpTeamId : Principal;
        teams : [CompletedSeasonTeam];
        matchGroups : [CompletedMatchGroup];
    };

    public type CompletedSeasonTeam = TeamInfo and {
        wins : Nat;
        losses : Nat;
        totalScore : Int;
    };
};
