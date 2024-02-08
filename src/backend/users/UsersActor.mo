import Trie "mo:base/Trie";
import Player "../models/Player";
import Nat32 "mo:base/Nat32";
import Debug "mo:base/Debug";
import Principal "mo:base/Principal";
import Buffer "mo:base/Buffer";
import Iter "mo:base/Iter";
import Hash "mo:base/Hash";
import TextX "mo:xtended-text/TextX";
import IterTools "mo:itertools/Iter";
import Types "./Types";
// import LeagueActor "canister:league"; TODO

actor UsersActor {

    stable var users : Trie.Trie<Principal, Types.User> = Trie.empty();

    public shared query ({ caller }) func get(userId : Principal) : async Types.GetUserResult {
        if (caller != userId and not isLeague(caller)) {
            return #notAuthorized;
        };
        let ?user = Trie.get(users, buildPrincipalKey(userId), Principal.equal) else return #notFound;
        #ok(user);
    };

    public shared ({ caller }) func setFavoriteTeam(userId : Principal, teamId : Principal) : async Types.SetUserFavoriteTeamResult {
        if (caller != userId and not isLeague(caller)) {
            return #notAuthorized;
        };
        updateUser(
            userId,
            func(user : Types.User) : Types.User = {
                user with
                favoriteTeamId = ?teamId;
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
                    favoriteTeamId = null;
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

    private func isLeague(caller : Principal) : Bool {
        // TODO
        // return caller == Principal.fromActor(LeagueActor);
        return true;
    };

    private func assertLeague(caller : Principal) {
        // TODO
        // if (!isLeague(caller)) {
        //     Debug.trap("Only the league can create players");
        // };
    };
};
