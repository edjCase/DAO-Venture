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
        createDivision(request : CreateDivisionRequest) : async CreateDivisionResult;
        scheduleSeason(request : ScheduleSeasonRequest) : async ScheduleSeasonResult;
        createStadium() : async CreateStadiumResult;
        updateLeagueCanisters() : async ();
    };

    public type Stadium = {
        id : Principal;
    };

    public type ScheduleSeasonRequest = {
        divisions : [DivisionScheduleRequest];
    };

    public type DivisionScheduleRequest = {
        id : Principal;
        startTime : Time.Time;
    };
    public type ScheduleSeasonResult = {
        #ok;
        #divisionErrors : [{
            divisionId : Principal;
            error : Division.ScheduleError;
        }];
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
