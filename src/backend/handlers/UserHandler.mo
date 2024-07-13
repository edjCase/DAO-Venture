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
        membership : ?UserMembership;
        points : Int;
    };

    public type UserMembership = {
        teamId : ?Nat;
        votingPower : Nat;
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
        var membership : ?UserMembership;
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
                switch (user.membership) {
                    case (?membership) {
                        switch (membership.teamId) {
                            case (?teamId) {
                                let stats : TeamStats = switch (teamStats.get(teamId)) {
                                    case (?stats) stats;
                                    case (null) {
                                        {
                                            id = teamId;
                                            totalPoints = 0;
                                            userCount = 0;
                                            ownerCount = 0;
                                        };
                                    };
                                };

                                let newStats : TeamStats = {
                                    id = teamId;
                                    totalPoints = stats.totalPoints + user.points;
                                    userCount = stats.userCount + 1;
                                    ownerCount = stats.ownerCount + 1;
                                };
                                teamStats.put(teamId, newStats);
                                leagueStats.teamOwnerCount += 1;
                            };
                            case (null) ();
                        };

                        leagueStats.totalPoints += user.points;
                        leagueStats.userCount += 1;

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
            let getMatchingTeamMembership = switch (teamId) {
                case (?tId) func(membership : UserMembership) : ?Nat {
                    // Filter to only the team we want
                    if (membership.teamId == ?tId) {
                        return ?tId;
                    };
                    return null;
                };
                case (null) func(membership : UserMembership) : ?Nat {
                    membership.teamId;
                };
            };

            let owners = users.vals()
            |> IterTools.mapFilter(
                _,
                func(user : MutableUser) : ?UserVotingInfo {
                    let ?membership = user.membership else return null;
                    switch (getMatchingTeamMembership(membership)) {
                        case (?teamId) {
                            ?{
                                id = user.id;
                                teamId = teamId;
                                votingPower = membership.votingPower;
                            };
                        };
                        case (null) {
                            return null;
                        };
                    };
                },
            )
            |> Iter.toArray(_);
            owners;
        };

        public func addLeagueMember(userId : Principal, votingPower : Nat) : Result.Result<(), { #alreadyLeagueMember }> {
            let user = getOrCreateUser(userId);
            switch (user.membership) {
                case (?membership) {
                    return #err(#alreadyLeagueMember);
                };
                case (null) {
                    user.membership := ?{
                        teamId = null;
                        votingPower = votingPower;
                    };
                    #ok;
                };
            };
        };

        public func assignToTeam(
            userId : Principal,
            teamId : Nat,
        ) : Result.Result<(), { #alreadyOnTeam; #notLeagueMember }> {
            let user = getOrCreateUser(userId);
            switch (user.membership) {
                case (?membership) {
                    if (membership.teamId != null) {
                        return #err(#alreadyOnTeam);
                    };
                    user.membership := ?{
                        membership with
                        teamId = ?teamId;
                    };
                    #ok;
                };
                case (null) {
                    // Add as owner
                    return #err(#notLeagueMember);
                };
            };
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
                        var membership = null;
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
            var membership = user.membership;
            var points = user.points;
        };
    };

    private func fromMutableUser(user : MutableUser) : User {
        {
            id = user.id;
            membership = user.membership;
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
