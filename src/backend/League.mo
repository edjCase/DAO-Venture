import Stadium "Stadium";
import TimeZone "mo:datetime/TimeZone";
import Principal "mo:base/Principal";
import Time "mo:base/Time";

module {
    public type ScheduleSeasonRequest = {
        divisions : [DivisionScheduleRequest];
    };
    public type DivisionScheduleRequest = {
        id : Nat32;
        start : Time.Time;
    };
    public type ScheduleSeasonResult = {
        #ok;
        #divisionErrors : [(Nat32, DivisionScheduleError)];
    };
    public type DivisionScheduleError = {
        #missingDivision;
        #oddNumberOfTeams;
        #notEnoughStadiums;
        #divisionNotFound;
        #alreadyScheduled;
        #noTeamsInDivision;
    };
    public type CreateDivisionRequest = {
        name : Text;
    };
    public type CreateDivisionResult = {
        #ok : Nat32;
        #nameTaken;
    };
    public type CreateTeamRequest = {
        name : Text;
        logoUrl : Text;
        tokenName : Text;
        tokenSymbol : Text;
        divisionId : Nat32;
    };
    public type CreateTeamResult = {
        #ok : Principal;
        #nameTaken;
        #divisionNotFound;
    };
    public type CreateStadiumRequest = {
        name : Text;
    };
    public type CreateStadiumResult = {
        #ok : Principal;
        #nameTaken;
    };
    public type ScheduleMatchResult = Stadium.ScheduleMatchResult or {
        #stadiumNotFound;
    };
    public type TeamInfo = {
        id : Principal;
        name : Text;
        logoUrl : Text;
        ledgerId : Principal; // TODO this is duplicated in TeamActor
        divisionId : Nat32;
    };
    public type StadiumInfo = {
        id : Principal;
        name : Text;
    };
    public type CreateTeamDaoResult = {
        #ok : Principal;
        #notAuthenticated;
        #error : Text;
    };
    public type Division = {
        name : Text;
        schedule : ?DivisionSchedule;
    };
    public type DivisionWithId = Division and {
        id : Nat32;
    };
    public type DivisionSchedule = {
        weeks : [SeasonWeek];
    };
    public type SeasonWeek = {
        matchUps : [MatchUp];
    };
    public type MatchUpStatus = {
        #scheduled : Nat32;
        #failedToSchedule : {
            #duplicateTeams;
            #timeNotAvailable;
            #unknown : Text;
        };
    };
    public type MatchUp = {
        status : MatchUpStatus;
        stadiumId : Principal;
        team1 : Principal;
        team2 : Principal;
    };
    public type TimeOfDay = {
        hour : Nat;
        minute : Nat;
    };
};
