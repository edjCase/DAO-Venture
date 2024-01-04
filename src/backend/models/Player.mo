import Hash "mo:base/Hash";
import FieldPosition "FieldPosition";
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
        skills : Skills;
        position : FieldPosition.FieldPosition;
    };

    public type PlayerWithId = Player and {
        id : Nat32;
    };

    public type Skills = {
        battingAccuracy : Int;
        battingPower : Int;
        throwingAccuracy : Int;
        throwingPower : Int;
        catching : Int;
        defense : Int;
        piety : Int;
        speed : Int;
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

};
