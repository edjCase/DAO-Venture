import Principal "mo:base/Principal";
import Time "mo:base/Time";
import Nat "mo:base/Nat";
import Bool "mo:base/Bool";
import Player "../models/Player";
import StadiumTypes "../stadium/Types";
import MatchAura "../models/MatchAura";
import Team "../models/Team";
import Season "../models/Season";

module {

    public type TeamAssociationKind = {
        #fan;
        #owner;
    };

    public type User = {
        // TODO team association be in the season?
        teamAssociation : ?{
            id : Principal;
            kind : TeamAssociationKind;
        };
        points : Int;
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
