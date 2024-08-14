import Nat "mo:base/Nat";
import Buffer "mo:base/Buffer";
import Debug "mo:base/Debug";
import PseudoRandomX "mo:xtended-random/PseudoRandomX";
import Location "../models/Location";
import HexGrid "../models/HexGrid";
import IterTools "mo:itertools/Iter";

module {
    type Prng = PseudoRandomX.PseudoRandomGenerator;

    public type StableData = {
        turn : Nat;
        locations : [Location.Location];
        characterLocationId : Nat;
    };

    public class Handler(stableData : StableData) {

        let locations : Buffer.Buffer<Location.Location> = Buffer.fromArray(stableData.locations);

        var turn = stableData.turn;

        var characterLocationId = stableData.characterLocationId;

        public func toStableData() : StableData {
            {
                turn = turn;
                locations = Buffer.toArray(locations);
                characterLocationId = characterLocationId;
            };
        };

        public func getTurn() : Nat {
            turn;
        };

        public func getCharacterLocation() : Location.Location {
            let ?location = IterTools.find(
                locations.vals(),
                func(location : Location.Location) : Bool = location.id == characterLocationId,
            ) else Debug.trap("Character location not found");
            location;
        };

        public func nextTurn(nextScenarioId : Nat) {
            turn += 1;
            let currentLocation = getCharacterLocation();

            let nextCoordinate = {
                q = currentLocation.coordinate.q + 1; // Move right
                r = currentLocation.coordinate.r;
            };
            let nextLocation = {
                id = HexGrid.axialCoordinateToIndex(nextCoordinate);
                coordinate = nextCoordinate;
                scenarioId = nextScenarioId;
            };
            locations.add(nextLocation);
            characterLocationId := nextLocation.id;
        };

        public func getLocations() : [Location.Location] {
            return Buffer.toArray(locations);
        };

    };

};
