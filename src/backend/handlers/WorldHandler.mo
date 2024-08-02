import Principal "mo:base/Principal";
import Iter "mo:base/Iter";
import Result "mo:base/Result";
import Int "mo:base/Int";
import HashMap "mo:base/HashMap";
import Nat "mo:base/Nat";
import Nat32 "mo:base/Nat32";
import Debug "mo:base/Debug";
import Float "mo:base/Float";
import Prelude "mo:base/Prelude";
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
        #gold : MutableGoldLocation;
        #wood : MutableWoodLocation;
        #food : MutableFoodLocation;
        #stone : MutableStoneLocation;
        #town : MutableTownLocation;
    };

    type MutableTownLocation = {
        var townId : Nat;
    };

    type MutableUnexploredLocation = {
        var currentExploration : Nat;
        explorationNeeded : Nat;
    };

    type MutableGoldLocation = {
        var efficiency : Float;
    };

    type MutableWoodLocation = {
        var amount : Nat;
    };

    type MutableFoodLocation = {
        var amount : Nat;
    };

    type MutableStoneLocation = {
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
            case (#gold(g)) #gold({ var efficiency = g.efficiency });
            case (#wood(w)) #wood({ var amount = w.amount });
            case (#food(f)) #food({ var amount = f.amount });
            case (#stone(s)) #stone({ var efficiency = s.efficiency });
            case (#town(t)) #town({ var townId = t.townId });
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
            case (#gold(g)) #gold({ efficiency = g.efficiency });
            case (#wood(w)) #wood({ amount = w.amount });
            case (#food(f)) #food({ amount = f.amount });
            case (#stone(s)) #stone({ efficiency = s.efficiency });
            case (#town(t)) #town({ townId = t.townId });
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
            newEfficiency : Float,
        ) : Result.Result<(), { #locationNotFound }> {
            let ?location = locations.get(locationId) else return #err(#locationNotFound);

            switch (location.kind) {
                case (#gold(goldLocation)) goldLocation.efficiency := newEfficiency;
                case (#stone(stoneLocation)) stoneLocation.efficiency := newEfficiency;
                case (_) return #err(#locationNotFound); // TODO better error?
            };

            Debug.print("Updating resource " # debug_show (location.kind) # " at location " # Nat.toText(locationId) # " to " # Float.toText(newEfficiency));

            #ok;
        };

        public type DeterminateResourceKind = {
            #wood;
            #food;
        };

        public func updateDeterminateResource(
            locationId : Nat,
            delta : Int,
            behaviour : {
                #errorOnNegative : { setToZero : Bool };
                #ignoreNegative;
            },
        ) : Result.Result<Nat, { #locationNotFound; #notEnoughResource : { missing : Nat } }> {
            let ?location = locations.get(locationId) else return #err(#locationNotFound);

            let currentValue = switch (location.kind) {
                case (#wood(woodLocation)) woodLocation.amount;
                case (#food(foodLocation)) foodLocation.amount;
                case (_) return #err(#locationNotFound); // TODO better error?
            };
            if (delta == 0) {
                return #ok(currentValue);
            };

            let updateResource = func(newAmount : Nat) {
                Debug.print("Updating determinate resource at location " # Nat.toText(locationId) # " by " # Int.toText(delta) # " to " # Nat.toText(newAmount));
                switch (location.kind) {
                    case (#wood(woodLocation)) woodLocation.amount := newAmount;
                    case (#food(foodLocation)) foodLocation.amount := newAmount;
                    case (_) Prelude.unreachable();
                };
            };

            let newValueInt = currentValue + delta;
            let newAmount : Nat = if (newValueInt <= 0) {
                switch (behaviour) {
                    case (#errorOnNegative({ setToZero })) {
                        if (setToZero) {
                            updateResource(0);
                        };
                        return #err(#notEnoughResource({ missing = Int.abs(newValueInt) }));
                    };
                    case (#ignoreNegative) 0; // Keep min value of 0
                };
            } else {
                Int.abs(newValueInt);
            };
            updateResource(newAmount);
            #ok(newAmount);
        };

        public func addTown(locationId : Nat, townId : Nat) : Result.Result<(), { #locationNotFound; #otherTownAtLocation : Nat }> {
            let ?location = locations.get(locationId) else return #err(#locationNotFound);
            switch (location.kind) {
                case (#town(townLocation)) return #err(#otherTownAtLocation(townLocation.townId));
                case (#unexplored(_)) return #err(#locationNotFound);
                case (_) {
                    // Overwrite the location with a town, destroying the previous location
                    locations.put(
                        locationId,
                        {
                            id = location.id;
                            coordinate = location.coordinate;
                            var kind = #town({ var townId = townId });
                        },
                    );
                };
            };
            #ok;
        };

    };

};
