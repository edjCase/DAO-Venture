import Time "mo:base/Time";
import Anomoly "Anomoly";
import Team "Team";
import FieldPosition "FieldPosition";
import Player "Player";

module {

    public type SeasonStatus = {
        #notStarted;
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
    };

    public type InProgressMatchGroup = {
        time : Time.Time;
        matches : [InProgressMatch];
    };

    public type InProgressTeam = {
        id : Nat;
        positions : FieldPosition.TeamPositions;
        anomolies : [Anomoly.Anomoly];
    };

    public type InProgressMatch = {
        team1 : InProgressTeam;
        team2 : InProgressTeam;
    };

    public type CompletedMatchTeam = {
        id : Nat;
        score : Int;
        positions : FieldPosition.TeamPositions;
        anomolies : [Anomoly.Anomoly];
        playerStats : [Player.PlayerMatchStats];
    };

    public type CompletedMatch = {
        team1 : CompletedMatchTeam;
        team2 : CompletedMatchTeam;
        winner : Team.TeamIdOrTie;
    };

    public type CompletedMatchGroup = {
        time : Time.Time;
        matches : [CompletedMatch];
    };

    // Completed Season
    public type CompletedSeason = {
        teams : [CompletedSeasonTeam];
        completedMatchGroups : [CompletedMatchGroup];
        outcome : CompletedSeasonOutcome;
    };

    public type CompletedSeasonOutcome = {
        #success : CompletedSeasonOutcomeSuccess;
        #failure : CompletedSeasonOutcomeFailure;
    };

    public type CompletedSeasonOutcomeSuccess = {
        championTeamId : Nat;
        runnerUpTeamId : Nat;
    };

    public type CompletedSeasonOutcomeFailure = {
        incompleteMatchGroups : [NotScheduledMatchGroup];
    };

    public type CompletedSeasonTeam = {
        id : Nat;
        wins : Nat;
        losses : Nat;
        totalScore : Int;
    };
};
