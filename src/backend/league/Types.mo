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
        closeSeason : () -> async CloseSeasonResult;
        createTeam : (request : CreateTeamRequest) -> async CreateTeamResult;
        mint : (request : MintRequest) -> async MintResult;
        updateLeagueCanisters : () -> async ();
        startMatchGroup : (id : Nat) -> async StartMatchGroupResult;
        onMatchGroupComplete : (request : OnMatchGroupCompleteRequest) -> async OnMatchGroupCompleteResult;
    };

    // On start
    public type StartMatchGroupResult = {
        #ok;
        #matchGroupNotFound;
        #notAuthorized;
        #notScheduledYet;
        #alreadyStarted;
        #matchErrors : [{
            matchId : Nat;
            error : StartMatchError;
        }];
    };

    public type StartMatchError = {
        #notEnoughPlayers : Team.TeamIdOrBoth;
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

    public type CloseSeasonResult = {
        #ok;
        #seasonInProgress;
        #notAuthorized;
        #seasonNotOpen;
    };

    // On complete

    public type OnMatchGroupCompleteRequest = {
        id : Nat;
        matches : [Season.CompletedMatch];
    };

    public type PlayedMatchResult = {
        team1 : PlayedMatchTeamData;
        team2 : PlayedMatchTeamData;
        winner : Team.TeamIdOrTie;
    };

    public type PlayedMatchTeamData = {
        score : Int;
        offering : Offering.Offering;
        championId : Player.PlayerId;
    };

    public type FailedMatchResult = {
        message : Text;
    };

    public type LogEntry = {
        message : Text;
        isImportant : Bool;
    };

    public type OnMatchGroupCompleteResult = {
        #ok;
        #seasonNotOpen;
        #matchGroupNotFound;
        #matchGroupNotInProgress;
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
        #teamFactoryCallError : Text;
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
