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
        getSeasonStatus : composite query () -> async SeasonStatus;
        startSeason : (request : StartSeasonRequest) -> async StartSeasonResult;
        createStadium : () -> async CreateStadiumResult;
        createTeam : (request : CreateTeamRequest) -> async CreateTeamResult;
        mint : (request : MintRequest) -> async MintResult;
        updateLeagueCanisters : () -> async ();
        onMatchGroupComplete : (request : OnMatchGroupCompleteRequest) -> async OnMatchGroupCompleteResult;
    };

    public type OnMatchGroupCompleteRequest = {
        id : Nat32;
        state : CompletedMatchGroupState;
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

    public type SeasonStatus = {
        #notStarted;
        #starting;
        #inProgress : SeasonSchedule;
        #completed : CompletedSeasonSchedule;
    };

    public type SeasonSchedule = {
        matchGroups : [MatchGroupScheduleWithId];
    };

    public type CompletedSeasonSchedule = {
        teamStandings : [Principal]; // 1st to last place
        matchGroups : [CompletedMatchGroup];
    };

    public type CompletedMatchGroup = {
        id : Nat32;
        state : CompletedMatchGroupState;
    };

    public type CompletedMatchGroupState = {
        #played : [CompletedMatch];
        #unplayed : {
            #notStarted;
            #scheduleError : ScheduleMatchGroupError;
        };
    };

    public type CompletedMatch = Stadium.MatchWithoutState and {
        state : Stadium.CompletedMatchState;
    };

    public type MatchGroupSchedule = {
        time : Time.Time;
        matches : [MatchSchedule];
        status : MatchGroupScheduleStatus;
    };
    public type MatchGroupScheduleWithId = MatchGroupSchedule and {
        id : Nat32;
    };

    public type ScheduleMatchGroupError = Stadium.ScheduleMatchGroupError or {
        #stadiumScheduleCallError : Text;
    };

    public type MatchGroupScheduleStatus = {
        #notOpen;
        #scheduleError : ScheduleMatchGroupError;
        #open : OpenMatchGroupState;
        #completed : CompletedMatchGroupState;
    };

    public type OpenMatchGroupState = {
        matches : [OpenMatchState];
    };

    public type OpenMatchState = {
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
