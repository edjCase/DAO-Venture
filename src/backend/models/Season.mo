import Time "mo:base/Time";
import Array "mo:base/Array";
import Principal "mo:base/Principal";
import Trie "mo:base/Trie";
import MatchAura "MatchAura";
import Team "Team";
import Trait "Trait";
import Player "Player";
import Curse "Curse";
import Blessing "Blessing";
import Base "Base";
import FieldPosition "FieldPosition";
import Scenario "Scenario";

module {

    public type SeasonStatus = {
        #notStarted;
        #starting;
        #inProgress : InProgressSeason;
        #completed : CompletedSeason;
    };

    public type InProgressSeason = {
        matchGroups : [InProgressSeasonMatchGroupVariant];
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

    public type ScheduledTeamInfo = TeamInfo and {
        scenario : Scenario.Instance;
    };

    public type ScheduledMatch = {
        team1 : ScheduledTeamInfo;
        team2 : ScheduledTeamInfo;
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
        scenario : Scenario.InstanceWithChoice;
        positions : TeamPositions;
    };

    public type InProgressMatch = {
        team1 : InProgressTeam;
        team2 : InProgressTeam;
        aura : MatchAura.MatchAura;
    };

    public type CompletedMatchTeam = TeamInfo and {
        scenario : Scenario.InstanceWithChoice;
        score : Int;
        positions : TeamPositions;
    };

    public type CompletedMatch = {
        team1 : CompletedMatchTeam;
        team2 : CompletedMatchTeam;
        aura : MatchAura.MatchAura;
        winner : Team.TeamIdOrTie;
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
