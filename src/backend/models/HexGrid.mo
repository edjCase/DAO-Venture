import HashMap "mo:base/HashMap";
import Hash "mo:base/Hash";
import Int "mo:base/Int";
import Iter "mo:base/Iter";
import Buffer "mo:base/Buffer";
import Float "mo:base/Float";
import IterTools "mo:itertools/Iter";

module {
    public type AxialCoordinate = {
        q : Int;
        r : Int;
    };

    public type CubeCoordinate = {
        x : Int;
        y : Int;
        z : Int;
    };

    public class HexGrid<T>() {

        private func axialCoordEq(a : AxialCoordinate, b : AxialCoordinate) : Bool {
            a == b;
        };
        private func axialCoordHash(coord : AxialCoordinate) : Hash.Hash {
            var hash : Nat32 = 5381;
            hash := ((hash << 5) +% hash) +% Int.hash(coord.q);
            hash := ((hash << 5) +% hash) +% Int.hash(coord.r);
            hash;
        };

        private var cells = HashMap.HashMap<AxialCoordinate, T>(1, axialCoordEq, axialCoordHash);

        private func cubeCoordEq(a : CubeCoordinate, b : CubeCoordinate) : Bool {
            a == b;
        };

        public func getValue(coord : AxialCoordinate) : ?T {
            cells.get(coord);
        };

        public func setValue(coord : AxialCoordinate, value : T) {
            cells.put(coord, value);
        };

        public func removeValue(coord : AxialCoordinate) {
            cells.delete(coord);
        };

        public func getOccupiedCoords() : Iter.Iter<(AxialCoordinate, T)> {
            cells.entries();
        };

        private func distanceBetween(a : CubeCoordinate, b : CubeCoordinate) : Int {
            (Int.abs(a.x - b.x) + Int.abs(a.y - b.y) + Int.abs(a.z - b.z)) / 2;
        };

        private func getNeighbors(coord : CubeCoordinate) : Iter.Iter<CubeCoordinate> {
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
                        x = coord.x + dir.x;
                        y = coord.y + dir.y;
                        z = coord.z + dir.z;
                    };
                },
            );
        };

        public func findPath(start : AxialCoordinate, end : AxialCoordinate) : [AxialCoordinate] {
            var path : Buffer.Buffer<CubeCoordinate> = Buffer.Buffer<CubeCoordinate>(1);
            var current : CubeCoordinate = axialToCube(start);
            let cubicEnd : CubeCoordinate = axialToCube(end);

            while (not cubeCoordEq(current, cubicEnd)) {
                path.add(current);
                let neighbors = getNeighbors(current);
                // Simple heuristic: move towards the end coordinate
                current := IterTools.fold<CubeCoordinate, CubeCoordinate>(
                    neighbors,
                    current,
                    func(acc : CubeCoordinate, neighbor : CubeCoordinate) : CubeCoordinate {
                        if (distanceBetween(neighbor, cubicEnd) < distanceBetween(acc, cubicEnd)) {
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

    // Convert axial to cube coordinates
    public func axialToCube(c : AxialCoordinate) : CubeCoordinate {
        let x = c.q;
        let z = c.r;
        let y = -x - z;
        { x = x; y = y; z = z };
    };

    // Convert cube to axial coordinates
    public func cubeToAxial(cube : CubeCoordinate) : AxialCoordinate = {
        q = cube.x;
        r = cube.z;
    };

    let neighbors = [
        { q = 0; r = -1 },
        { q = 1; r = -1 },
        { q = 1; r = 0 },
        { q = 0; r = 1 },
        { q = -1; r = 1 },
        { q = -1; r = 0 },
    ];
    // https://www.redblobgames.com/grids/hexagons/

    public func indexToAxialCoord(index : Nat) : AxialCoordinate {
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
};
