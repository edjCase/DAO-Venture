import Time "mo:base/Time";
import Anomoly "Anomoly";
import Team "Team";
import Player "Player";
import FieldPosition "FieldPosition";

module {

    public type SeasonStatus = {
        #notStarted;
        #starting;
        #inProgress : InProgressSeason;
        #completed : CompletedSeason;
    };

    public type InProgressSeason = {
        teams : [TeamInfo];
        players : [Player.Player];
        matchGroups : [InProgressSeasonMatchGroupVariant];
    };

    public type InProgressSeasonMatchGroupVariant = {
        #notScheduled : NotScheduledMatchGroup;
        #scheduled : ScheduledMatchGroup;
        #inProgress : InProgressMatchGroup;
        #completed : CompletedMatchGroup;
    };

    public type TeamInfo = {
        id : Nat;
        name : Text;
        logoUrl : Text;
        positions : FieldPosition.TeamPositions;
        color : (Nat8, Nat8, Nat8);
    };

    public type NotScheduledMatchGroup = {
        time : Time.Time;
        matches : [NotScheduledMatch];
    };

    public type TeamAssignment = {
        #predetermined : Nat;
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

    public type ScheduledTeamInfo = { id : Nat };

    public type ScheduledMatch = {
        team1 : ScheduledTeamInfo;
        team2 : ScheduledTeamInfo;
        anomoly : Anomoly.AnomolyWithMetaData;
    };

    public type InProgressMatchGroup = {
        time : Time.Time;
        matches : [InProgressMatch];
    };

    public type InProgressTeam = {
        id : Nat;
    };

    public type InProgressMatch = {
        team1 : InProgressTeam;
        team2 : InProgressTeam;
        anomoly : Anomoly.Anomoly;
    };

    public type CompletedMatchTeam = {
        id : Nat;
        score : Int;
    };

    public type CompletedMatch = {
        team1 : CompletedMatchTeam;
        team2 : CompletedMatchTeam;
        anomoly : Anomoly.Anomoly;
        winner : Team.TeamIdOrTie;
    };

    public type CompletedMatchGroup = {
        time : Time.Time;
        matches : [CompletedMatch];
    };

    // Completed Season
    public type CompletedSeason = {
        championTeamId : Nat;
        runnerUpTeamId : Nat;
        teams : [CompletedSeasonTeam];
        matchGroups : [CompletedMatchGroup];
    };

    public type CompletedSeasonTeam = TeamInfo and {
        wins : Nat;
        losses : Nat;
        totalScore : Int;
    };
};
