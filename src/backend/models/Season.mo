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

    public type NotScheduledMatch = {
        team1 : TeamInfo;
        team2 : TeamInfo;
    };

    public type ScheduledMatchGroup = {
        time : Time.Time;
        timerId : Nat;
        matches : [ScheduledMatch];
    };

    public type ScheduledMatch = {
        team1 : TeamInfo;
        team2 : TeamInfo;
        offerings : [Offering.Offering];
        aura : MatchAura.MatchAura;
    };

    public type InProgressMatchGroup = {
        time : Time.Time;
        stadiumId : Principal;
        matches : [InProgressMatch];
    };

    public type InProgressMatch = {
        team1 : TeamInfo;
        team2 : TeamInfo;
        aura : MatchAura.MatchAura;
        result : {
            #started : {
                team1Offering : Offering.Offering;
                team1ChampionId : Nat32;
                team2Offering : Offering.Offering;
                team2ChampionId : Nat32;
            };
            #absentTeam : Team.TeamId;
            #allAbsent;
        };
    };

    public type CompletedMatch = {
        team1 : TeamInfo;
        team2 : TeamInfo;
        result : CompletedMatchResult;
    };

    public type CompletedMatchResult = {
        #played : {
            team1Score : Int;
            team2Score : Int;
            winner : Team.TeamIdOrTie;
            log : [LogEntry];
        };
        #absentTeam : Team.TeamId;
        #allAbsent;
        #failed : {
            message : Text;
            log : [LogEntry];
        };
    };

    public type LogEntry = {
        message : Text;
        isImportant : Bool;
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
    };

    public type StartMatchGroupError = StadiumTypes.StartMatchGroupError or {
        #stadiumStartCallError : Text;
    };
};
