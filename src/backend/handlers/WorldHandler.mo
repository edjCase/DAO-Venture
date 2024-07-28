import Principal "mo:base/Principal";
import Iter "mo:base/Iter";
import Result "mo:base/Result";
import Prelude "mo:base/Prelude";
import Int "mo:base/Int";
import HashMap "mo:base/HashMap";
import Nat "mo:base/Nat";
import Nat32 "mo:base/Nat32";
import World "../models/World";
import IterTools "mo:itertools/Iter";
import PseudoRandomX "mo:xtended-random/PseudoRandomX";
import WorldGenerator "../WorldGenerator";
import HexGrid "../models/HexGrid";

module {
    type Prng = PseudoRandomX.PseudoRandomGenerator;

    public type StableData = {
        progenitor : Principal;
        locations : [World.WorldLocation];
    };

    type MutableWorldLocation = {
        id : Nat;
        coordinate : HexGrid.AxialCoordinate;
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

    private func toMutableWorldLocation(location : World.WorldLocation) : MutableWorldLocation {
        {
            id = location.id;
            coordinate = location.coordinate;
            var townId = location.townId;
            resources = {
                gold = { var difficulty = location.resources.gold.difficulty };
                wood = { var amount = location.resources.wood.amount };
                food = { var amount = location.resources.food.amount };
                stone = { var difficulty = location.resources.stone.difficulty };
            };
        };
    };

    private func fromMutableWorldLocation(location : MutableWorldLocation) : World.WorldLocation {
        {
            id = location.id;
            coordinate = location.coordinate;
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

        let locations = stableData.locations.vals()
        |> Iter.map<World.WorldLocation, (Nat, MutableWorldLocation)>(
            _,
            func(a) = (a.id, toMutableWorldLocation(a)),
        )
        |> HashMap.fromIter<Nat, MutableWorldLocation>(_, stableData.locations.size(), Nat.equal, Nat32.fromNat);

        public func toStableData() : StableData {
            {
                progenitor = progenitor;
                locations = locations.vals()
                |> Iter.map<MutableWorldLocation, World.WorldLocation>(
                    _,
                    fromMutableWorldLocation,
                )
                |> Iter.toArray(_);
            };
        };

        public func exploreLocation(prng : Prng, locationId : Nat) : Result.Result<World.WorldLocation, { #locationAlreadyExplored; #noAdjacentLocationExplored }> {
            let null = locations.get(locationId) else return #err(#locationAlreadyExplored);
            let locationCoordinate = HexGrid.indexToAxialCoordinate(locationId);
            let anyAdjacentExplored = locations.keys()
            |> Iter.map<Nat, HexGrid.AxialCoordinate>(_, HexGrid.indexToAxialCoordinate)
            |> IterTools.any<HexGrid.AxialCoordinate>(_, func(c) = HexGrid.areAdjacent(locationCoordinate, c));
            if (not anyAdjacentExplored) {
                return #err(#noAdjacentLocationExplored);
            };
            let newLocation = WorldGenerator.generateLocation(prng, locationId);

            #ok(newLocation);
        };

        public func getLocations() : HashMap.HashMap<Nat, World.WorldLocation> {
            return locations.entries()
            |> Iter.map<(Nat, MutableWorldLocation), (Nat, World.WorldLocation)>(
                _,
                func(a) = (a.0, fromMutableWorldLocation(a.1)),
            )
            |> HashMap.fromIter<Nat, World.WorldLocation>(_, locations.size(), Nat.equal, Nat32.fromNat);
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
            let ?location = locations.get(locationId) else return #err(#locationNotFound);
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

        public func addTown(locationId : Nat, townId : Nat) : Result.Result<(), { #locationNotFound; #otherTownAtLocation : Nat }> {
            let ?location = locations.get(locationId) else return #err(#locationNotFound);
            switch (location.townId) {
                case (?townId) return #err(#otherTownAtLocation(townId));
                case (null) location.townId := ?townId;
            };
            #ok;
        };

    };

};
