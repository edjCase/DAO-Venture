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
        getSeasonSchedule : composite query () -> async ?SeasonSchedule;
        startSeason : (request : StartSeasonRequest) -> async StartSeasonResult;
        createStadium : () -> async CreateStadiumResult;
        createTeam : (request : CreateTeamRequest) -> async CreateTeamResult;
        mint : (request : MintRequest) -> async MintResult;
        updateLeagueCanisters : () -> async ();
        onMatchGroupComplete : (request : OnMatchGroupCompleteRequest) -> async OnMatchGroupCompleteResult;
    };

    public type OnMatchGroupCompleteRequest = {
        id : Nat32;
        state : Stadium.CompletedMatchGroupState;
    };

    public type OnMatchGroupCompleteResult = {
        #ok;
        #seasonNotOpen;
        #matchGroupNotFound;
        #seedGenerationError : Text;
        #notAuthorized;
    };

    public type CreateTeamRequest = {
        name : Text;
        logoUrl : Text;
        tokenName : Text;
        tokenSymbol : Text;
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

    public type SeasonSchedule = {
        matchGroups : [MatchGroupScheduleWithId];
    };

    public type MatchGroupSchedule = {
        time : Time.Time;
        matches : [MatchSchedule];
        status : MatchGroupScheduleStatus;
    };
    public type MatchGroupScheduleWithId = MatchGroupSchedule and {
        id : Nat32;
    };

    public type ErrorMatchGroupScheduleStatus = Stadium.ScheduleMatchGroupError or {
        #scheduleError : Text;
    };

    public type MatchGroupScheduleStatus = {
        #notOpen;
        #error : ErrorMatchGroupScheduleStatus;
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
    public type StartSeasonRequest = {
        startTime : Time.Time;
    };

    public type StartSeasonResult = {
        #ok;
        #alreadyStarted;
        #noStadiumsExist;
        #seedGenerationError : Text;
        #noTeams;
        #oddNumberOfTeams;
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
};
