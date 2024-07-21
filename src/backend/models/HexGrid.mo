import HashMap "mo:base/HashMap";
import Hash "mo:base/Hash";
import Int "mo:base/Int";
import Iter "mo:base/Iter";
import Buffer "mo:base/Buffer";
import Prelude "mo:base/Prelude";
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

    public func indexToAxialCoord(index : Nat) : AxialCoordinate {
        if (index == 0) {
            return { q = 0; r = 0 };
        };

        let indexFloat : Float = Float.fromInt(index);
        let ring : Int = Int.abs(Float.toInt(Float.floor((Float.sqrt(12.0 * indexFloat - 3.0) + 3.0) / 6.0)));
        let ringStart : Int = 3 * ring * (ring - 1) + 1;
        let position : Int = index - ringStart;
        let side : Int = position / ring;
        let offset : Int = position % ring;

        var q : Int = 0;
        var r : Int = 0;

        switch (side) {
            case 0 {
                // top
                q := -ring + offset + 1;
                r := -offset - 1;
            };
            case 1 {
                // top-right
                q := offset + 1;
                r := -ring;
            };
            case 2 {
                // bottom-right
                q := ring;
                r := -ring + offset + 1;
            };
            case 3 {
                // bottom
                q := ring - offset - 1;
                r := offset + 1;
            };
            case 4 {
                // bottom-left
                q := -offset - 1;
                r := ring;
            };
            case 5 {
                // top-left
                q := -ring;
                r := ring - offset - 1;
            };
            case _ Prelude.unreachable();
        };

        { q = q; r = r };
    };
};
