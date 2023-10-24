import Stadium "Stadium";
import TimeZone "mo:datetime/TimeZone";
import Principal "mo:base/Principal";
import Time "mo:base/Time";

module {
    public type CreateDivisionRequest = {
        name : Text;
        dayOfWeek : DayOfWeek;
        timeZoneOffsetSeconds : Nat;
        timeOfDay : TimeOfDay;
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
    public type DivisionInfo = {
        id : Nat32;
        name : Text;
        dayOfWeek : DayOfWeek;
        timeZoneOffsetSeconds : Nat;
        timeOfDay : TimeOfDay;
        schedule : ?[Week];
    };
    public type CreateTeamDaoResult = {
        #ok : Principal;
        #notAuthenticated;
        #error : Text;
    };
    public type DayOfWeek = {
        #sunday;
        #monday;
        #tuesday;
        #wednesday;
        #thursday;
        #friday;
        #saturday;
    };
    public type Division = {
        name : Text;
        dayOfWeek : DayOfWeek;
        timeZoneOffsetSeconds : Nat;
        timeOfDay : TimeOfDay;
        schedule : ?[Week];
    };
    public type Week = {
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
