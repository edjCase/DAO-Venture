import Stadium "Stadium";
import TimeZone "mo:datetime/TimeZone";
import Principal "mo:base/Principal";
import Time "mo:base/Time";
import Nat "mo:base/Nat";
import Team "Team";
import ICRC1 "mo:icrc1/ICRC1";

module {
    public type LeagueActor = actor {
        getTeams : query () -> async [Team.TeamWithId];
        getStadiums : query () -> async [Stadium];
        getDivisions : query () -> async [DivisionWithId];
        getSeasonSchedule : composite query () -> async ?SeasonSchedule;
        createDivision : (request : CreateDivisionRequest) -> async CreateDivisionResult;
        startSeason : (request : StartSeasonRequest) -> async StartSeasonResult;
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
        #divisionNotFound;
    };

    public type Stadium = {
        id : Principal;
    };

    public type SeasonSchedule = {
        divisions : [DivisionScheduleWithId];
        matchGroups : [MatchGroupScheduleWithId];
    };

    public type DivisionSchedule = {
        matchGroupIds : [Nat32];
    };

    public type DivisionScheduleWithId = DivisionSchedule and {
        id : Nat32;
    };

    public type MatchGroupSchedule = {
        id : Nat32;
        time : Time.Time;
        matches : [MatchSchedule];
        status : MatchGroupScheduleStatus;
    };
    public type MatchGroupScheduleWithId = MatchGroupSchedule and {
        id : Nat32;
    };

    public type MatchGroupScheduleStatus = {
        #notOpen;
        #open : OpenMatchGroupScheduleStatus;
        #completed : Stadium.CompletedMatchGroupState;
    };

    public type OpenMatchGroupScheduleStatus = {
        matches : [OpenMatchScheduleStatus];
    };

    public type OpenMatchScheduleStatus = {
        offerings : [Stadium.Offering];
        matchAura : Stadium.MatchAura;
    };

    public type MatchSchedule = {
        team1Id : Principal;
        team2Id : Principal;
    };

    public type StartDivisionSeasonRequest = {
        id : Nat32;
        startTime : Time.Time;
    };

    public type StartSeasonRequest = {
        divisions : [StartDivisionSeasonRequest];
    };

    public type StartDivisionSeasionErrorResult = {
        id : Nat32;
        error : StartDivisionSeasonError;
    };

    public type StartSeasonResult = {
        #ok;
        #divisionErrors : [StartDivisionSeasonErrorResult];
        #noDivisionSpecified;
        #alreadyStarted;
        #noStadiumsExist;
        #stadiumScheduleError : Stadium.ScheduleMatchGroupsError or {
            #unknown : Text;
        };
    };

    public type StartDivisionSeasonError = {
        #divisionNotFound;
        #noMatchGroupSpecified;
        #oddNumberOfTeams;
        #noTeamsInDivision;
    };
    public type StartDivisionSeasonErrorResult = {
        id : Nat32;
        error : StartDivisionSeasonError;
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
