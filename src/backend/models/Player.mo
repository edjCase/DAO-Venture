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
        skills : PlayerSkills;
        position : FieldPosition.FieldPosition;
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

};
