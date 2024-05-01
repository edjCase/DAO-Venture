import Types "./Types";
import IterTools "mo:itertools/Iter";
import HashMap "mo:base/HashMap";
import Principal "mo:base/Principal";
import Iter "mo:base/Iter";
import Nat "mo:base/Nat";
import Nat32 "mo:base/Nat32";
import Order "mo:base/Order";
import Int "mo:base/Int";
import CommonTypes "../Types";

module {

    public type User = {
        id : Principal;
        team : ?{
            id : Nat;
            kind : Types.TeamAssociationKind;
        };
        points : Int;
    };

    public type StableData = {
        users : [User];
    };

    public class UserHandler(stableData : StableData) {
        let users : HashMap.HashMap<Principal, User> = buildUserMap(stableData.users);

        public func toStableData() : StableData {
            {
                users = Iter.toArray(users.vals());
            };
        };

        public func get(id : Principal) : ?User {
            users.get(id);
        };

        public func getAll() : [User] {
            users.vals()
            |> Iter.toArray(_);
        };

        public func getStats() : Types.UserStats {
            let leagueStats = {
                var totalPoints : Int = 0;
                var userCount = 0;
                var teamOwnerCount = 0;
            };
            let teamStats = HashMap.HashMap<Nat, Types.TeamStats>(6, Nat.equal, Nat32.fromNat);
            for (user in users.vals()) {
                switch (user.team) {
                    case (?team) {
                        let stats : Types.TeamStats = switch (teamStats.get(team.id)) {
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
                        let newStats : Types.TeamStats = {
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
                teams = Iter.toArray<Types.TeamStats>(teamStats.vals());
            };
        };

        public func getUserLeaderboard(count : Nat, offset : Nat) : CommonTypes.PagedResult<User> {
            let orderedUsers = users.vals()
            |> IterTools.sort(
                _,
                func(u1 : User, u2 : User) : Order.Order = Int.compare(u2.points, u1.points),
            )
            |> IterTools.skip(_, offset)
            |> IterTools.take(_, count)
            |> Iter.toArray(_);
            {
                data = orderedUsers;
                count = count;
                offset = offset;
            };
        };

        public func getTeamOwners(request : Types.GetTeamOwnersRequest) : [Types.UserVotingInfo] {
            let owners = users.vals()
            |> IterTools.mapFilter(
                _,
                func(user : Types.User) : ?Types.UserVotingInfo {
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
                        id = user.id;
                        teamId = team.id;
                        votingPower = o.votingPower;
                    };
                },
            )
            |> Iter.toArray(_);
            owners;
        };

        public func setFavoriteTeam(userId : Principal, teamId : Nat) : Types.SetUserFavoriteTeamResult {
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

        public func addTeamOwner(request : Types.AddTeamOwnerRequest) : Types.AddTeamOwnerResult {
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
        public func awardPoints(awards : [Types.AwardPointsRequest]) {
            for (award in Iter.fromArray(awards)) {
                updateUser(
                    award.userId,
                    func(user : Types.User) : Types.User = {
                        user with
                        points = user.points + award.points;
                    },
                );
            };
        };

        private func updateUser(userId : Principal, f : (Types.User) -> Types.User) {
            let userInfo = getUserInfoInternal(userId);
            let newUserInfo = f(userInfo);
            users.put(userId, newUserInfo);
        };

        private func getUserInfoInternal(userId : Principal) : Types.User {
            switch (users.get(userId)) {
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

    };

    private func buildUserMap(users : [User]) : HashMap.HashMap<Principal, User> {
        users.vals()
        |> Iter.map<User, (Principal, User)>(
            _,
            func(p : User) : (Principal, User) { (p.id, p) },
        )
        |> HashMap.fromIter<Principal, User>(_, users.size(), Principal.equal, Principal.hash);
    };

};
