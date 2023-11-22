import Stadium "Stadium";
import TimeZone "mo:datetime/TimeZone";
import Principal "mo:base/Principal";
import Time "mo:base/Time";
import Nat "mo:base/Nat";
import Team "Team";
import ICRC1 "mo:icrc1/ICRC1";
import Player "Player";

module {
    public type LeagueActor = actor {
        getTeams : query () -> async [Team.TeamWithId];
        getSeasonStatus : query () -> async SeasonStatus;
        startSeason : (request : StartSeasonRequest) -> async StartSeasonResult;
        getMatchGroup : query (id : Nat32) -> async ?MatchGroupScheduleWithId;
        createTeam : (request : CreateTeamRequest) -> async CreateTeamResult;
        mint : (request : MintRequest) -> async MintResult;
        updateLeagueCanisters : () -> async ();
        onMatchGroupStart(request : OnMatchGroupStartRequest) : async OnMatchGroupStartResult;
        onMatchGroupComplete : (request : OnMatchGroupCompleteRequest) -> async OnMatchGroupCompleteResult;
    };

    public type OnMatchGroupStartRequest = {
        id : Nat32;
    };

    public type OnMatchGroupStartError = {
        #notAuthorized;
        #matchGroupNotFound;
        #notScheduledYet;
        #alreadyStarted;
    };

    public type OnMatchGroupStartResult = OnMatchGroupStartError or {
        #ok : MatchGroupStartData;
    };

    public type MatchGroupStartData = {
        matches : [MatchStartOrSkip];
    };

    public type MatchStartOrSkip = {
        #start : MatchStartData;
        #absentTeam : Stadium.TeamId;
        #allAbsent;
    };

    public type MatchStartData = {
        team1 : TeamStartData;
        team2 : TeamStartData;
        aura : Stadium.MatchAura;
    };

    public type TeamStartData = {
        offering : Stadium.Offering;
        championId : Nat32;
        players : [Player.PlayerWithId];
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
        teams : [CompletedSeasonTeam];
        matchGroups : [CompletedMatchGroup];
    };

    public type CompletedSeasonTeam = {
        id : Principal;
        name : Text;
        logoUrl : Text;
    };

    public type CompletedMatchGroup = {
        id : Nat32;
        state : CompletedMatchGroupState;
    };

    public type CompletedMatchGroupState = {
        #played : PlayedMatchGroupState;
        #canceled;
        #scheduleError : ScheduleMatchGroupError;
    };
    public type PlayedMatchGroupState = {
        matches : [CompletedMatch];
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
        #notScheduled;
        #scheduleError : ScheduleMatchGroupError;
        #scheduled : ScheduledMatchGroupState;
        #inProgress : InProgressMatchGroupState;
        #completed : CompletedMatchGroupState;
    };

    public type InProgressMatchGroupState = {
        stadiumId : Principal;
        matches : [MatchStartOrSkip];
    };

    public type ScheduledMatchGroupState = {
        matches : [ScheduledMatchState];
    };

    public type ScheduledMatchState = {
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
};
