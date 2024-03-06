import Principal "mo:base/Principal";
import Trie "mo:base/Trie";
import Player "../models/Player";
import StadiumTypes "../stadium/Types";

module {

    public type TeamActor = actor {
        getPlayers : composite query () -> async [Player.PlayerWithId];
        getScenarioVote : query (request : GetScenarioVoteRequest) -> async GetScenarioVoteResult;
        voteOnScenario : (request : VoteOnScenarioRequest) -> async VoteOnScenarioResult;
        getWinningScenarioOption : (request : GetWinningScenarioOptionRequest) -> async GetWinningScenarioOptionResult;
        onNewScenario : (request : OnNewScenarioRequest) -> async OnNewScenarioResult;
        onScenarioVoteComplete : (request : OnScenarioVoteCompleteRequest) -> async OnScenarioVoteCompleteResult;
        onSeasonComplete() : async OnSeasonCompleteResult;
    };

    public type TeamFactoryActor = actor {
        setLeague : (id : Principal) -> async SetLeagueResult;
        createTeamActor : (request : CreateTeamRequest) -> async CreateTeamResult;
        getTeamActors : () -> async [TeamActorInfoWithId];
        updateCanisters : () -> async ();
    };

    public type OnScenarioVoteCompleteRequest = {
        scenarioId : Text;
    };

    public type OnScenarioVoteCompleteResult = {
        #ok;
        #scenarioNotFound;
        #notAuthorized;
    };

    public type OnNewScenarioRequest = {
        scenarioId : Text;
        optionCount : Nat;
    };

    public type OnNewScenarioResult = {
        #ok;
        #notAuthorized;
    };

    public type OnSeasonCompleteResult = {
        #ok;
        #notAuthorized;
    };

    public type SetLeagueResult = {
        #ok;
        #notAuthorized;
    };

    public type TeamActorInfo = {};

    public type TeamActorInfoWithId = TeamActorInfo and { id : Principal };

    public type CreateTeamRequest = {

    };

    public type CreateTeamResult = {
        #ok : {
            id : Principal;
        };
    };

    public type MatchVoteResult = {
        votes : [Nat];
    };

    public type ScenarioVoteResult = {
        option : Nat;
    };

    public type GetScenarioVoteRequest = {
        scenarioId : Text;
    };

    public type GetScenarioVoteResult = {
        #ok : ?Nat;
        #scenarioNotFound;
    };

    public type GetWinningScenarioOptionRequest = {
        scenarioId : Text;
    };

    public type GetWinningScenarioOptionResult = {
        #ok : Nat;
        #noVotes;
        #notAuthorized;
        #scenarioNotFound;
    };

    public type GetCyclesResult = {
        #ok : Nat;
        #notAuthorized;
    };

    public type VoteOnScenarioRequest = {
        scenarioId : Text;
        option : Nat;
    };

    public type VoteOnScenarioResult = {
        #ok;
        #notAuthorized;
        #scenarioNotFound;
        #votingNotOpen;
        #teamNotInScenario;
        #alreadyVoted;
        #seasonStatusFetchError : Text;
        #invalidOption;
    };
};
