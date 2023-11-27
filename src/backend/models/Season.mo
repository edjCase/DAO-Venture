import Time "mo:base/Time";
import Array "mo:base/Array";
import Offering "Offering";
import MatchAura "MatchAura";
import Team "Team";
import StadiumTypes "../stadium/Types";

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
        #failedToSchedule : FailedToScheduleMatchGroup;
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

    public type FailedToScheduleMatchGroup = {
        time : Time.Time;
        matches : [NotScheduledMatch];
        error : ScheduleMatchGroupError;
    };

    public type NotScheduledMatch = {
        team1 : TeamInfo;
        team2 : TeamInfo;
    };

    public type ScheduledMatchGroup = {
        time : Time.Time;
        matches : [ScheduledMatch];
    };

    public type ScheduledMatch = {
        team1 : TeamInfo;
        team2 : TeamInfo;
        offerings : [Offering.Offering];
        matchAura : MatchAura.MatchAura;
    };

    public type InProgressMatchGroup = {
        time : Time.Time;
        stadiumId : Principal;
        matches : [InProgressMatchGroupMatchVariant];
    };

    public type InProgressMatchGroupMatchVariant = {
        #inProgress : InProgressMatch;
        #absentTeam : AbsentTeamMatch;
        #allAbsent : AllAbsentMatch;
        #completed : CompletedMatch;
    };

    public type InProgressMatch = {
        team1 : TeamInfo;
        team2 : TeamInfo;
    };

    public type AbsentTeamMatch = {
        team1 : TeamInfo;
        team2 : TeamInfo;
        absentTeam : Team.TeamId;
    };

    public type AllAbsentMatch = {
        team1 : TeamInfo;
        team2 : TeamInfo;
    };

    public type CompletedMatch = {
        team1 : TeamInfo and {
            score : Nat;
        };
        team2 : TeamInfo and {
            score : Nat;
        };
        winner : Team.TeamId;
    };

    public type CompletedMatchGroup = {
        time : Time.Time;
        matches : [CompletedMatchGroupMatchVariant];
    };

    public type CompletedMatchGroupMatchVariant = {
        #completed : CompletedMatch;
        #absentTeam : AbsentTeamMatch;
        #allAbsent : AllAbsentMatch;
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
    };

    public type ScheduleMatchGroupError = StadiumTypes.ScheduleMatchGroupError or {
        #stadiumScheduleCallError : Text;
    };
};
