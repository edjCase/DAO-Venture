import Stadium "Stadium";
import TimeZone "mo:datetime/TimeZone";
import Principal "mo:base/Principal";
import Time "mo:base/Time";

module {

    public type CreateTeamResult = {
        #ok : Principal;
        #nameTaken;
        #divisionNotFound;
    };
    public type CreateStadiumResult = {
        #ok : Principal;
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
        timeZone : TimeZone.FixedTimeZone;
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
