import IterTools "mo:itertools/Iter";
import HashMap "mo:base/HashMap";
import Principal "mo:base/Principal";
import Iter "mo:base/Iter";
import Nat "mo:base/Nat";
import Order "mo:base/Order";
import Int "mo:base/Int";
import Result "mo:base/Result";
import Time "mo:base/Time";
import CommonTypes "../CommonTypes";

module {

    public type User = {
        id : Principal;
        inWorldSince : Time.Time;
        level : Nat;
    };

    public type UserStats = {
        totalUserLevel : Int;
        userCount : Nat;
    };

    public type UserVotingInfo = {
        id : Principal;
        votingPower : Nat;
    };

    public type StableData = {
        users : [User];
    };

    type MutableUser = {
        id : Principal;
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
            for (user in users.vals()) {
                worldStats.totalUserLevel += user.level;
                worldStats.userCount += 1;
            };
            {
                totalUserLevel = worldStats.totalUserLevel;
                userCount = worldStats.userCount;
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

        public func add(
            userId : Principal
        ) : Result.Result<(), { #alreadyMember }> {
            switch (users.get(userId)) {
                case (?_) #err(#alreadyMember);
                case (null) {
                    let newUser : MutableUser = {
                        id = userId;
                        inWorldSince = Time.now();
                        var level = 0;
                    };
                    users.put(userId, newUser);
                    #ok;
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

    };

    private func toMutableUser(user : User) : MutableUser {
        {
            id = user.id;
            inWorldSince = user.inWorldSince;
            var level = user.level;
        };
    };

    private func fromMutableUser(user : MutableUser) : User {
        {
            id = user.id;
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
