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
        teams : [TeamInfo];
        players : [Player.PlayerWithId];
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
        scenarioId : Text;
    };

    public type TeamAssignment = {
        #predetermined : Principal;
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
        stadiumId : Principal;
        matches : [ScheduledMatch];
        scenarioId : Text;
    };

    public type ScheduledTeamInfo = { id : Principal };

    public type ScheduledMatch = {
        team1 : ScheduledTeamInfo;
        team2 : ScheduledTeamInfo;
        aura : MatchAura.MatchAuraWithMetaData;
    };

    public type InProgressMatchGroup = {
        time : Time.Time;
        stadiumId : Principal;
        matches : [InProgressMatch];
        scenarioId : Text;
    };

    public type InProgressTeam = {
        id : Principal;
        positions : FieldPosition.TeamPositions;
    };

    public type InProgressMatch = {
        team1 : InProgressTeam;
        team2 : InProgressTeam;
        aura : MatchAura.MatchAura;
    };

    public type CompletedMatchTeam = {
        id : Principal;
        score : Int;
        positions : FieldPosition.TeamPositions;
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
        scenarioId : Text;
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
