import Trie "mo:base/Trie";
import Principal "mo:base/Principal";
import Iter "mo:base/Iter";
import Hash "mo:base/Hash";
import IterTools "mo:itertools/Iter";
import Types "./Types";
// import LeagueActor "canister:league"; TODO

actor : Types.Actor {

    stable var users : Trie.Trie<Principal, Types.User> = Trie.empty();

    public shared query ({ caller }) func get(userId : Principal) : async Types.GetUserResult {
        if (caller != userId and not isLeague(caller)) {
            return #notAuthorized;
        };
        let ?user = Trie.get(users, buildPrincipalKey(userId), Principal.equal) else return #notFound;
        #ok(user);
    };

    // TODO should there be a get all?
    public shared query func getAll() : async [Types.User] {
        Trie.iter(users)
        |> Iter.map(
            _,
            func((_, user) : (Principal, Types.User)) : Types.User = user,
        )
        |> Iter.toArray(_);
    };

    public shared query func getTeamOwners(request : Types.GetTeamOwnersRequest) : async Types.GetTeamOwnersResult {
        let owners = Trie.iter(users)
        |> IterTools.mapFilter(
            _,
            func((userId, user) : (Principal, Types.User)) : ?Types.UserVotingInfo {
                let ?team = user.team else return null;
                switch (request) {
                    case (#team(teamId)) {
                        // Filter to only the team we want
                        if (team.id != teamId) {
                            return null;
                        };
                    };
                    case (#all) (); // No filter
                };
                let #owner(o) = team.kind else return null;
                ?{
                    id = userId;
                    votingPower = o.votingPower;
                };
            },
        )
        |> Iter.toArray(_);
        #ok(owners);
    };

    public shared ({ caller }) func setFavoriteTeam(userId : Principal, teamId : Nat) : async Types.SetUserFavoriteTeamResult {
        if (Principal.isAnonymous(userId)) {
            return #identityRequired;
        };
        if (caller != userId and not isLeague(caller)) {
            return #notAuthorized;
        };
        let userInfo = getUserInfoInternal(userId);
        switch (userInfo.team) {
            case (?team) {
                return #alreadySet;
            };
            case (null) {
                let teamExists = true; // TODO get all team ids and check if teamId is in there
                if (not teamExists) {
                    return #teamNotFound;
                };
                updateUser(
                    userId,
                    func(user : Types.User) : Types.User = {
                        user with
                        team = ?{
                            id = teamId;
                            kind = #fan;
                        };
                    },
                );
            };
        };
        #ok;
    };

    public shared ({ caller }) func addTeamOwner(request : Types.AddTeamOwnerRequest) : async Types.AddTeamOwnerResult {
        if (not isLeague(caller)) {
            return #notAuthorized;
        };
        let userInfo = getUserInfoInternal(request.userId);
        switch (userInfo.team) {
            case (?team) {
                if (team.id != request.teamId) {
                    return #onOtherTeam(team.id);
                };
            };
            case (null) {
                let teamExists = true; // TODO get all team ids and check if teamId is in there
                if (not teamExists) {
                    return #teamNotFound;
                };
            };
        };
        updateUser(
            request.userId,
            func(user : Types.User) : Types.User = {
                user with
                team = ?{
                    id = request.teamId;
                    kind = #owner({ votingPower = request.votingPower });
                };
            },
        );
        #ok;
    };

    // TODO change to BoomDAO or ledger
    public shared ({ caller }) func awardPoints(awards : [Types.AwardPointsRequest]) : async Types.AwardPointsResult {
        if (not isLeague(caller)) {
            return #notAuthorized;
        };
        for (award in Iter.fromArray(awards)) {
            updateUser(
                award.userId,
                func(user : Types.User) : Types.User = {
                    user with
                    points = user.points + award.points;
                },
            );
        };
        #ok;
    };

    public shared ({ caller }) func onSeasonComplete() : async Types.OnSeasonCompleteResult {
        if (not isLeague(caller)) {
            return #notAuthorized;
        };
        users := Trie.empty();
        #ok;
    };

    private func updateUser(userId : Principal, f : (Types.User) -> Types.User) {
        let userInfo = getUserInfoInternal(userId);
        let newUserInfo = f(userInfo);
        let key = buildPrincipalKey(userId);
        let (newUsers, _) = Trie.put(users, key, Principal.equal, newUserInfo);
        users := newUsers;
    };

    private func getUserInfoInternal(userId : Principal) : Types.User {
        switch (Trie.get(users, buildPrincipalKey(userId), Principal.equal)) {
            case (?userInfo) userInfo;
            case (null) {
                {
                    id = userId;
                    team = null;
                    points = 0;
                };
            };
        };
    };

    private func buildPrincipalKey(id : Principal) : {
        key : Principal;
        hash : Hash.Hash;
    } {
        { key = id; hash = Principal.hash(id) };
    };

    private func isLeague(_ : Principal) : Bool {
        // TODO
        // return caller == Principal.fromActor(LeagueActor);
        return true;
    };
};
