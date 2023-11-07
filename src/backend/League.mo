import Stadium "Stadium";
import TimeZone "mo:datetime/TimeZone";
import Principal "mo:base/Principal";
import Time "mo:base/Time";
import Team "Team";
import Division "Division";

module {
    public type LeagueActor = actor {
        getTeams() : async [Team.TeamWithId];
        getStadiums() : async [Stadium];
        getDivisions() : async [DivisionWithId];
        getSeasonSchedule : composite query () -> async ?Stadium.SeasonSchedule;
        createDivision(request : CreateDivisionRequest) : async CreateDivisionResult;
        scheduleSeason(request : ScheduleSeasonRequest) : async ScheduleSeasonResult;
        createStadium() : async CreateStadiumResult;
        updateLeagueCanisters() : async ();
    };

    public type Stadium = {
        id : Principal;
    };

    public type ScheduleSeasonRequest = {
        divisions : [ScheduleDivisionRequest];
    };

    public type ScheduleDivisionRequest = {
        id : Principal;
        startTime : Time.Time;
    };
    public type ScheduleSeasonResult = Stadium.ScheduleSeasonResultGeneric<ScheduleDivisionErrorResult> or {
        #noStadium;
        #stadiumScheduleError : Text;
        #teamFetchError : Text;
    };
    public type ScheduleDivisionError = Stadium.ScheduleDivisionError or {
        #oddNumberOfTeams;
        #noTeamsInDivision;
    };
    public type ScheduleDivisionErrorResult = {
        id : Principal;
        error : ScheduleDivisionError;
    };
    public type CreateDivisionRequest = {
        name : Text;
    };
    public type CreateDivisionResult = {
        #ok : Principal;
        #nameTaken;
        #noStadium;
    };
    public type CreateStadiumResult = {
        #ok : Principal;
        #alreadyCreated;
        #stadiumCreationError : Text;
    };
    public type CreateTeamDaoResult = {
        #ok : Principal;
        #notAuthenticated;
        #error : Text;
    };
    public type Division = {
        name : Text;
    };
    public type DivisionWithId = Division and {
        id : Principal;
    };
};
