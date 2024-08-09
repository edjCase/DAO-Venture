import Principal "mo:base/Principal";
import Iter "mo:base/Iter";
import Result "mo:base/Result";
import HashMap "mo:base/HashMap";
import Nat "mo:base/Nat";
import Nat32 "mo:base/Nat32";
import Debug "mo:base/Debug";
import Buffer "mo:base/Buffer";
import Prelude "mo:base/Prelude";
import Int "mo:base/Int";
import World "../models/World";
import PseudoRandomX "mo:xtended-random/PseudoRandomX";
import WorldGenerator "../WorldGenerator";
import HexGrid "../models/HexGrid";

module {
    type Prng = PseudoRandomX.PseudoRandomGenerator;

    public type StableData = {
        turn : Nat;
        progenitor : Principal;
        locations : [World.WorldLocation];
        daoResources : World.ResourceList;
    };

    type MutableWorldLocation = {
        id : Nat;
        coordinate : HexGrid.AxialCoordinate;
        var kind : MutableLocationKind;
    };

    type MutableLocationKind = {
        #unexplored;
        #resource : MutableResourceLocation;
        #town : MutableTownLocation;
    };

    type MutableTownLocation = {
        var townId : Nat;
    };

    type MutableResourceLocation = {
        var rarity : World.ResourceRarity;
        kind : World.ResourceKind;
    };

    type MutableResourceList = {
        var gold : Nat;
        var wood : Nat;
        var food : Nat;
        var stone : Nat;
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
            case (#unexplored) #unexplored;
            case (#resource(r)) #resource({
                kind = r.kind;
                var rarity = r.rarity;
            });
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
            case (#unexplored) #unexplored;
            case (#resource(r)) #resource({
                kind = r.kind;
                rarity = r.rarity;
            });
            case (#town(t)) #town({ townId = t.townId });
        };
    };

    public class Handler(stableData : StableData) {
        public let progenitor = stableData.progenitor;

        let daoResources : MutableResourceList = {
            var gold = stableData.daoResources.gold;
            var wood = stableData.daoResources.wood;
            var food = stableData.daoResources.food;
            var stone = stableData.daoResources.stone;
        };

        let locations : HashMap.HashMap<Nat, MutableWorldLocation> = stableData.locations.vals()
        |> Iter.map<World.WorldLocation, (Nat, MutableWorldLocation)>(
            _,
            func(a) = (a.id, toMutableWorldLocation(a)),
        )
        |> HashMap.fromIter<Nat, MutableWorldLocation>(_, stableData.locations.size(), Nat.equal, Nat32.fromNat);

        var turn = stableData.turn;

        public func toStableData() : StableData {
            {
                turn = turn;
                progenitor = progenitor;
                daoResources = {
                    gold = daoResources.gold;
                    wood = daoResources.wood;
                    food = daoResources.food;
                    stone = daoResources.stone;
                };
                locations = locations.vals()
                |> Iter.map<MutableWorldLocation, World.WorldLocation>(
                    _,
                    fromMutableWorldLocation,
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
        ) : Result.Result<(), { #locationAlreadyExplored; #locationNotFound }> {
            let ?location = locations.get(locationId) else return #err(#locationNotFound);
            switch (location.kind) {
                case (#unexplored) {
                    switch (revealLocation(prng, locationId)) {
                        case (#ok(_)) #ok;
                        case (#err(err)) #err(err);
                    };
                };
                case (_) return #err(#locationAlreadyExplored);
            };
        };

        public func revealLocation(prng : Prng, locationId : Nat) : Result.Result<World.WorldLocation, { #locationNotFound; #locationAlreadyExplored }> {
            let ?location = locations.get(locationId) else return #err(#locationNotFound);
            switch (location.kind) {
                case (#unexplored(_)) {
                    Debug.print("Revealing location " # Nat.toText(locationId));
                    location.kind := toMutableLocationKind(WorldGenerator.generateLocationKind(prng, location.id, true));
                    #ok(fromMutableWorldLocation(location));
                };
                case (_) #err(#locationAlreadyExplored);
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

        public func addResource(
            townId : Nat,
            resource : World.ResourceKind,
            amount : Nat,
        ) : Result.Result<(), { #townNotFound }> {
            switch (updateResource(townId, resource, amount, false)) {
                case (#ok) #ok;
                case (#err(#townNotFound)) #err(#townNotFound);
                case (#err(#notEnoughResource(_))) Prelude.unreachable();
            };
        };

        public func updateResource(
            townId : Nat,
            resource : World.ResourceKind,
            delta : Int,
            allowBelowZero : Bool,
        ) : Result.Result<(), { #townNotFound; #notEnoughResource : { defecit : Nat } }> {
            switch (updateResourceBulk(townId, [{ kind = resource; delta = delta }], allowBelowZero)) {
                case (#ok) #ok();
                case (#err(#townNotFound)) #err(#townNotFound);
                case (#err(#notEnoughResources(r))) #err(#notEnoughResource(r[0]));
            };
        };

        public func updateResourceBulk(
            townId : Nat,
            resources : [{
                kind : World.ResourceKind;
                delta : Int;
            }],
            allowBelowZero : Bool,
        ) : Result.Result<(), { #townNotFound; #notEnoughResources : [{ defecit : Nat; kind : World.ResourceKind }] }> {
            if (resources.size() == 0) {
                return #ok;
            };
            let newResources = Buffer.Buffer<{ kind : World.ResourceKind; delta : Int; newValue : Nat }>(resources.size());
            let notEnoughResources = Buffer.Buffer<{ defecit : Nat; kind : World.ResourceKind }>(0);
            label l for (resource in resources.vals()) {
                if (resource.delta == 0) {
                    continue l;
                };
                let currentValue = switch (resource.kind) {
                    case (#gold) daoResources.gold;
                    case (#wood) daoResources.wood;
                    case (#food) daoResources.food;
                    case (#stone) daoResources.stone;
                };
                let newResource = currentValue + resource.delta;
                if (not allowBelowZero and newResource < 0) {

                    notEnoughResources.add({
                        kind = resource.kind;
                        defecit = Int.abs(newResource);
                    });
                    continue l;
                };
                let newResourceNat = if (newResource <= 0) {
                    0;
                } else {
                    Int.abs(newResource);
                };
                newResources.add({
                    kind = resource.kind;
                    delta = resource.delta;
                    newValue = newResourceNat;
                });
            };
            if (notEnoughResources.size() > 0) {
                return #err(#notEnoughResources(Buffer.toArray(notEnoughResources)));
            };
            for (resource in newResources.vals()) {
                Debug.print("Updating resource " # debug_show (resource.kind) # " for town " # Nat.toText(townId) # " by " # Int.toText(resource.delta) # " to " # Nat.toText(resource.newValue));
                switch (resource.kind) {
                    case (#gold) {
                        daoResources.gold := resource.newValue;
                    };
                    case (#wood) {
                        daoResources.wood := resource.newValue;
                    };
                    case (#food) {
                        daoResources.food := resource.newValue;
                    };
                    case (#stone) {
                        daoResources.stone := resource.newValue;
                    };
                };
            };
            #ok;
        };

        private func revealNeighbors(prng : Prng, location : MutableWorldLocation, depthRemaining : Nat) {
            // TODO do some procdeural generation of town resources so that
            // the town has some resources to start with of all important types
            let surroundingLocations = HexGrid.getNeighbors(location.coordinate);

            let neighborLocationIds = Buffer.Buffer<Nat>(6);
            label f for (neighbor in surroundingLocations) {
                let neighborLocationId = HexGrid.axialCoordinateToIndex(neighbor);
                switch (revealLocation(prng, neighborLocationId)) {
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
                    revealNeighbors(prng, neighborLocation, depthRemaining - 1);
                };
            };
        };

    };

};
