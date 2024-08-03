import HashMap "mo:base/HashMap";
import Hash "mo:base/Hash";
import Int "mo:base/Int";
import Iter "mo:base/Iter";
import Buffer "mo:base/Buffer";
import Float "mo:base/Float";
import Nat32 "mo:base/Nat32";
import Nat "mo:base/Nat";
import Prelude "mo:base/Prelude";
import Debug "mo:base/Debug";
import IterTools "mo:itertools/Iter";

// https://www.redblobgames.com/grids/hexagons/

module {
    public type AxialCoordinate = {
        q : Int;
        r : Int;
    };

    type CubeCoordinate = {
        x : Int;
        y : Int;
        z : Int;
    };

    public class HexGrid<T>() {

        private var cells = HashMap.HashMap<AxialCoordinate, T>(1, axialCoordinateEq, axialCoordinateHash);

        private func cubeCoordEq(a : CubeCoordinate, b : CubeCoordinate) : Bool {
            a == b;
        };

        public func getValue(coordinate : AxialCoordinate) : ?T {
            cells.get(coordinate);
        };

        public func setValue(coordinate : AxialCoordinate, value : T) {
            cells.put(coordinate, value);
        };

        public func removeValue(coordinate : AxialCoordinate) {
            cells.delete(coordinate);
        };

        public func getOccupiedCoords() : Iter.Iter<(AxialCoordinate, T)> {
            cells.entries();
        };

        public func findPath(start : AxialCoordinate, end : AxialCoordinate) : [AxialCoordinate] {
            var path : Buffer.Buffer<CubeCoordinate> = Buffer.Buffer<CubeCoordinate>(1);
            var current : CubeCoordinate = axialToCube(start);
            let cubicEnd : CubeCoordinate = axialToCube(end);

            while (not cubeCoordEq(current, cubicEnd)) {
                path.add(current);
                let neighbors = getNeighborsCube(current);
                // Simple heuristic: move towards the end coordinate
                current := IterTools.fold<CubeCoordinate, CubeCoordinate>(
                    neighbors,
                    current,
                    func(acc : CubeCoordinate, neighbor : CubeCoordinate) : CubeCoordinate {
                        if (distanceBetweenCube(neighbor, cubicEnd) < distanceBetweenCube(acc, cubicEnd)) {
                            neighbor;
                        } else {
                            acc;
                        };
                    },
                );
            };
            path.add(cubicEnd);
            path.vals()
            |> Iter.map(
                _,
                cubeToAxial,
            )
            |> Iter.toArray(_);
        };

    };

    private func axialCoordinateEq(a : AxialCoordinate, b : AxialCoordinate) : Bool {
        a == b;
    };
    private func axialCoordinateHash(coordinate : AxialCoordinate) : Hash.Hash {
        var hash : Nat32 = 5381;
        hash := ((hash << 5) +% hash) +% Nat32.fromNat(Int.abs(coordinate.q));
        hash := ((hash << 5) +% hash) +% Nat32.fromNat(Int.abs(coordinate.r));
        hash;
    };

    public func distanceBetween(a : AxialCoordinate, b : AxialCoordinate) : Int {
        distanceBetweenCube(axialToCube(a), axialToCube(b));
    };

    public func distanceBetweenIndex(a : Nat, b : Nat) : Int {
        distanceBetween(indexToAxialCoordinate(a), indexToAxialCoordinate(b));
    };

    private func distanceBetweenCube(a : CubeCoordinate, b : CubeCoordinate) : Int {
        (Int.abs(a.x - b.x) + Int.abs(a.y - b.y) + Int.abs(a.z - b.z)) / 2;
    };

    public func areAdjacent(a : AxialCoordinate, b : AxialCoordinate) : Bool {
        areAdjacentCube(axialToCube(a), axialToCube(b));
    };

    private func areAdjacentCube(a : CubeCoordinate, b : CubeCoordinate) : Bool {
        distanceBetweenCube(a, b) == 1;
    };

    // Convert axial to cube coordinates
    public func axialToCube(axial : AxialCoordinate) : CubeCoordinate {
        let x = axial.q;
        let z = axial.r;
        let y = -x - z;
        { x = x; y = y; z = z };
    };

    // Convert cube to axial coordinates
    public func cubeToAxial(cube : CubeCoordinate) : AxialCoordinate = {
        q = cube.x;
        r = cube.z;
    };

    let neighbors = [
        { q = 0; r = -1 }, // Up
        { q = 1; r = -1 }, // Up-right
        { q = 1; r = 0 }, // Down-right
        { q = 0; r = 1 }, // Down
        { q = -1; r = 1 }, // Down-left
        { q = -1; r = 0 } // Up-left
    ];

    public func indexToAxialCoordinate(index : Nat) : AxialCoordinate {
        if (index == 0) {
            return { q = 0; r = 0 };
        };

        // https://stackoverflow.com/a/77540107
        let float_index = Float.fromInt(index);
        // n is the layer/ring index around the center (0 being the center)
        let n : Nat = Int.abs(Float.toInt(Float.ceil(((Float.sqrt(12.0 * float_index + 1) - 3.0) / 6.0))));

        let position : Nat = (index - 3 * n * (n - 1) - 1) % (6 * n);
        let direction : Nat = position / n; // 0 is up, 1 is up-right, 2 is down-right, etc.
        let firstSideNeighbor = neighbors[direction]; // The direction we're moving out to first
        let secondSideNeighbor = neighbors[(direction + 2) % 6]; // Then move down the offset

        let firstSideJumps = n;
        let secondSideJumps = (position % n); // How many steps we need to take in the second direction

        {
            q = firstSideNeighbor.q * firstSideJumps + secondSideNeighbor.q * secondSideJumps;
            r = firstSideNeighbor.r * firstSideJumps + secondSideNeighbor.r * secondSideJumps;
        };
    };

    public func axialCoordinateToIndex(coordinate : AxialCoordinate) : Nat {
        let { q; r } = coordinate;

        if (q == 0 and r == 0) {
            return 0;
        };

        // Calculate the ring number
        let ring : Nat = Nat.max(Int.abs(q), Nat.max(Int.abs(r), Int.abs(-q - r)));

        // Calculate the base index for this ring
        let ringStart : Nat = 3 * ring * (ring - 1) + 1;

        // Determine which side of the hexagon we're on
        let (side, offset) : (Nat, Int) = if (q == 0) {
            if (r < 0) {
                (0, 0); // Up
            } else if (r == 0) {
                return 0; // Center
            } else {
                (3, 0); // Down
            };
        } else if (r == 0) {
            if (q > 0) {
                (2, 0); // Down-right
            } else {
                (5, 0); // Up-left
            };
        } else if (q + r == 0) {
            if (q > 0) {
                (1, 0); // Up-right
            } else {
                (4, 0); // Down-left
            };
        } else {
            if (q > 0) {
                if (r < 0) {
                    if (q > -r) {
                        (1, q + r); // Up-right with offset
                    } else {
                        (0, q); // Up with offset
                    };
                } else {
                    (2, r); // Down-right with offset
                };
            } else {
                if (r < 0) {
                    (5, -r); // Up-left with offset
                } else {
                    if (q > -r) {
                        (3, -q); // Down with offset
                    } else {
                        (4, q + r); //Down-left with offset
                    };
                };
            };
        };

        // Calculate the position on the side

        ringStart + side * ring + Int.abs(offset);
    };

    public func getNeighbors(coordinate : AxialCoordinate) : Iter.Iter<AxialCoordinate> {
        getNeighborsCube(axialToCube(coordinate))
        |> Iter.map(
            _,
            cubeToAxial,
        );
    };

    private func getNeighborsCube(coordinate : CubeCoordinate) : Iter.Iter<CubeCoordinate> {
        [
            { x = 1; y = -1; z = 0 },
            { x = 1; y = 0; z = -1 },
            { x = 0; y = 1; z = -1 },
            { x = -1; y = 1; z = 0 },
            { x = -1; y = 0; z = 1 },
            { x = 0; y = -1; z = 1 },
        ]
        |> Iter.fromArray(_)
        |> Iter.map(
            _,
            func(dir : CubeCoordinate) : CubeCoordinate {
                {
                    x = coordinate.x + dir.x;
                    y = coordinate.y + dir.y;
                    z = coordinate.z + dir.z;
                };
            },
        );
    };
};
