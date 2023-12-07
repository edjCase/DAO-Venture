import Hash "mo:base/Hash";
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

    public func toText(position : FieldPosition) : Text {
        switch (position) {
            case (#firstBase) "first base";
            case (#secondBase) "second base";
            case (#thirdBase) "third base";
            case (#pitcher) "pitcher";
            case (#shortStop) "short stop";
            case (#leftField) "left field";
            case (#centerField) "center field";
            case (#rightField) "right field";
        };
    };
};
