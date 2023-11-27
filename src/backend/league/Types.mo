import TimeZone "mo:datetime/TimeZone";
import Components "mo:datetime/Components";
import Principal "mo:base/Principal";
import Time "mo:base/Time";
import Nat "mo:base/Nat";
import ICRC1 "mo:icrc1/ICRC1";
import Player "../models/Player";
import StadiumTypes "../stadium/Types";
import MatchAura "../models/MatchAura";
import Offering "../models/Offering";
import Team "../models/Team";
import Season "../models/Season";

module {
    public type LeagueActor = actor {
        getTeams : query () -> async [Team.TeamWithId];
        getSeasonStatus : query () -> async Season.SeasonStatus;
        startSeason : (request : StartSeasonRequest) -> async StartSeasonResult;
        createTeam : (request : CreateTeamRequest) -> async CreateTeamResult;
        mint : (request : MintRequest) -> async MintResult;
        updateLeagueCanisters : () -> async ();
        onMatchGroupStart(request : OnMatchGroupStartRequest) : async OnMatchGroupStartResult;
        onMatchGroupComplete : (request : OnMatchGroupCompleteRequest) -> async OnMatchGroupCompleteResult;
    };

    // On start

    public type OnMatchGroupStartRequest = {
        id : Nat;
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
        matches : [MatchStartOrSkipData];
    };

    public type MatchStartOrSkipData = {
        #start : MatchStartData;
        #absentTeam : Team.TeamId;
        #allAbsent;
    };

    public type MatchStartData = {
        team1 : TeamStartData;
        team2 : TeamStartData;
        aura : MatchAura.MatchAura;
    };

    public type TeamStartData = {
        offering : Offering.Offering;
        championId : Nat32;
        players : [Player.PlayerWithId];
    };

    // Start season
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

    // On complete

    public type OnMatchGroupCompleteRequest = {
        id : Nat;
        state : {

        };
    };

    public type OnMatchGroupCompleteResult = {
        #ok;
        #seasonNotOpen;
        #matchGroupNotFound;
        #seedGenerationError : Text;
        #notAuthorized;
    };

    // Create Team

    public type CreateTeamRequest = {
        name : Text;
        logoUrl : Text;
        tokenName : Text;
        tokenSymbol : Text;
    };

    public type CreateTeamResult = {
        #ok : Principal;
        #nameTaken;
        #noStadiumsExist;
    };

    // Mint

    public type MintRequest = {
        amount : Nat;
        teamId : Principal;
    };

    public type MintResult = {
        #ok : ICRC1.TxIndex;
        #teamNotFound;
        #transferError : ICRC1.TransferError;
    };
};
