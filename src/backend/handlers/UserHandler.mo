import IterTools "mo:itertools/Iter";
import HashMap "mo:base/HashMap";
import Principal "mo:base/Principal";
import Iter "mo:base/Iter";
import Nat "mo:base/Nat";
import Nat32 "mo:base/Nat32";
import Order "mo:base/Order";
import Int "mo:base/Int";
import Result "mo:base/Result";
import Time "mo:base/Time";
import CommonTypes "../CommonTypes";

module {

    public type User = {
        id : Principal;
        townId : Nat;
        atTownSince : Time.Time;
        inWorldSince : Time.Time;
        level : Nat;
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
        var townId : Nat;
        var atTownSince : Time.Time;
        inWorldSince : Time.Time;
        var level : Nat;
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
                let stats : TownStats = switch (townStats.get(user.townId)) {
                    case (?stats) stats;
                    case (null) {
                        {
                            id = user.townId;
                            totalUserLevel = 0;
                            userCount = 0;
                        };
                    };
                };

                let newStats : TownStats = {
                    id = user.townId;
                    totalUserLevel = stats.totalUserLevel + user.level;
                    userCount = stats.userCount + 1;
                };
                townStats.put(user.townId, newStats);

                worldStats.totalUserLevel += user.level;
                worldStats.userCount += 1;
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
                totalCount = users.size();
            };
        };

        public func getByTownId(townId : Nat) : [User] {
            users.vals()
            |> IterTools.mapFilter(
                _,
                func(user : MutableUser) : ?User {
                    if (user.townId == townId) {
                        ?fromMutableUser(user);
                    } else {
                        null;
                    };
                },
            )
            |> Iter.toArray(_);
        };

        public func addWorldMember(
            userId : Principal,
            townId : Nat,
        ) : Result.Result<(), { #alreadyWorldMember }> {
            switch (users.get(userId)) {
                case (?_) #err(#alreadyWorldMember);
                case (null) {
                    let newUser : MutableUser = {
                        id = userId;
                        var townId = townId;
                        var atTownSince = Time.now();
                        inWorldSince = Time.now();
                        var level = 0;
                    };
                    users.put(userId, newUser);
                    #ok;
                };
            };
        };

        public func changeTown(
            userId : Principal,
            townId : Nat,
        ) : Result.Result<(), { #notWorldMember }> {
            let ?user = users.get(userId) else return #err(#notWorldMember);
            user.townId := townId;
            user.atTownSince := Time.now();
            #ok;
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

    };

    private func toMutableUser(user : User) : MutableUser {
        {
            id = user.id;
            var townId = user.townId;
            var atTownSince = user.atTownSince;
            inWorldSince = user.inWorldSince;
            var level = user.level;
        };
    };

    private func fromMutableUser(user : MutableUser) : User {
        {
            id = user.id;
            townId = user.townId;
            atTownSince = user.atTownSince;
            inWorldSince = user.inWorldSince;
            level = user.level;
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
