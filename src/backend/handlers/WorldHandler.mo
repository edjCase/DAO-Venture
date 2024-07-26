import Principal "mo:base/Principal";
import Iter "mo:base/Iter";
import Buffer "mo:base/Buffer";
import Result "mo:base/Result";
import Prelude "mo:base/Prelude";
import Int "mo:base/Int";
import World "../models/World";
module {
    public type StableData = {
        progenitor : Principal;
        locations : [World.WorldLocationWithoutId];
    };

    type MutableWorldLocation = {
        var townId : ?Nat;
        resources : {
            gold : MutableGoldResourceInfo;
            wood : MutableWoodResourceInfo;
            food : MutableFoodResourceInfo;
            stone : MutableStoneResourceInfo;
        };
    };

    public type MutableGoldResourceInfo = {
        var difficulty : Nat;
    };

    public type MutableWoodResourceInfo = {
        var amount : Nat;
    };

    public type MutableFoodResourceInfo = {
        var amount : Nat;
    };

    public type MutableStoneResourceInfo = {
        var difficulty : Nat;
    };

    private func toMutableWorldLocation(location : World.WorldLocationWithoutId) : MutableWorldLocation {
        {
            var townId = location.townId;
            resources = {
                gold = { var difficulty = location.resources.gold.difficulty };
                wood = { var amount = location.resources.wood.amount };
                food = { var amount = location.resources.food.amount };
                stone = { var difficulty = location.resources.stone.difficulty };
            };
        };
    };

    private func fromMutableWorldLocation(location : MutableWorldLocation) : World.WorldLocationWithoutId {
        {
            townId = location.townId;
            resources = {
                gold = { difficulty = location.resources.gold.difficulty };
                wood = { amount = location.resources.wood.amount };
                food = { amount = location.resources.food.amount };
                stone = { difficulty = location.resources.stone.difficulty };
            };
        };
    };

    public class Handler(stableData : StableData) {
        public let progenitor = stableData.progenitor;

        var locations = stableData.locations.vals()
        |> Iter.map<World.WorldLocationWithoutId, MutableWorldLocation>(
            _,
            toMutableWorldLocation,
        )
        |> Buffer.fromIter<MutableWorldLocation>(_);

        public func toStableData() : StableData {
            {
                progenitor = progenitor;
                locations = locations.vals()
                |> Iter.map<MutableWorldLocation, World.WorldLocationWithoutId>(
                    _,
                    fromMutableWorldLocation,
                )
                |> Iter.toArray(_);
            };
        };

        public func getLocations() : [World.WorldLocationWithoutId] {
            return locations.vals()
            |> Iter.map<MutableWorldLocation, World.WorldLocationWithoutId>(
                _,
                fromMutableWorldLocation,
            )
            |> Iter.toArray(_);
        };

        public func addResource(
            locationId : Nat,
            kind : World.ResourceKind,
            delta : Nat,
        ) : Result.Result<Nat, { #locationNotFound }> {
            switch (updateResource(locationId, kind, delta, false)) {
                case (#ok(v)) #ok(v);
                case (#err(#locationNotFound)) #err(#locationNotFound);
                case (#err(#notEnoughResource(_))) Prelude.unreachable();
            };
        };

        public func updateResource(
            locationId : Nat,
            kind : World.ResourceKind,
            delta : Int,
            allowBelowZero : Bool,
        ) : Result.Result<Nat, { #locationNotFound; #notEnoughResource : { missing : Nat } }> {
            let ?location = locations.getOpt(locationId) else return #err(#locationNotFound);
            let currentValue = switch (kind) {
                case (#food) location.resources.food.amount;
                case (#wood) location.resources.wood.amount;
                case (#gold) location.resources.gold.difficulty;
                case (#stone) location.resources.stone.difficulty;
            };
            if (delta == 0) {
                return #ok(currentValue);
            };
            let newValueInt = currentValue + delta;
            let newAmountOrDifficulty : Nat = if (newValueInt <= 0) {
                if (not allowBelowZero) {
                    return #err(#notEnoughResource({ missing = Int.abs(newValueInt) }));
                };
                // Keep min value of 0
                0;
            } else {
                Int.abs(newValueInt);
            };
            switch (kind) {
                case (#food) location.resources.food.amount := newAmountOrDifficulty;
                case (#wood) location.resources.wood.amount := newAmountOrDifficulty;
                case (#gold) location.resources.gold.difficulty := newAmountOrDifficulty;
                case (#stone) location.resources.stone.difficulty := newAmountOrDifficulty;
            };
            #ok(newAmountOrDifficulty);
        };

    };

};
