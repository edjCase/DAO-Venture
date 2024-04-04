import Principal "mo:base/Principal";
import Nat "mo:base/Nat";

module {

    public type Actor = actor {
        get : query (userId : Principal) -> async GetUserResult;
        getStats : query () -> async GetStatsResult;
        getTeamOwners : query (request : GetTeamOwnersRequest) -> async GetTeamOwnersResult;
        setFavoriteTeam : (userId : Principal, teamId : Nat) -> async SetUserFavoriteTeamResult;
        addTeamOwner : (request : AddTeamOwnerRequest) -> async AddTeamOwnerResult;
        awardPoints : (awards : [AwardPointsRequest]) -> async AwardPointsResult;
        onSeasonEnd : () -> async OnSeasonEndResult;
    };

    public type GetStatsResult = {
        #ok : UserStats;
    };

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

    public type OnSeasonEndResult = {
        #ok;
        #notAuthorized;
    };

    public type GetTeamOwnersRequest = {
        #team : Nat;
        #all;
    };

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

    public type AddTeamOwnerResult = {
        #ok;
        #onOtherTeam : Nat;
        #teamNotFound;
        #notAuthorized;
    };

    public type GetUserResult = {
        #ok : User;
        #notFound;
        #notAuthorized;
    };

    public type AwardPointsRequest = {
        userId : Principal;
        points : Int;
    };

    public type AwardPointsResult = {
        #ok;
        #notAuthorized;
    };

    public type SetUserFavoriteTeamResult = {
        #ok;
        #identityRequired;
        #teamNotFound;
        #notAuthorized;
        #alreadySet;
    };
};
