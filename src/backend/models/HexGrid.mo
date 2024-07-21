import HashMap "mo:base/HashMap";
import Hash "mo:base/Hash";
import Int "mo:base/Int";
import Iter "mo:base/Iter";
import Buffer "mo:base/Buffer";
import IterTools "mo:itertools/Iter";

module {
    public type AxialCoord = {
        q : Int;
        r : Int;
    };

    type CubeCoord = {
        x : Int;
        y : Int;
        z : Int;
    };

    public class HexGrid<T>() {

        private func axialCoordEq(a : AxialCoord, b : AxialCoord) : Bool {
            a == b;
        };
        private func axialCoordHash(coord : AxialCoord) : Hash.Hash {
            var hash : Nat32 = 5381;
            hash := ((hash << 5) +% hash) +% Int.hash(coord.q);
            hash := ((hash << 5) +% hash) +% Int.hash(coord.r);
            hash;
        };

        private var cells = HashMap.HashMap<AxialCoord, T>(1, axialCoordEq, axialCoordHash);

        private func cubeCoordEq(a : CubeCoord, b : CubeCoord) : Bool {
            a == b;
        };

        public func getValue(coord : AxialCoord) : ?T {
            cells.get(coord);
        };

        public func setValue(coord : AxialCoord, value : T) {
            cells.put(coord, value);
        };

        public func removeValue(coord : AxialCoord) {
            cells.delete(coord);
        };

        public func getOccupiedCoords() : Iter.Iter<(AxialCoord, T)> {
            cells.entries();
        };

        private func distanceBetween(a : CubeCoord, b : CubeCoord) : Int {
            (Int.abs(a.x - b.x) + Int.abs(a.y - b.y) + Int.abs(a.z - b.z)) / 2;
        };

        private func getNeighbors(coord : CubeCoord) : Iter.Iter<CubeCoord> {
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
                func(dir : CubeCoord) : CubeCoord {
                    {
                        x = coord.x + dir.x;
                        y = coord.y + dir.y;
                        z = coord.z + dir.z;
                    };
                },
            );
        };

        public func findPath(start : AxialCoord, end : AxialCoord) : [AxialCoord] {
            var path : Buffer.Buffer<CubeCoord> = Buffer.Buffer<CubeCoord>(1);
            var current : CubeCoord = axialToCube(start);
            let cubicEnd : CubeCoord = axialToCube(end);

            while (not cubeCoordEq(current, cubicEnd)) {
                path.add(current);
                let neighbors = getNeighbors(current);
                // Simple heuristic: move towards the end coordinate
                current := IterTools.fold<CubeCoord, CubeCoord>(
                    neighbors,
                    current,
                    func(acc : CubeCoord, neighbor : CubeCoord) : CubeCoord {
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

        // Convert axial to cube coordinates
        public func axialToCube(c : AxialCoord) : CubeCoord {
            let x = c.q;
            let z = c.r;
            let y = -x - z;
            { x = x; y = y; z = z };
        };

        // Convert cube to axial coordinates
        public func cubeToAxial(cube : CubeCoord) : AxialCoord = {
            q = cube.x;
            r = cube.z;
        };
    };
};
