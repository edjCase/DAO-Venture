import Principal "mo:base/Principal";
import Nat "mo:base/Nat";
import Result "mo:base/Result";
import CommonTypes "../Types";

module {

    public type Actor = actor {
        get : query (userId : Principal) -> async GetUserResult;
        getStats : query () -> async GetStatsResult;
        getTeamOwners : query (request : GetTeamOwnersRequest) -> async GetTeamOwnersResult;
        getUserLeaderboard : query (request : GetUserLeaderboardRequest) -> async GetUserLeaderboardResult;
        setFavoriteTeam : (userId : Principal, teamId : Nat) -> async SetUserFavoriteTeamResult;
        addTeamOwner : (request : AddTeamOwnerRequest) -> async AddTeamOwnerResult;
        awardPoints : (awards : [AwardPointsRequest]) -> async AwardPointsResult;
        onSeasonEnd : () -> async OnSeasonEndResult;
    };

    public type GetUserLeaderboardRequest = {
        count : Nat;
        offset : Nat;
    };

    public type GetUserLeaderboardResult = {
        #ok : CommonTypes.PagedResult<User>;
    };

    public type GetStatsResult = Result.Result<UserStats, ()>;

    public type UserStats = {
        totalPoints : Int;
        userCount : Nat;
        teamOwnerCount : Nat;
        teams : [TeamStats];
    };

    public type TeamStats = {
        id : Nat;
        totalPoints : Int;
        userCount : Nat;
        ownerCount : Nat;
    };
    public type OnSeasonEndError = {
        #notAuthorized;
    };

    public type OnSeasonEndResult = Result.Result<(), OnSeasonEndError>;

    public type GetTeamOwnersRequest = {
        #team : Nat;
        #all;
    };

    public type GetTeamOwnersError = {};

    public type GetTeamOwnersResult = {
        #ok : [UserVotingInfo];
    };

    public type TeamAssociationKind = {
        #fan;
        #owner : {
            votingPower : Nat;
        };
    };

    public type User = {
        // TODO team association be in the season?
        id : Principal;
        team : ?{
            id : Nat;
            kind : TeamAssociationKind;
        };
        points : Int;
    };

    public type UserVotingInfo = {
        id : Principal;
        teamId : Nat;
        votingPower : Nat;
    };

    public type AddTeamOwnerRequest = {
        userId : Principal;
        teamId : Nat;
        votingPower : Nat;
    };

    public type AddTeamOwnerError = {
        #onOtherTeam : Nat;
        #teamNotFound;
        #notAuthorized;
    };

    public type AddTeamOwnerResult = Result.Result<(), AddTeamOwnerError>;

    public type GetUserError = {
        #notFound;
        #notAuthorized;
    };

    public type GetUserResult = Result.Result<User, GetUserError>;

    public type AwardPointsRequest = {
        userId : Principal;
        points : Int;
    };

    public type AwardPointsError = {
        #notAuthorized;
    };

    public type AwardPointsResult = Result.Result<(), AwardPointsError>;

    public type SetUserFavoriteTeamError = {
        #identityRequired;
        #teamNotFound;
        #notAuthorized;
        #alreadySet;
    };

    public type SetUserFavoriteTeamResult = Result.Result<(), SetUserFavoriteTeamError>;
};
