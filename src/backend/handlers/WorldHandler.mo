import Principal "mo:base/Principal";
import Iter "mo:base/Iter";
import Result "mo:base/Result";
import Int "mo:base/Int";
import HashMap "mo:base/HashMap";
import Nat "mo:base/Nat";
import Nat32 "mo:base/Nat32";
import Debug "mo:base/Debug";
import Float "mo:base/Float";
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

    type MutableGoldResourceInfo = {
        var efficiency : Float;
    };

    type MutableWoodResourceInfo = {
        var amount : Nat;
    };

    type MutableFoodResourceInfo = {
        var amount : Nat;
    };

    type MutableStoneResourceInfo = {
        var efficiency : Float;
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
                        var efficiency = s.resources.gold.efficiency;
                    };
                    wood = { var amount = s.resources.wood.amount };
                    food = { var amount = s.resources.food.amount };
                    stone = {
                        var efficiency = s.resources.stone.efficiency;
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
                    gold = { efficiency = s.resources.gold.efficiency };
                    wood = { amount = s.resources.wood.amount };
                    food = { amount = s.resources.food.amount };
                    stone = { efficiency = s.resources.stone.efficiency };
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

        public func getLocation(locationId : Nat) : ?World.WorldLocation {
            let ?location = locations.get(locationId) else return null;
            ?fromMutableWorldLocation(location);
        };

        public type EfficiencyResourceKind = {
            #gold;
            #stone;
        };

        public func updateEfficiencyResource(
            locationId : Nat,
            kind : EfficiencyResourceKind,
            newEfficiency : Float,
        ) : Result.Result<Float, { #locationNotFound }> {
            let ?location = locations.get(locationId) else return #err(#locationNotFound);

            let standardLocation = switch (location.kind) {
                case (#unexplored(_)) return #err(#locationNotFound); // TODO better error?
                case (#standard(standardLocation)) standardLocation;
            };

            Debug.print("Updating resource " # debug_show (kind) # " at location " # Nat.toText(locationId) # " to " # Float.toText(newEfficiency));
            switch (kind) {
                case (#gold) standardLocation.resources.gold.efficiency := newEfficiency;
                case (#stone) standardLocation.resources.stone.efficiency := newEfficiency;
            };
            #ok(newEfficiency);
        };

        public type DeterminateResourceKind = {
            #wood;
            #food;
        };

        public func updateDeterminateResource(
            locationId : Nat,
            kind : { #wood; #food },
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
                case (#food(_)) standardLocation.resources.food.amount;
                case (#wood(_)) standardLocation.resources.wood.amount;
            };
            if (delta == 0) {
                return #ok(currentValue);
            };

            let updateResource = func(kind : DeterminateResourceKind, newAmount : Nat) {
                Debug.print("Updating resource " # debug_show (kind) # " at location " # Nat.toText(locationId) # " by " # Int.toText(delta) # " to " # Nat.toText(newAmount));
                switch (kind) {
                    case (#food) standardLocation.resources.food.amount := newAmount;
                    case (#wood) standardLocation.resources.wood.amount := newAmount;
                };
            };

            let newValueInt = currentValue + delta;
            let newAmount : Nat = if (newValueInt <= 0) {
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
            updateResource(kind, newAmount);
            #ok(newAmount);
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
