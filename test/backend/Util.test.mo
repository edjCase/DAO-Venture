import { test } "mo:test";
import Random "mo:base/Random";
import Debug "mo:base/Debug";
import Nat "mo:base/Nat";
import Int "mo:base/Int";
import Util "../../src/backend/Util";

test(
    "arrayUpdateElementSafe",
    func() {
        let testUpdate = func(originalArray : [Int], index : Nat, newValue : Int) {
            let newArray = Util.arrayUpdateElementSafe<Int>(originalArray, index, newValue);
            switch (newArray) {
                case (null) {
                    Debug.trap("invalid index: " # Nat.toText(index));
                };
                case (?a) {
                    if (a.size() != originalArray.size()) {
                        Debug.trap("arrays have different lengths");
                    };
                    if (a[index] != newValue) {
                        Debug.trap("newArray[" # Nat.toText(index) # "] != " # Int.toText(newValue));
                    };
                };
            };
        };

        let originalArray = [1, 2, 3, 4, 5];
        testUpdate(originalArray, 0, 2);
        testUpdate(originalArray, 4, 4);
        let failedCase = Util.arrayUpdateElementSafe<Int>(originalArray, 10, 0);
        switch (failedCase) {
            case (null) {
                // expected
            };
            case (?newArray) {
                Debug.trap("expected null, got " # debug_show (newArray));
            };
        };
    },
);
