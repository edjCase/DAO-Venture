import Principal "mo:base/Principal";
import Time "mo:base/Time";
import Nat "mo:base/Nat";
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
        getUserInfo : query () -> async ?UserInfo;
        updateUserInfo : query (id : Principal, request : UserInfo) -> async UpdateUserInfoResult;
        startSeason : (request : StartSeasonRequest) -> async StartSeasonResult;
        closeSeason : () -> async CloseSeasonResult;
        createTeam : (request : CreateTeamRequest) -> async CreateTeamResult;
        predictMatchOutcome : (request : PredictMatchOutcomeRequest) -> async PredictMatchOutcomeResult;
        getUpcomingMatchPredictions : () -> async UpcomingMatchPredictionsResult;
        updateLeagueCanisters : () -> async UpdateLeagueCanistersResult;
        startMatchGroup : (id : Nat) -> async StartMatchGroupResult;
        onMatchGroupComplete : (request : OnMatchGroupCompleteRequest) -> async OnMatchGroupCompleteResult;
    };

    public type UserInfo = {
        isAdmin : Bool;
    };

    public type UpdateUserInfoRequest = {
        isAdmin : Bool;
    };

    public type UpdateUserInfoResult = {
        #ok;
        #notAuthorized;
    };

    public type UpcomingMatchPredictionsResult = {
        #ok : [UpcomingMatchPrediction];
        #noUpcomingMatches;
    };

    public type UpcomingMatchPrediction = {
        team1 : Nat;
        team2 : Nat;
        yourVote : ?Team.TeamId;
    };

    public type UpdateLeagueCanistersResult = {
        #ok;
        #notAuthorized;
    };

    public type PredictMatchOutcomeRequest = {
        matchId : Nat32;
        winner : ?Team.TeamId;
    };

    public type PredictMatchOutcomeResult = {
        #ok;
        #matchGroupNotFound;
        #matchNotFound;
        #predictionsClosed;
        #identityRequired;
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
        #notAuthorized;
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
        matches : [Season.CompletedMatchWithoutPredictions];
    };

    public type PlayedMatchResult = {
        team1 : PlayedMatchTeamData;
        team2 : PlayedMatchTeamData;
        winner : Team.TeamIdOrTie;
    };

    public type PlayedMatchTeamData = {
        score : Int;
        offering : Offering.Offering;
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
        motto : Text;
        description : Text;
    };

    public type CreateTeamResult = {
        #ok : Principal;
        #nameTaken;
        #noStadiumsExist;
        #teamFactoryCallError : Text;
        #notAuthorized;
        #populateTeamRosterCallError : Text;
    };
};
