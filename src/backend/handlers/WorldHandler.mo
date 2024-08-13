import Principal "mo:base/Principal";
import Iter "mo:base/Iter";
import Result "mo:base/Result";
import HashMap "mo:base/HashMap";
import Nat "mo:base/Nat";
import Nat32 "mo:base/Nat32";
import Debug "mo:base/Debug";
import Buffer "mo:base/Buffer";
import PseudoRandomX "mo:xtended-random/PseudoRandomX";
import WorldGenerator "../WorldGenerator";
import HexGrid "../models/HexGrid";
import Location "../models/Location";

module {
    type Prng = PseudoRandomX.PseudoRandomGenerator;

    public type StableData = {
        turn : Nat;
        progenitor : Principal;
        locations : [Location.Location];
    };

    type MutableLocation = {
        id : Nat;
        coordinate : HexGrid.AxialCoordinate;
        var kind : Location.LocationKind;
    };

    private func toMutableLocation(location : Location.Location) : MutableLocation {
        {
            id = location.id;
            coordinate = location.coordinate;
            var kind = location.kind;
        };
    };

    private func fromMutableLocation(location : MutableLocation) : Location.Location {
        {
            id = location.id;
            coordinate = location.coordinate;
            kind = location.kind;
        };
    };

    public class Handler(stableData : StableData) {
        public let progenitor = stableData.progenitor;

        let locations : HashMap.HashMap<Nat, MutableLocation> = stableData.locations.vals()
        |> Iter.map<Location.Location, (Nat, MutableLocation)>(
            _,
            func(a) = (a.id, toMutableLocation(a)),
        )
        |> HashMap.fromIter<Nat, MutableLocation>(_, stableData.locations.size(), Nat.equal, Nat32.fromNat);

        var turn = stableData.turn;

        public func toStableData() : StableData {
            {
                turn = turn;
                progenitor = progenitor;
                locations = locations.vals()
                |> Iter.map<MutableLocation, Location.Location>(
                    _,
                    fromMutableLocation,
                )
                |> Iter.toArray(_);
            };
        };

        public func getTurn() : Nat {
            turn;
        };

        public func exploreLocation(
            prng : Prng,
            locationId : Nat,
            scenarioGenerator : (Prng) -> Nat,
        ) : Result.Result<(), { #locationAlreadyExplored; #locationNotFound }> {
            let ?location = locations.get(locationId) else return #err(#locationNotFound);
            switch (location.kind) {
                case (#unexplored) {
                    switch (revealLocation(prng, locationId, scenarioGenerator)) {
                        case (#ok(_)) #ok;
                        case (#err(err)) #err(err);
                    };
                };
                case (_) return #err(#locationAlreadyExplored);
            };
        };

        public func revealLocation(
            prng : Prng,
            locationId : Nat,
            scenarioGenerator : (Prng) -> Nat,
        ) : Result.Result<Location.Location, { #locationNotFound; #locationAlreadyExplored }> {
            let ?location = locations.get(locationId) else return #err(#locationNotFound);
            switch (location.kind) {
                case (#unexplored(_)) {
                    Debug.print("Revealing location " # Nat.toText(locationId));
                    location.kind := WorldGenerator.generateLocationKind(prng, scenarioGenerator);
                    #ok(fromMutableLocation(location));
                };
                case (_) #err(#locationAlreadyExplored);
            };
        };

        public func getLocations() : HashMap.HashMap<Nat, Location.Location> {
            return locations.entries()
            |> Iter.map<(Nat, MutableLocation), (Nat, Location.Location)>(
                _,
                func(a) = (a.0, fromMutableLocation(a.1)),
            )
            |> HashMap.fromIter<Nat, Location.Location>(_, locations.size(), Nat.equal, Nat32.fromNat);
        };

        public func getLocation(locationId : Nat) : ?Location.Location {
            let ?location = locations.get(locationId) else return null;
            ?fromMutableLocation(location);
        };

        private func revealNeighbors(
            prng : Prng,
            location : MutableLocation,
            scenarioGenerator : (Prng) -> Nat,
            depthRemaining : Nat,
        ) {
            // TODO do some procdeural generation of town resources so that
            // the town has some resources to start with of all important types
            let surroundingLocations = HexGrid.getNeighbors(location.coordinate);

            let neighborLocationIds = Buffer.Buffer<Nat>(6);
            label f for (neighbor in surroundingLocations) {
                let neighborLocationId = HexGrid.axialCoordinateToIndex(neighbor);
                switch (revealLocation(prng, neighborLocationId, scenarioGenerator)) {
                    case (#ok(_)) ();
                    case (#err(#locationNotFound)) continue f; // Skip non-existent locations
                    case (#err(#locationAlreadyExplored)) (); // Skip already explored locations
                };
                neighborLocationIds.add(neighborLocationId);
            };
            for (neighborLocationId in neighborLocationIds.vals()) {
                if (depthRemaining > 0) {
                    let ?neighborLocation = locations.get(neighborLocationId) else Debug.trap("Location not found: " # Nat.toText(neighborLocationId));
                    // TODO optimize not to reveal neighbors of neighbors that are already revealed
                    // Only 'claim' the immediate neighbors of the town, but reveal one level past
                    revealNeighbors(prng, neighborLocation, scenarioGenerator, depthRemaining - 1);
                };
            };
        };

    };

};
