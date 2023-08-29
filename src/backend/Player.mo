import Hash "mo:base/Hash";
module {
    public type Player = {
        name : Text;
        energy : Int;
        energyRecoveryRate : Nat;
        condition : PlayerCondition;
        skills : PlayerSkills;
        position : FieldPosition;
    };

    public type PlayerWithId = Player and {
        id : Nat32;
    };

    public type PlayerSkills = {
        batting : Int;
        throwing : Int;
        catching : Int;
    };

    public type Injury = {
        #twistedAnkle;
        #brokenLeg;
        #brokenArm;
        #concussion;
    };

    public type PlayerCondition = {
        #ok;
        #injured : Injury;
        #dead;
    };

    public type Base = {
        #firstBase;
        #secondBase;
        #thirdBase;
        #homeBase;
    };

    public func equalBase(a : Base, b : Base) : Bool {
        a == b;
    };

    public func hashBase(location : Base) : Hash.Hash {
        switch (location) {
            case (#homeBase) 0;
            case (#firstBase) 1;
            case (#secondBase) 2;
            case (#thirdBase) 3;
        };
    };

    public func toTextBase(location : Base) : Text {
        switch (location) {
            case (#homeBase) "at bat";
            case (#firstBase) "on first base";
            case (#secondBase) "on second base";
            case (#thirdBase) "on third base";
        };
    };

    public type FieldPosition = {
        #firstBase;
        #secondBase;
        #thirdBase;
        #shortStop;
        #leftField;
        #centerField;
        #rightField;
        #pitcher;
        #catcher;
    };

    public func equalFieldPosition(a : FieldPosition, b : FieldPosition) : Bool {
        a == b;
    };

    public func hashFieldPosition(position : FieldPosition) : Hash.Hash {
        switch (position) {
            case (#firstBase) 0;
            case (#secondBase) 1;
            case (#thirdBase) 2;
            case (#pitcher) 3;
            case (#catcher) 4;
            case (#shortStop) 5;
            case (#leftField) 6;
            case (#centerField) 7;
            case (#rightField) 8;
        };
    };

    public func toTextFieldPosition(position : FieldPosition) : Text {
        switch (position) {
            case (#firstBase) "first base";
            case (#secondBase) "second base";
            case (#thirdBase) "third base";
            case (#pitcher) "pitcher";
            case (#catcher) "catcher";
            case (#shortStop) "short stop";
            case (#leftField) "left field";
            case (#centerField) "center field";
            case (#rightField) "right field";
        };
    };
};
