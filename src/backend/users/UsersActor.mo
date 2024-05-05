import Principal "mo:base/Principal";
import Nat "mo:base/Nat";
import Types "./Types";
import UserHandler "UserHandler";
// import LeagueActor "canister:league"; TODO

actor : Types.Actor {

    stable var stableData = {
        users : UserHandler.StableData = {
            users = [];
        };
    };

    var userHandler = UserHandler.UserHandler(stableData.users);

    system func preupgrade() {
        stableData := {
            users = userHandler.toStableData();
        };
    };

    system func postupgrade() {
        userHandler := UserHandler.UserHandler(stableData.users);
    };

    public shared query ({ caller }) func get(userId : Principal) : async Types.GetUserResult {
        if (caller != userId and not isLeague(caller)) {
            return #err(#notAuthorized);
        };
        switch (userHandler.get(userId)) {
            case (?user) #ok(user);
            case (null) #err(#notFound);
        };
    };

    public shared query func getStats() : async Types.GetStatsResult {
        let stats = userHandler.getStats();
        #ok(stats);
    };

    public shared query func getUserLeaderboard(request : Types.GetUserLeaderboardRequest) : async Types.GetUserLeaderboardResult {
        let topUsers = userHandler.getUserLeaderboard(request.count, request.offset);
        #ok(topUsers);
    };

    public shared query func getTeamOwners(request : Types.GetTeamOwnersRequest) : async Types.GetTeamOwnersResult {
        let owners = userHandler.getTeamOwners(request);
        #ok(owners);
    };

    public shared ({ caller }) func setFavoriteTeam(userId : Principal, teamId : Nat) : async Types.SetUserFavoriteTeamResult {
        if (Principal.isAnonymous(userId)) {
            return #err(#identityRequired);
        };
        if (caller != userId and not isLeague(caller)) {
            return #err(#notAuthorized);
        };

        userHandler.setFavoriteTeam(userId, teamId);
    };

    public shared ({ caller }) func addTeamOwner(request : Types.AddTeamOwnerRequest) : async Types.AddTeamOwnerResult {
        if (not isLeague(caller)) {
            return #err(#notAuthorized);
        };
        userHandler.addTeamOwner(request);
    };

    // TODO change to BoomDAO or ledger
    public shared ({ caller }) func awardPoints(awards : [Types.AwardPointsRequest]) : async Types.AwardPointsResult {
        if (not isLeague(caller)) {
            return #err(#notAuthorized);
        };
        userHandler.awardPoints(awards);
        #ok;
    };

    public shared ({ caller }) func onSeasonEnd() : async Types.OnSeasonEndResult {
        if (not isLeague(caller)) {
            return #err(#notAuthorized);
        };
        // TODO
        #ok;
    };

    private func isLeague(_ : Principal) : Bool {
        // TODO
        // return caller == Principal.fromActor(LeagueActor);
        return true;
    };
};
