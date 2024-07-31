import Principal "mo:base/Principal";
import Iter "mo:base/Iter";
import Result "mo:base/Result";
import Prelude "mo:base/Prelude";
import Int "mo:base/Int";
import HashMap "mo:base/HashMap";
import Nat "mo:base/Nat";
import Nat32 "mo:base/Nat32";
import Debug "mo:base/Debug";
import World "../models/World";
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
        var kind : MutableLocationKind;
    };

    type MutableLocationKind = {
        #unexplored : MutableUnexploredLocation;
        #standard : MutableStandardLocation;
    };

    type MutableUnexploredLocation = {
        var currentExploration : Nat;
        explorationNeeded : Nat;
    };

    type MutableStandardLocation = {
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
            var kind = toMutableLocationKind(location.kind);
        };
    };

    private func toMutableLocationKind(kind : World.LocationKind) : MutableLocationKind {
        switch (kind) {
            case (#unexplored(u)) #unexplored({
                var currentExploration = u.currentExploration;
                explorationNeeded = u.explorationNeeded;
            });
            case (#standard(s)) #standard({
                var townId = s.townId;
                resources = {
                    gold = {
                        var difficulty = s.resources.gold.difficulty;
                    };
                    wood = { var amount = s.resources.wood.amount };
                    food = { var amount = s.resources.food.amount };
                    stone = {
                        var difficulty = s.resources.stone.difficulty;
                    };
                };
            });
        };
    };

    private func fromMutableWorldLocation(location : MutableWorldLocation) : World.WorldLocation {
        {
            id = location.id;
            coordinate = location.coordinate;
            kind = fromMutableLocationKind(location.kind);
        };
    };

    private func fromMutableLocationKind(kind : MutableLocationKind) : World.LocationKind {
        switch (kind) {
            case (#unexplored(u)) #unexplored({
                currentExploration = u.currentExploration;
                explorationNeeded = u.explorationNeeded;
            });
            case (#standard(s)) #standard({
                townId = s.townId;
                resources = {
                    gold = { difficulty = s.resources.gold.difficulty };
                    wood = { amount = s.resources.wood.amount };
                    food = { amount = s.resources.food.amount };
                    stone = { difficulty = s.resources.stone.difficulty };
                };
            });
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

        public func exploreLocation(
            prng : Prng,
            locationId : Nat,
            amount : Nat,
        ) : Result.Result<{ #incomplete; #complete }, { #locationAlreadyExplored; #locationNotFound }> {
            let ?location = locations.get(locationId) else return #err(#locationNotFound);
            switch (location.kind) {
                case (#unexplored(unexplored)) {
                    Debug.print("Exploring location " # Nat.toText(locationId) # " by " # Nat.toText(amount));
                    unexplored.currentExploration += amount;
                    if (unexplored.currentExploration >= unexplored.explorationNeeded) {
                        Debug.print("Location " # Nat.toText(locationId) # " fully explored");
                        location.kind := toMutableLocationKind(WorldGenerator.generateLocationKind(prng, location.id, true));
                        #ok(#complete);
                    } else {
                        #ok(#incomplete);
                    };
                };
                case (_) return #err(#locationAlreadyExplored);
            };
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
            switch (updateResource(locationId, kind, delta, #ignoreNegative)) {
                case (#ok(v)) #ok(v);
                case (#err(#locationNotFound)) #err(#locationNotFound);
                case (#err(#notEnoughResource(_))) Prelude.unreachable();
            };
        };

        public func updateResource(
            locationId : Nat,
            kind : World.ResourceKind,
            delta : Int,
            behaviour : {
                #errorOnNegative : { setToZero : Bool };
                #ignoreNegative;
            },
        ) : Result.Result<Nat, { #locationNotFound; #notEnoughResource : { missing : Nat } }> {
            let ?location = locations.get(locationId) else return #err(#locationNotFound);

            let standardLocation = switch (location.kind) {
                case (#unexplored(_)) return #err(#locationNotFound); // TODO better error?
                case (#standard(standardLocation)) standardLocation;
            };
            let currentValue = switch (kind) {
                case (#food) standardLocation.resources.food.amount;
                case (#wood) standardLocation.resources.wood.amount;
                case (#gold) standardLocation.resources.gold.difficulty;
                case (#stone) standardLocation.resources.stone.difficulty;
            };
            if (delta == 0) {
                return #ok(currentValue);
            };

            let updateResource = func(kind : World.ResourceKind, newAmountOrDifficulty : Nat) {
                Debug.print("Updating resource " # debug_show (kind) # " at location " # Nat.toText(locationId) # " by " # Int.toText(delta) # " to " # Nat.toText(newAmountOrDifficulty));
                switch (kind) {
                    case (#food) standardLocation.resources.food.amount := newAmountOrDifficulty;
                    case (#wood) standardLocation.resources.wood.amount := newAmountOrDifficulty;
                    case (#gold) standardLocation.resources.gold.difficulty := newAmountOrDifficulty;
                    case (#stone) standardLocation.resources.stone.difficulty := newAmountOrDifficulty;
                };
            };

            let newValueInt = currentValue + delta;
            let newAmountOrDifficulty : Nat = if (newValueInt <= 0) {
                switch (behaviour) {
                    case (#errorOnNegative({ setToZero })) {
                        if (setToZero) {
                            updateResource(kind, 0);
                        };
                        return #err(#notEnoughResource({ missing = Int.abs(newValueInt) }));
                    };
                    case (#ignoreNegative) 0; // Keep min value of 0
                };
            } else {
                Int.abs(newValueInt);
            };
            updateResource(kind, newAmountOrDifficulty);
            #ok(newAmountOrDifficulty);
        };

        public func addTown(locationId : Nat, townId : Nat) : Result.Result<(), { #locationNotFound; #otherTownAtLocation : Nat }> {
            let ?location = locations.get(locationId) else return #err(#locationNotFound);
            let standardLocation = switch (location.kind) {
                case (#unexplored(_)) return #err(#locationNotFound); // TODO better error?
                case (#standard(standardLocation)) standardLocation;
            };
            switch (standardLocation.townId) {
                case (?townId) return #err(#otherTownAtLocation(townId));
                case (null) standardLocation.townId := ?townId;
            };
            #ok;
        };

    };

};
