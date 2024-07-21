import { test } "mo:test";
import Iter "mo:base/Iter";
import Debug "mo:base/Debug";
import HexGrid "../../src/backend/models/HexGrid";

test(
    "Index To Axial Coordinate",
    func() : () {
        let expectedItems : [HexGrid.AxialCoordinate] = [
            {
                q = 0;
                r = 0;
            },
            {
                q = 0;
                r = -1;
            },
            {
                q = 1;
                r = -1;
            },
            {
                q = 1;
                r = 0;
            },
            {
                q = 0;
                r = 1;
            },
            {
                q = -1;
                r = 1;
            },
            {
                q = -1;
                r = 0;
            },
            {
                q = 0;
                r = -2;
            },
            {
                q = 1;
                r = -2;
            },
            {
                q = 2;
                r = -2;
            },
            {
                q = 2;
                r = -1;
            },
            {
                q = 2;
                r = 0;
            },
            {
                q = 1;
                r = 1;
            },
            {
                q = 0;
                r = 2;
            },
            {
                q = -1;
                r = 2;
            },
            {
                q = -2;
                r = 2;
            },
            {
                q = -2;
                r = 1;
            },
            {
                q = -2;
                r = 0;
            },
            {
                q = -1;
                r = -1;
            },
            {
                q = 0;
                r = -3;
            },
            {
                q = 1;
                r = -3;
            },
            {
                q = 2;
                r = -3;
            },
            {
                q = 3;
                r = -3;
            },
            {
                q = 3;
                r = -2;
            },
            {
                q = 3;
                r = -1;
            },
            {
                q = 3;
                r = 0;
            },
            {
                q = 2;
                r = 1;
            },
            {
                q = 1;
                r = 2;
            },
            {
                q = 0;
                r = 3;
            },
            {
                q = -1;
                r = 3;
            },
            {
                q = -2;
                r = 3;
            },
            {
                q = -3;
                r = 3;
            },
            {
                q = -3;
                r = 2;
            },
            {
                q = -3;
                r = 1;
            },
            {
                q = -3;
                r = 0;
            },
            {
                q = -2;
                r = -1;
            },
            {
                q = -1;
                r = -2;
            },
            {
                q = 0;
                r = -4;
            },
            {
                q = 1;
                r = -4;
            },
            {
                q = 2;
                r = -4;
            },
            {
                q = 3;
                r = -4;
            },
            {
                q = 4;
                r = -4;
            },
            {
                q = 4;
                r = -3;
            },
            {
                q = 4;
                r = -2;
            },
            {
                q = 4;
                r = -1;
            },
            {
                q = 4;
                r = 0;
            },
            {
                q = 3;
                r = 1;
            },
            {
                q = 2;
                r = 2;
            },
            {
                q = 1;
                r = 3;
            },
            {
                q = 0;
                r = 4;
            },
            {
                q = -1;
                r = 4;
            },
            {
                q = -2;
                r = 4;
            },
            {
                q = -3;
                r = 4;
            },
            {
                q = -4;
                r = 4;
            },
            {
                q = -4;
                r = 3;
            },
            {
                q = -4;
                r = 2;
            },
            {
                q = -4;
                r = 1;
            },
            {
                q = -4;
                r = 0;
            },
            {
                q = -3;
                r = -1;
            },
            {
                q = -2;
                r = -2;
            },
            {
                q = -1;
                r = -3;
            },
        ];
        for (i in Iter.range(0, 60)) {
            let expected = expectedItems[i];
            let actual = HexGrid.indexToAxialCoord(i);
            if (expected != actual) {
                Debug.trap("Expected: " # debug_show (expected) # ", Actual: " # debug_show (actual));
            };
        };
    },
);
