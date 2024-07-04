import IterTools "mo:itertools/Iter";
import HashMap "mo:base/HashMap";
import Principal "mo:base/Principal";
import Iter "mo:base/Iter";
import Nat "mo:base/Nat";
import Nat32 "mo:base/Nat32";
import Order "mo:base/Order";
import Int "mo:base/Int";
import Result "mo:base/Result";
import CommonTypes "../CommonTypes";

module {

    public type User = {
        id : Principal;
        team : ?TeamAssociation;
        points : Int;
    };

    public type TeamAssociation = {
        id : Nat;
        kind : TeamAssociationKind;
    };

    public type TeamAssociationKind = {
        #fan;
        #owner : {
            votingPower : Nat;
        };
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

    public type UserVotingInfo = {
        id : Principal;
        teamId : Nat;
        votingPower : Nat;
    };

    public type StableData = {
        users : [User];
    };

    type MutableUser = {
        id : Principal;
        var team : ?TeamAssociation;
        var points : Int;
    };

    public class UserHandler(stableData : StableData) {
        let users : HashMap.HashMap<Principal, MutableUser> = buildUserMap(stableData.users);

        public func toStableData() : StableData {
            {
                users = users.vals() |> Iter.map(_, fromMutableUser) |> Iter.toArray(_);
            };
        };

        public func get(id : Principal) : ?User {
            let ?user = users.get(id) else return null;
            ?fromMutableUser(user);
        };

        public func getAll() : [User] {
            users.vals()
            |> Iter.map(_, fromMutableUser)
            |> Iter.toArray(_);
        };

        public func getStats() : UserStats {
            let leagueStats = {
                var totalPoints : Int = 0;
                var userCount = 0;
                var teamOwnerCount = 0;
            };
            let teamStats = HashMap.HashMap<Nat, TeamStats>(6, Nat.equal, Nat32.fromNat);
            for (user in users.vals()) {
                switch (user.team) {
                    case (?team) {
                        let stats : TeamStats = switch (teamStats.get(team.id)) {
                            case (?stats) stats;
                            case (null) {
                                {
                                    id = team.id;
                                    totalPoints = 0;
                                    userCount = 0;
                                    ownerCount = 0;
                                };
                            };
                        };
                        let isOwner = switch (team.kind) {
                            case (#owner(_)) true;
                            case (#fan) false;
                        };
                        let newStats : TeamStats = {
                            id = team.id;
                            totalPoints = stats.totalPoints + user.points;
                            userCount = stats.userCount + 1;
                            ownerCount = stats.ownerCount + (if (isOwner) 1 else 0);
                        };
                        leagueStats.totalPoints += user.points;
                        leagueStats.userCount += 1;
                        leagueStats.teamOwnerCount += (if (isOwner) 1 else 0);

                        teamStats.put(team.id, newStats);
                    };
                    case (null) ();
                };
            };
            {
                totalPoints = leagueStats.totalPoints;
                userCount = leagueStats.userCount;
                teamOwnerCount = leagueStats.teamOwnerCount;
                teams = Iter.toArray<TeamStats>(teamStats.vals());
            };
        };

        public func getUserLeaderboard(count : Nat, offset : Nat) : CommonTypes.PagedResult<User> {
            let orderedUsers = users.vals()
            |> IterTools.sort(
                _,
                func(u1 : MutableUser, u2 : MutableUser) : Order.Order = Int.compare(u2.points, u1.points),
            )
            |> IterTools.skip(_, offset)
            |> IterTools.take(_, count)
            |> Iter.map(_, fromMutableUser)
            |> Iter.toArray(_);
            {
                data = orderedUsers;
                count = count;
                offset = offset;
            };
        };

        public func getTeamOwners(teamId : ?Nat) : [UserVotingInfo] {
            let owners = users.vals()
            |> IterTools.mapFilter(
                _,
                func(user : MutableUser) : ?UserVotingInfo {
                    let ?team = user.team else return null;
                    switch (teamId) {
                        case (?teamId) {
                            // Filter to only the team we want
                            if (team.id != teamId) {
                                return null;
                            };
                        };
                        case (null) (); // No filter
                    };
                    let #owner(o) = team.kind else return null;
                    ?{
                        id = user.id;
                        teamId = team.id;
                        votingPower = o.votingPower;
                    };
                },
            )
            |> Iter.toArray(_);
            owners;
        };

        public func setFavoriteTeam(
            userId : Principal,
            teamId : Nat,
        ) : Result.Result<(), { #alreadySet }> {
            let user = getOrCreateUser(userId);
            switch (user.team) {
                case (?team) {
                    return #err(#alreadySet);
                };
                case (null) {
                    user.team := ?{
                        id = teamId;
                        kind = #fan;
                    };
                };
            };
            #ok;
        };

        public func addTeamOwner(
            userId : Principal,
            teamId : Nat,
            votingPower : Nat,
        ) : Result.Result<(), { #alreadyOwner; #onOtherTeam : Nat }> {
            let user = getOrCreateUser(userId);
            switch (user.team) {
                case (?team) {
                    if (team.id != teamId) {
                        return #err(#onOtherTeam(team.id));
                    };
                    switch (team.kind) {
                        case (#owner(_)) {
                            return #err(#alreadyOwner);
                        };
                        case (#fan) (); // Upgrade to owner
                    };
                };
                case (null) {
                    // Add as owner
                };
            };
            user.team := ?{
                id = teamId;
                kind = #owner({ votingPower = votingPower });
            };
            #ok;
        };

        public func awardPoints(
            userId : Principal,
            points : Int,
        ) : Result.Result<(), { #userNotFound }> {
            let ?user = users.get(userId) else return #err(#userNotFound);
            user.points += points;
            #ok;
        };

        private func getOrCreateUser(userId : Principal) : MutableUser {
            switch (users.get(userId)) {
                case (?userInfo) userInfo;
                case (null) {
                    let newUser : MutableUser = {
                        id = userId;
                        var team = null;
                        var points = 0;
                    };
                    users.put(userId, newUser);
                    newUser;
                };
            };
        };

    };

    private func toMutableUser(user : User) : MutableUser {
        {
            id = user.id;
            var team = user.team;
            var points = user.points;
        };
    };

    private func fromMutableUser(user : MutableUser) : User {
        {
            id = user.id;
            team = user.team;
            points = user.points;
        };
    };

    private func buildUserMap(users : [User]) : HashMap.HashMap<Principal, MutableUser> {
        users.vals()
        |> Iter.map(_, toMutableUser)
        |> Iter.map<MutableUser, (Principal, MutableUser)>(
            _,
            func(p : MutableUser) : (Principal, MutableUser) { (p.id, p) },
        )
        |> HashMap.fromIter<Principal, MutableUser>(_, users.size(), Principal.equal, Principal.hash);
    };

};
