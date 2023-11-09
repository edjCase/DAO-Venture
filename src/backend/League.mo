import Stadium "Stadium";
import TimeZone "mo:datetime/TimeZone";
import Principal "mo:base/Principal";
import Time "mo:base/Time";
import Team "Team";
import ICRC1 "mo:icrc1/ICRC1";

module {
    public type LeagueActor = actor {
        getTeams : query () -> async [Team.TeamWithId];
        getStadiums : query () -> async [Stadium];
        getDivisions : query () -> async [DivisionWithId];
        getSeasonSchedule : composite query () -> async ?Stadium.SeasonSchedule;
        createDivision : (request : CreateDivisionRequest) -> async CreateDivisionResult;
        scheduleSeason : (request : ScheduleSeasonRequest) -> async ScheduleSeasonResult;
        createStadium : () -> async CreateStadiumResult;
        createTeam : (request : CreateTeamRequest) -> async CreateTeamResult;
        mint : (request : MintRequest) -> async MintResult;
        updateLeagueCanisters : () -> async ();
    };
    public type CreateTeamRequest = {
        name : Text;
        logoUrl : Text;
        tokenName : Text;
        tokenSymbol : Text;
        divisionId : Nat32;
    };
    public type MintRequest = {
        amount : Nat;
        teamId : Principal;
    };

    public type MintResult = {
        #ok : ICRC1.TxIndex;
        #teamNotFound;
        #transferError : ICRC1.TransferError;
    };

    public type CreateTeamResult = {
        #ok : Principal;
        #nameTaken;
        #noStadiumsExist;
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
        #noStadiumsExist;
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
        #ok : Nat32;
        #nameTaken;
        #noStadiumsExist;
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
        id : Nat32;
    };
};
