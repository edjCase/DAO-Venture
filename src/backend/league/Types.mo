import Principal "mo:base/Principal";
import Time "mo:base/Time";
import Nat "mo:base/Nat";
import Bool "mo:base/Bool";
import Player "../models/Player";
import StadiumTypes "../stadium/Types";
import MatchAura "../models/MatchAura";
import Team "../models/Team";
import Season "../models/Season";
import Scenario "../models/Scenario";

module {
    public type LeagueActor = actor {
        getTeams : query () -> async [Team.TeamWithId];
        getSeasonStatus : query () -> async Season.SeasonStatus;
        getTeamStandings : query () -> async GetTeamStandingsResult;
        getScenario : query (id : Text) -> async GetScenarioResult;
        processEventOutcomes : (request : ProcessEffectOutcomesRequest) -> async ProcessEffectOutcomesResult;
        startSeason : (request : StartSeasonRequest) -> async StartSeasonResult;
        closeSeason : () -> async CloseSeasonResult;
        createTeam : (request : CreateTeamRequest) -> async CreateTeamResult;
        predictMatchOutcome : (request : PredictMatchOutcomeRequest) -> async PredictMatchOutcomeResult;
        getMatchGroupPredictions : (matchGroupId : Nat) -> async GetMatchGroupPredictionsResult;
        updateLeagueCanisters : () -> async UpdateLeagueCanistersResult;
        startMatchGroup : (id : Nat) -> async StartMatchGroupResult;
        onMatchGroupComplete : (request : OnMatchGroupCompleteRequest) -> async OnMatchGroupCompleteResult;
        setUserIsAdmin : (id : Principal, isAdmin : Bool) -> async SetUserIsAdminResult;
        getAdmins : query () -> async [Principal];
    };

    public type GetScenarioResult = {
        #ok : Scenario;
        #notFound;
    };

    public type Scenario = {
        id : Text;
        title : Text;
        description : Text;
        options : [ScenarioOption];
        state : {
            #notStarted;
            #started;
            #resolved : {
                teamChoices : [{
                    teamId : Principal;
                    option : Nat;
                }];
            };
        };

    };

    public type ScenarioOption = {
        id : Nat;
        description : Text;
    };

    public type TeamStandingInfo = {
        id : Principal;
        wins : Nat;
        losses : Nat;
        totalScore : Int;
    };

    public type GetTeamStandingsResult = {
        #ok : [TeamStandingInfo];
        #notFound;
    };

    public type ProcessEffectOutcomesRequest = {
        outcomes : [Scenario.EffectOutcome];
    };

    public type ProcessEffectOutcomesResult = {
        #ok;
        #notAuthorized;
        #seasonNotInProgress;
    };

    public type SetUserIsAdminResult = {
        #ok;
        #notAuthorized;
    };

    public type GetMatchGroupPredictionsResult = {
        #ok : MatchGroupPredictionSummary;
        #notFound;
    };

    public type MatchGroupPredictionSummary = {
        matches : [MatchPredictionSummary];
    };

    public type MatchPredictionSummary = {
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
        scenarios : [AddScenarioRequest];
    };

    public type AddScenarioRequest = {
        id : Text;
        title : Text;
        description : Text;
        options : [Scenario.ScenarioOption];
        metaEffect : Scenario.MetaEffect;
    };

    public type StartSeasonResult = {
        #ok;
        #alreadyStarted;
        #noStadiumsExist;
        #seedGenerationError : Text;
        #noTeams;
        #oddNumberOfTeams;
        #notAuthorized;
        #scenarioCountMismatch : {
            expected : Nat;
            actual : Nat;
        };
        #invalidScenario : {
            id : Text;
            errors : [Text];
        };
    };

    public type CloseSeasonResult = {
        #ok;
        #notAuthorized;
        #seasonNotOpen;
    };

    // On complete

    public type OnMatchGroupCompleteRequest = {
        id : Nat;
        matches : [Season.CompletedMatch];
        playerStats : [Player.PlayerMatchStatsWithId];
    };

    public type FailedMatchResult = {
        message : Text;
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
        motto : Text;
        description : Text;
        color : (Nat8, Nat8, Nat8);
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
