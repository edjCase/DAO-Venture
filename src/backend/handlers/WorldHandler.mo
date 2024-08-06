import Principal "mo:base/Principal";
import Iter "mo:base/Iter";
import Result "mo:base/Result";
import HashMap "mo:base/HashMap";
import Nat "mo:base/Nat";
import Nat32 "mo:base/Nat32";
import Debug "mo:base/Debug";
import Time "mo:base/Time";
import World "../models/World";
import PseudoRandomX "mo:xtended-random/PseudoRandomX";
import WorldGenerator "../WorldGenerator";
import HexGrid "../models/HexGrid";
import TimeUtil "../TimeUtil";

module {
    type Prng = PseudoRandomX.PseudoRandomGenerator;

    public type StableData = {
        genesisTime : Time.Time;
        progenitor : Principal;
        locations : [World.WorldLocation];
    };

    public type WorldAgeInfo = {
        genesisTime : Time.Time;
        daysElapsed : Nat;
        nextDayStartTime : Nat;
    };

    type MutableWorldLocation = {
        id : Nat;
        coordinate : HexGrid.AxialCoordinate;
        var kind : MutableLocationKind;
    };

    type MutableLocationKind = {
        #unexplored : MutableUnexploredLocation;
        #resource : MutableResourceLocation;
        #town : MutableTownLocation;
    };

    type MutableTownLocation = {
        var townId : Nat;
    };

    type MutableUnexploredLocation = {
        var currentExploration : Nat;
        explorationNeeded : Nat;
    };

    type MutableResourceLocation = {
        var rarity : World.ResourceRarity;
        kind : World.ResourceKind;
        claimedByTownIds : HashMap.HashMap<Nat, ()>;
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
            case (#resource(r)) #resource({
                kind = r.kind;
                var rarity = r.rarity;
                claimedByTownIds = r.claimedByTownIds.vals()
                |> Iter.map<Nat, (Nat, ())>(_, func(a : Nat) : (Nat, ()) = (a, ()))
                |> HashMap.fromIter(_, r.claimedByTownIds.size(), Nat.equal, Nat32.fromNat);
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
            case (#unexplored(u)) #unexplored({
                currentExploration = u.currentExploration;
                explorationNeeded = u.explorationNeeded;
            });
            case (#resource(r)) #resource({
                kind = r.kind;
                rarity = r.rarity;
                claimedByTownIds = Iter.toArray(r.claimedByTownIds.keys());
            });
            case (#town(t)) #town({ townId = t.townId });
        };
    };

    public class Handler(stableData : StableData) {
        public let progenitor = stableData.progenitor;

        let locations : HashMap.HashMap<Nat, MutableWorldLocation> = stableData.locations.vals()
        |> Iter.map<World.WorldLocation, (Nat, MutableWorldLocation)>(
            _,
            func(a) = (a.id, toMutableWorldLocation(a)),
        )
        |> HashMap.fromIter<Nat, MutableWorldLocation>(_, stableData.locations.size(), Nat.equal, Nat32.fromNat);

        public func toStableData() : StableData {
            {
                genesisTime = stableData.genesisTime;
                progenitor = progenitor;
                locations = locations.vals()
                |> Iter.map<MutableWorldLocation, World.WorldLocation>(
                    _,
                    fromMutableWorldLocation,
                )
                |> Iter.toArray(_);
            };
        };

        public func getAgeInfo() : WorldAgeInfo {
            let { days; nextDayStartTime } = TimeUtil.getAge(stableData.genesisTime);
            {
                genesisTime = stableData.genesisTime;
                daysElapsed = days;
                nextDayStartTime = nextDayStartTime;
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
                        switch (revealLocation(prng, locationId, null)) {
                            case (#ok(_)) #ok(#complete);
                            case (#err(err)) #err(err);
                        };
                    } else {
                        #ok(#incomplete);
                    };
                };
                case (_) return #err(#locationAlreadyExplored);
            };
        };

        public func revealLocation(prng : Prng, locationId : Nat, claimedByTownId : ?Nat) : Result.Result<World.WorldLocation, { #locationNotFound; #locationAlreadyExplored }> {
            let ?location = locations.get(locationId) else return #err(#locationNotFound);
            switch (location.kind) {
                case (#unexplored(_)) {
                    Debug.print("Revealing location " # Nat.toText(locationId));
                    location.kind := toMutableLocationKind(WorldGenerator.generateLocationKind(prng, location.id, true, claimedByTownId));
                    #ok(fromMutableWorldLocation(location));
                };
                case (_) #err(#locationAlreadyExplored);
            };
        };

        public func claimLocation(
            locationId : Nat,
            townId : Nat,
        ) : Result.Result<(), { #locationNotFound; #cannotClaim }> {
            let ?location = locations.get(locationId) else return #err(#locationNotFound);
            switch (location.kind) {
                case (#resource(resource)) {
                    resource.claimedByTownIds.put(townId, ());
                    #ok;
                };
                case (#town(_) or #unexplored(_)) return #err(#cannotClaim);
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

        public func addTown(prng : Prng, locationId : Nat, townId : Nat) : Result.Result<(), { #locationNotFound; #otherTownAtLocation : Nat }> {
            let ?location = locations.get(locationId) else return #err(#locationNotFound);
            switch (location.kind) {
                case (#town(townLocation)) return #err(#otherTownAtLocation(townLocation.townId));
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
                    revealNeighbors(prng, location, 1, townId);
                };
            };
            #ok;
        };

        private func revealNeighbors(prng : Prng, location : MutableWorldLocation, depthRemaining : Nat, revealingTownId : Nat) {
            // TODO do some procdeural generation of town resources so that
            // the town has some resources to start with of all important types
            let surroundingLocations = HexGrid.getNeighbors(location.coordinate);
            label f for (neighbor in surroundingLocations) {
                let neighborLocationId = HexGrid.axialCoordinateToIndex(neighbor);
                switch (revealLocation(prng, neighborLocationId, ?revealingTownId)) {
                    case (#ok(_)) ();
                    case (#err(#locationNotFound)) continue f; // Skip non-existent locations
                    case (#err(#locationAlreadyExplored)) (); // Skip already explored locations
                };
                if (depthRemaining > 0) {
                    let ?neighborLocation = locations.get(neighborLocationId) else Debug.trap("Location not found: " # Nat.toText(neighborLocationId));
                    // TODO optimize not to reveal neighbors of neighbors that are already revealed
                    revealNeighbors(prng, neighborLocation, depthRemaining - 1, revealingTownId);
                };
            };
        };

    };

};
