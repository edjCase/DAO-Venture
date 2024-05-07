import Hash "mo:base/Hash";
import PseudoRandomX "mo:random/PseudoRandomX";

module {

    public type FieldPosition = {
        #firstBase;
        #secondBase;
        #thirdBase;
        #shortStop;
        #leftField;
        #centerField;
        #rightField;
        #pitcher;
    };

    public let allPositions : [FieldPosition] = [
        #pitcher,
        #firstBase,
        #secondBase,
        #thirdBase,
        #shortStop,
        #leftField,
        #centerField,
        #rightField,
    ]; // TODO how to get this list from variant

    public type TeamPositions = {
        firstBase : Nat32;
        secondBase : Nat32;
        thirdBase : Nat32;
        shortStop : Nat32;
        pitcher : Nat32;
        leftField : Nat32;
        centerField : Nat32;
        rightField : Nat32;
    };

    public func getTeamPosition(poistions : TeamPositions, position : FieldPosition) : Nat32 {
        switch (position) {
            case (#firstBase) poistions.firstBase;
            case (#secondBase) poistions.secondBase;
            case (#thirdBase) poistions.thirdBase;
            case (#shortStop) poistions.shortStop;
            case (#leftField) poistions.leftField;
            case (#centerField) poistions.centerField;
            case (#rightField) poistions.rightField;
            case (#pitcher) poistions.pitcher;
        };
    };

    public func getRandom(prng : PseudoRandomX.PseudoRandomGenerator) : FieldPosition {
        let index = prng.nextNat(0, allPositions.size() - 1);
        return allPositions[index];
    };

    public func equal(a : FieldPosition, b : FieldPosition) : Bool {
        a == b;
    };

    public func hash(position : FieldPosition) : Hash.Hash {
        switch (position) {
            case (#firstBase) 0;
            case (#secondBase) 1;
            case (#thirdBase) 2;
            case (#pitcher) 3;
            case (#shortStop) 4;
            case (#leftField) 5;
            case (#centerField) 6;
            case (#rightField) 7;
        };
    };
};
