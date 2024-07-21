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
        residency : ?UserResidency;
        level : Nat;
        currency : Nat;
    };

    public type UserResidency = {
        townId : Nat;
        votingPower : Nat;
    };

    public type UserStats = {
        totalUserLevel : Int;
        userCount : Nat;
        towns : [TownStats];
    };

    public type TownStats = {
        id : Nat;
        userCount : Nat;
        totalUserLevel : Int;
    };

    public type UserVotingInfo = {
        id : Principal;
        townId : Nat;
        votingPower : Nat;
    };

    public type StableData = {
        users : [User];
    };

    type MutableUser = {
        id : Principal;
        var residency : ?UserResidency;
        var level : Nat;
        var currency : Nat;
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
            let worldStats = {
                var totalUserLevel : Int = 0;
                var userCount = 0;
            };
            let townStats = HashMap.HashMap<Nat, TownStats>(6, Nat.equal, Nat32.fromNat);
            for (user in users.vals()) {
                switch (user.residency) {
                    case (?residency) {
                        let stats : TownStats = switch (townStats.get(residency.townId)) {
                            case (?stats) stats;
                            case (null) {
                                {
                                    id = residency.townId;
                                    totalUserLevel = 0;
                                    userCount = 0;
                                };
                            };
                        };

                        let newStats : TownStats = {
                            id = residency.townId;
                            totalUserLevel = stats.totalUserLevel + user.level;
                            userCount = stats.userCount + 1;
                        };
                        townStats.put(residency.townId, newStats);

                        worldStats.totalUserLevel += user.level;
                        worldStats.userCount += 1;

                    };
                    case (null) ();
                };
            };
            {
                totalUserLevel = worldStats.totalUserLevel;
                userCount = worldStats.userCount;
                towns = Iter.toArray<TownStats>(townStats.vals());
            };
        };

        public func getTopUsers(count : Nat, offset : Nat) : CommonTypes.PagedResult<User> {
            let orderedUsers = users.vals()
            |> IterTools.sort(
                _,
                func(u1 : MutableUser, u2 : MutableUser) : Order.Order = Int.compare(u2.level, u1.level),
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

        public func getTownOwners(townId : ?Nat) : [UserVotingInfo] {
            let getMatchingTownResidency = switch (townId) {
                case (?tId) func(residency : UserResidency) : ?Nat {
                    // Filter to only the town we want
                    if (residency.townId == tId) {
                        return ?tId;
                    };
                    return null;
                };
                case (null) func(residency : UserResidency) : ?Nat {
                    ?residency.townId;
                };
            };

            let owners = users.vals()
            |> IterTools.mapFilter(
                _,
                func(user : MutableUser) : ?UserVotingInfo {
                    let ?residency = user.residency else return null;
                    switch (getMatchingTownResidency(residency)) {
                        case (?townId) {
                            ?{
                                id = user.id;
                                townId = townId;
                                votingPower = residency.votingPower;
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

        public func addWorldMember(
            userId : Principal,
            townId : Nat,
            votingPower : Nat,
        ) : Result.Result<(), { #alreadyWorldMember }> {
            let user = getOrCreateUser(userId);
            switch (user.residency) {
                case (?_) {
                    return #err(#alreadyWorldMember);
                };
                case (null) {
                    user.residency := ?{
                        townId = townId;
                        votingPower = votingPower;
                    };
                    #ok;
                };
            };
        };

        public func changeTown(
            userId : Principal,
            townId : Nat,
        ) : Result.Result<(), { #notWorldMember }> {
            let user = getOrCreateUser(userId);
            switch (user.residency) {
                case (?residency) {
                    user.residency := ?{
                        residency with
                        townId = townId;
                    };
                    #ok;
                };
                case (null) {
                    // Add as owner
                    return #err(#notWorldMember);
                };
            };
        };

        public func awardLevels(
            userId : Principal,
            delta : Int,
        ) : Result.Result<(), { #userNotFound }> {
            let ?user = users.get(userId) else return #err(#userNotFound);
            let newLevel = user.level + delta;
            let newLevelNat = if (newLevel < 0) {
                0;
            } else {
                Int.abs(newLevel);
            };
            user.level += newLevelNat;
            #ok;
        };

        private func getOrCreateUser(userId : Principal) : MutableUser {
            switch (users.get(userId)) {
                case (?userInfo) userInfo;
                case (null) {
                    let newUser : MutableUser = {
                        id = userId;
                        var residency = null;
                        var level = 0;
                        var currency = 0;
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
            var residency = user.residency;
            var level = user.level;
            var currency = user.currency;
        };
    };

    private func fromMutableUser(user : MutableUser) : User {
        {
            id = user.id;
            residency = user.residency;
            level = user.level;
            currency = user.currency;
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
