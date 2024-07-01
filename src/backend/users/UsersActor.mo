import Principal "mo:base/Principal";
import Nat "mo:base/Nat";
import Types "./Types";
import UserHandler "UserHandler";
import LeagueTypes "../league/Types";

actor class Users(
    leagueCanisterId : Principal
) : async Types.Actor = this {

    stable var userStableData : UserHandler.StableData = {
        users = [];
    };

    var userHandler = UserHandler.UserHandler(userStableData);

    system func preupgrade() {
        userStableData := userHandler.toStableData();
    };

    system func postupgrade() {
        userHandler := UserHandler.UserHandler(userStableData);
    };

    public shared query func get(userId : Principal) : async Types.GetUserResult {
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
        if (caller != userId and not (await* isLeagueOrBDFN(caller))) {
            return #err(#notAuthorized);
        };

        userHandler.setFavoriteTeam(userId, teamId);
    };

    public shared ({ caller }) func addTeamOwner(request : Types.AddTeamOwnerRequest) : async Types.AddTeamOwnerResult {
        if (not (await* isLeagueOrBDFN(caller))) {
            return #err(#notAuthorized);
        };
        userHandler.addTeamOwner(request);
    };

    // TODO change to BoomDAO or ledger
    public shared ({ caller }) func awardPoints(awards : [Types.AwardPointsRequest]) : async Types.AwardPointsResult {
        if (not (await* isLeagueOrBDFN(caller))) {
            return #err(#notAuthorized);
        };
        userHandler.awardPoints(awards);
        #ok;
    };

    public shared ({ caller }) func onSeasonEnd() : async Types.OnSeasonEndResult {
        if (not (await* isLeagueOrBDFN(caller))) {
            return #err(#notAuthorized);
        };
        // TODO
        #ok;
    };

    private func isLeagueOrBDFN(caller : Principal) : async* Bool {
        if (leagueCanisterId == caller) {
            return true;
        };
        // TODO change to league push new bdfn vs fetch?
        let leagueActor = actor (Principal.toText(leagueCanisterId)) : LeagueTypes.LeagueActor;
        switch (await leagueActor.getBenevolentDictatorState()) {
            case (#claimed(bdfnId)) caller == bdfnId;
            case (#disabled or #open) false;
        };
    };
};
