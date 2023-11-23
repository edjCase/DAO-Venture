import Hash "mo:base/Hash";
module {
    public type PlayerId = Nat32;

    public type Deity = {
        #mischief;
        #war;
        #pestilence;
        #indulgence;
    };

    public type Player = {
        name : Text;
        teamId : ?Principal;
        skills : PlayerSkills;
        position : FieldPosition;
        deity : Deity;
    };

    public type PlayerWithId = Player and {
        id : Nat32;
    };

    public type PlayerSkills = {
        battingAccuracy : Int;
        battingPower : Int;
        throwingAccuracy : Int;
        throwingPower : Int;
        catching : Int;
        defense : Int;
        piety : Int;
        speed : Int;
    };

    public type Skill = {
        #battingAccuracy;
        #battingPower;
        #throwingAccuracy;
        #throwingPower;
        #catching;
        #defense;
        #piety;
        #speed;
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

    public func equalFieldPosition(a : FieldPosition, b : FieldPosition) : Bool {
        a == b;
    };

    public func hashFieldPosition(position : FieldPosition) : Hash.Hash {
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

    public func toTextFieldPosition(position : FieldPosition) : Text {
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
