import Principal "mo:base/Principal";
import Player "Player";
import DateTime "mo:datetime/DateTime";
import Time "mo:base/Time";
import Nat32 "mo:base/Nat32";
import Trie "mo:base/Trie";
import Hash "mo:base/Hash";
import Nat "mo:base/Nat";
import Team "Team";
import ICRC1 "mo:icrc1/ICRC1";
import Stadium "Stadium";

module {
    type TeamWithId = Team.TeamWithId;

    public type DivisionActor = actor {
        getTeams : query () -> async [TeamWithId];
        createTeam(request : CreateTeamRequest) : async CreateTeamResult;
        scheduleSeason(request : ScheduleSeasonRequest) : async ScheduleSeasonResult;
        mint(request : MintRequest) : async MintResult;
        updateDivisionCanisters() : async ();
    };
    public type ScheduleSeasonRequest = {
        start : Time.Time;
    };

    public type ScheduleSeasonResult = {
        #ok;
        #error : ScheduleError;
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

    public type CreateTeamRequest = {
        name : Text;
        logoUrl : Text;
        tokenName : Text;
        tokenSymbol : Text;
    };
    public type CreateTeamResult = {
        #ok : Principal;
        #nameTaken;
    };
    public type ScheduleError = {
        #missingDivision;
        #oddNumberOfTeams;
        #divisionNotFound;
        #alreadyScheduled;
        #noTeamsInDivision;
    };
    public type SeasonSchedule = {
        weeks : [WeekSchedule];
    };
    public type WeekSchedule = {
        matches : [MatchSchedule];
    };
    public type MatchScheduleStatus = {
        #scheduled : Nat32;
        #failedToSchedule : Stadium.ScheduleMatchGroupError or {
            #scheduleMatchGroupError : Text;
        };
    };
    public type MatchSchedule = {
        status : MatchScheduleStatus;
        stadiumId : Principal;
        team1Id : Principal;
        team2Id : Principal;
    };
};
