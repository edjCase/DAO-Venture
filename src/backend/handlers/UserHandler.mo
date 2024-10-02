import IterTools "mo:itertools/Iter";
import HashMap "mo:base/HashMap";
import Principal "mo:base/Principal";
import Iter "mo:base/Iter";
import Nat "mo:base/Nat";
import Order "mo:base/Order";
import Int "mo:base/Int";
import Result "mo:base/Result";
import Time "mo:base/Time";
import Array "mo:base/Array";
import Text "mo:base/Text";
import CommonTypes "../CommonTypes";

module {

    public type User = {
        id : Principal;
        createTime : Time.Time;
        points : Nat;
        achievementIds : [Text];
    };

    public type UserStats = {
        userCount : Nat;
    };

    public type StableData = {
        users : [User];
    };

    public class Handler(stableData : StableData) {
        let users : HashMap.HashMap<Principal, User> = buildUserMap(stableData.users);

        public func toStableData() : StableData {
            {
                users = users.vals() |> Iter.toArray(_);
            };
        };

        public func get(id : Principal) : ?User {
            users.get(id);
        };

        public func getAll() : [User] {
            users.vals()
            |> Iter.toArray(_);
        };

        public func getStats() : UserStats {
            {
                userCount = users.size();
            };
        };

        public func getTopUsers(count : Nat, offset : Nat) : CommonTypes.PagedResult<User> {
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
                totalCount = users.size();
            };
        };

        public func add(
            userId : Principal
        ) : Result.Result<User, { #alreadyMember }> {
            switch (users.get(userId)) {
                case (?_) #err(#alreadyMember);
                case (null) {
                    let firstUser = users.size() == 0;
                    let points = if (firstUser) {
                        100; // TODO temp to allow for voting with other testers
                    } else {
                        0;
                    };
                    let newUser : User = {
                        id = userId;
                        createTime = Time.now();
                        achievementIds = [];
                        points = points;
                    };
                    users.put(userId, newUser);
                    #ok(newUser);
                };
            };
        };

        public func unlockAchievement(
            userId : Principal,
            achievementId : Text,
        ) : Result.Result<(), { #userNotFound; #achievementNotFound; #alreadyUnlocked }> {
            switch (users.get(userId)) {
                case (null) #err(#userNotFound);
                case (?user) {
                    if (Array.indexOf(achievementId, user.achievementIds, Text.equal) != null) {
                        #err(#alreadyUnlocked);
                    } else {
                        users.put(
                            userId,
                            {
                                user with
                                achievementIds = Array.append(user.achievementIds, [achievementId]);
                            },
                        );
                        #ok;
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
